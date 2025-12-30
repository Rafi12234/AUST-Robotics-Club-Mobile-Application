import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'homepage.dart';
import 'admin_homepage.dart';

class SplashScreen extends StatefulWidget {
  final bool isAdminLoggedIn;

  const SplashScreen({
    Key? key,
    required this.isAdminLoggedIn,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeInController;
  late AnimationController _pulseController;
  late AnimationController _exitController;
  late AnimationController _progressController;

  // Animations
  late Animation<double> _fadeInAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _exitFadeAnimation;
  late Animation<double> _exitScaleAnimation;
  late Animation<double> _progressAnimation;

  // State
  bool _gifLoaded = false;
  bool _isExiting = false;

  // Splash duration (adjust based on your GIF length)
  static const Duration _splashDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _setupAnimations();
    _preloadGif();
    _startSplashTimer();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF061A11),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  void _setupAnimations() {
    // Fade in animation
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );

    // Pulse animation for decorative elements
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: _splashDuration,
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // Exit animations
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    // Start animations
    _fadeInController.forward();
    _progressController.forward();
  }

  Future<void> _preloadGif() async {
    try {
      await precacheImage(
        const AssetImage('assets/images/splash_screen.gif'),
        context,
      );
      if (mounted) {
        setState(() => _gifLoaded = true);
      }
    } catch (e) {
      debugPrint('Error loading GIF: $e');
      if (mounted) {
        setState(() => _gifLoaded = true);
      }
    }
  }

  void _startSplashTimer() {
    Future.delayed(_splashDuration, () {
      if (mounted && !_isExiting) {
        _navigateToHome();
      }
    });
  }

  Future<void> _navigateToHome() async {
    if (_isExiting) return;

    setState(() => _isExiting = true);

    // Play exit animation
    await _exitController.forward();

    if (mounted) {
      // Reset system UI based on destination
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: widget.isAdminLoggedIn
              ? Brightness.light
              : Brightness.dark,
        ),
      );

      // Navigate based on admin login status
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            // Navigate to AdminDashboard if admin is logged in, else HomePage
            return widget.isAdminLoggedIn
                ? const AdminDashboardPage()
                : const HomePage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A11),
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Opacity(
            opacity: _exitFadeAnimation.value,
            child: Transform.scale(
              scale: _exitScaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),

            // Main content
            _buildMainContent(),

            // Progress indicator
            _buildProgressIndicator(),

            // Skip button
            _buildSkipButton(),

            // Bottom branding
            _buildBottomBranding(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A2A1B),
                Color(0xFF061A11),
                Color(0xFF041008),
              ],
            ),
          ),
        ),

        // Animated glow circles
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Top right glow
                Positioned(
                  top: -120,
                  right: -80,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF2D6A4F).withOpacity(0.3),
                            const Color(0xFF2D6A4F).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom left glow
                Positioned(
                  bottom: -100,
                  left: -60,
                  child: Transform.scale(
                    scale: 2 - _pulseAnimation.value,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF52B788).withOpacity(0.2),
                            const Color(0xFF52B788).withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Center glow behind GIF
                Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF40916C).withOpacity(0.15),
                              const Color(0xFF40916C).withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Particle effects
        ..._buildParticles(),
      ],
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(8, (index) {
      final random = index * 0.125;
      return Positioned(
        top: MediaQuery.of(context).size.height * (0.2 + random * 0.6),
        left: MediaQuery.of(context).size.width * ((index % 4) * 0.25 + 0.05),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 2000 + (index * 200)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -20 * value),
              child: Opacity(
                opacity: (1 - value) * 0.6,
                child: Container(
                  width: 4 + (index % 3) * 2.0,
                  height: 4 + (index % 3) * 2.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF52B788).withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF52B788).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted && !_isExiting) setState(() {});
          },
        ),
      );
    });
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // GIF Container with decorative frame
            _buildGifContainer(),

            const SizedBox(height: 40),

            // App name
            _buildAppName(),

            const SizedBox(height: 12),

            // Tagline
            _buildTagline(),
          ],
        ),
      ),
    );
  }

  Widget _buildGifContainer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: const Color(0xFF52B788).withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
            ),
            // Inner shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF52B788).withOpacity(0.5),
                    const Color(0xFF2D6A4F).withOpacity(0.3),
                    const Color(0xFF1B4332).withOpacity(0.5),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(29),
                  color: const Color(0xFF0A2A1B),
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _gifLoaded
                      ? Image.asset(
                    'assets/images/splash_screen.gif',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                      : _buildLoadingPlaceholder(),
                ),
              ),
            ),

            // Shine effect
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1, end: 2),
                  duration: const Duration(seconds: 3),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: [
                            (value - 0.3).clamp(0.0, 1.0),
                            value.clamp(0.0, 1.0),
                            (value + 0.3).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcOver,
                      child: Container(
                        color: Colors.white,
                      ),
                    );
                  },
                  onEnd: () {
                    if (mounted && !_isExiting) setState(() {});
                  },
                ),
              ),
            ),

            // Corner decorations
            ..._buildCornerDecorations(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerDecorations() {
    return [
      Positioned(top: -5, left: -5, child: _buildCornerDot()),
      Positioned(top: -5, right: -5, child: _buildCornerDot()),
      Positioned(bottom: -5, left: -5, child: _buildCornerDot()),
      Positioned(bottom: -5, right: -5, child: _buildCornerDot()),
    ];
  }

  Widget _buildCornerDot() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF52B788), Color(0xFF40916C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF52B788).withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: const Color(0xFF0A2A1B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(
                  const Color(0xFF52B788).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF52B788),
              Color(0xFFFFFFFF),
            ],
          ).createShader(bounds);
        },
        child: const Text(
          'AUST ROBOTICS CLUB',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF52B788).withOpacity(0.3),
            width: 1,
          ),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF52B788).withOpacity(0.1),
              const Color(0xFF2D6A4F).withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF52B788),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF52B788).withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Innovation • Technology • Excellence',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      bottom: 120,
      left: 40,
      right: 40,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: Column(
          children: [
            // Progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Stack(
                    children: [
                      // Progress fill
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2D6A4F),
                                Color(0xFF52B788),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF52B788).withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Glow effect at end
                      Positioned(
                        left: (MediaQuery.of(context).size.width - 80) *
                            _progressAnimation.value -
                            10,
                        top: -4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF52B788),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF52B788).withOpacity(0.8),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Loading text with animation
            _AnimatedLoadingText(isAdmin: widget.isAdminLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(20 * (1 - value), 0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: _navigateToHome,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBranding() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AUST Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF52B788).withOpacity(0.8),
                          const Color(0xFF2D6A4F).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AUST',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ahsanullah University of Science & Technology',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),

            // Show admin indicator if admin is logged in
            if (widget.isAdminLoggedIn) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFB703).withOpacity(0.2),
                      const Color(0xFFFFB703).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFB703).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: const Color(0xFFFFB703).withOpacity(0.9),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Admin Mode',
                      style: TextStyle(
                        color: const Color(0xFFFFB703).withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========== ANIMATED LOADING TEXT ==========
class _AnimatedLoadingText extends StatefulWidget {
  final bool isAdmin;

  const _AnimatedLoadingText({
    required this.isAdmin,
  });

  @override
  State<_AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late List<String> _loadingTexts;
  int _currentTextIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Different loading texts based on user type
    _loadingTexts = widget.isAdmin
        ? [
      'Initializing admin panel...',
      'Loading dashboard...',
      'Preparing controls...',
      'Almost ready...',
    ]
        : [
      'Initializing...',
      'Loading resources...',
      'Preparing experience...',
      'Almost ready...',
    ];

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        _loadingTexts[_currentTextIndex],
        key: ValueKey(_currentTextIndex),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
    );
  }
}