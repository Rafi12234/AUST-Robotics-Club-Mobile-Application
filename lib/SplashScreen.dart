import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'homepage.dart';
import 'admin_homepage.dart';
import 'size_config.dart';

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
  static const Duration _splashDuration = Duration(milliseconds: 4400);

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
        const AssetImage('assets/images/SplashScreen.gif'),
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
    SizeConfig.init(context);
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
                  top: SizeConfig.screenHeight * -0.15,
                  right: SizeConfig.screenWidth * -0.2,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: SizeConfig.screenWidth * 1.2,
                      height: SizeConfig.screenWidth * 1.2,
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
                  bottom: SizeConfig.screenHeight * -0.12,
                  left: SizeConfig.screenWidth * -0.15,
                  child: Transform.scale(
                    scale: 2 - _pulseAnimation.value,
                    child: Container(
                      width: SizeConfig.screenWidth * 0.6,
                      height: SizeConfig.screenWidth * 0.6,
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
                        width: SizeConfig.screenWidth * 0.85,
                        height: SizeConfig.screenWidth * 0.85,
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

            SizedBox(height: SizeConfig.screenHeight * 0.035),

            // App name
            _buildAppName(),

            SizedBox(height: SizeConfig.screenHeight * 0.01),

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
        width: SizeConfig.screenWidth * 0.55,
        height: SizeConfig.screenWidth * 0.55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.065),
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: const Color(0xFF52B788).withOpacity(0.3),
              blurRadius: SizeConfig.screenWidth * 0.08,
              spreadRadius: SizeConfig.screenWidth * 0.01,
            ),
            // Inner shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: SizeConfig.screenWidth * 0.04,
              offset: Offset(0, SizeConfig.screenWidth * 0.02),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.065),
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
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.006),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.06),
                child: _gifLoaded
                    ? Image.asset(
                        'assets/images/SplashScreen.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : _buildLoadingPlaceholder(),
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
    final offset = SizeConfig.screenWidth * -0.01;
    return [
      Positioned(top: offset, left: offset, child: _buildCornerDot()),
      Positioned(top: offset, right: offset, child: _buildCornerDot()),
      Positioned(bottom: offset, left: offset, child: _buildCornerDot()),
      Positioned(bottom: offset, right: offset, child: _buildCornerDot()),
    ];
  }

  Widget _buildCornerDot() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: SizeConfig.screenWidth * 0.025,
            height: SizeConfig.screenWidth * 0.025,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF52B788), Color(0xFF40916C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF52B788).withOpacity(0.6),
                  blurRadius: SizeConfig.screenWidth * 0.015,
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
              width: SizeConfig.screenWidth * 0.1,
              height: SizeConfig.screenWidth * 0.1,
              child: CircularProgressIndicator(
                strokeWidth: SizeConfig.screenWidth * 0.006,
                valueColor: AlwaysStoppedAnimation(
                  const Color(0xFF52B788).withOpacity(0.7),
                ),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.015),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: SizeConfig.screenWidth * 0.03,
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
        child: Text(
          'AUST ROBOTICS CLUB',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.screenWidth * 0.05,
            fontWeight: FontWeight.w900,
            letterSpacing: SizeConfig.screenWidth * 0.005,
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
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.screenWidth * 0.05,
          vertical: SizeConfig.screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.06),
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
              width: SizeConfig.screenWidth * 0.018,
              height: SizeConfig.screenWidth * 0.018,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF52B788),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF52B788).withOpacity(0.5),
                    blurRadius: SizeConfig.screenWidth * 0.012,
                  ),
                ],
              ),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Text(
              'Innovation • Technology • Excellence',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: SizeConfig.screenWidth * 0.026,
                fontWeight: FontWeight.w500,
                letterSpacing: SizeConfig.screenWidth * 0.002,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      bottom: SizeConfig.screenHeight * 0.14,
      left: SizeConfig.screenWidth * 0.12,
      right: SizeConfig.screenWidth * 0.12,
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
                  height: SizeConfig.screenHeight * 0.005,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.005),
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
                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.005),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2D6A4F),
                                Color(0xFF52B788),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF52B788).withOpacity(0.5),
                                blurRadius: SizeConfig.screenWidth * 0.015,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Glow effect at end
                      Positioned(
                        left: (SizeConfig.screenWidth * 0.76) *
                            _progressAnimation.value -
                            SizeConfig.screenWidth * 0.02,
                        top: SizeConfig.screenHeight * -0.004,
                        child: Container(
                          width: SizeConfig.screenWidth * 0.025,
                          height: SizeConfig.screenWidth * 0.025,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF52B788),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF52B788).withOpacity(0.8),
                                blurRadius: SizeConfig.screenWidth * 0.025,
                                spreadRadius: SizeConfig.screenWidth * 0.004,
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

            SizedBox(height: SizeConfig.screenHeight * 0.015),

            // Loading text with animation
            _AnimatedLoadingText(isAdmin: widget.isAdminLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + SizeConfig.screenHeight * 0.02,
      right: SizeConfig.screenWidth * 0.05,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(SizeConfig.screenWidth * 0.05 * (1 - value), 0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: _navigateToHome,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.04,
              vertical: SizeConfig.screenHeight * 0.012,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: SizeConfig.screenWidth * 0.02,
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
                    fontSize: SizeConfig.screenWidth * 0.03,
                    fontWeight: FontWeight.w600,
                    letterSpacing: SizeConfig.screenWidth * 0.001,
                  ),
                ),
                SizedBox(width: SizeConfig.screenWidth * 0.015),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: SizeConfig.screenWidth * 0.038,
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
      bottom: SizeConfig.screenHeight * 0.05,
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
              offset: Offset(0, SizeConfig.screenHeight * 0.025 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AUST Logo
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: SizeConfig.screenWidth * 0.06,
                    height: SizeConfig.screenWidth * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF52B788).withOpacity(0.8),
                          const Color(0xFF2D6A4F).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.screenWidth * 0.03,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.025),
                  Text(
                    'AUST',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: SizeConfig.screenWidth * 0.035,
                      fontWeight: FontWeight.w700,
                      letterSpacing: SizeConfig.screenWidth * 0.007,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.01),

            Text(
              'Ahsanullah University of Science & Technology',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: SizeConfig.screenWidth * 0.025,
                letterSpacing: SizeConfig.screenWidth * 0.001,
              ),
            ),

            // Show admin indicator if admin is logged in
            if (widget.isAdminLoggedIn) ...[
              SizedBox(height: SizeConfig.screenHeight * 0.015),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.03,
                  vertical: SizeConfig.screenHeight * 0.007,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
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
                      size: SizeConfig.screenWidth * 0.035,
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.015),
                    Text(
                      'Admin Mode',
                      style: TextStyle(
                        color: const Color(0xFFFFB703).withOpacity(0.9),
                        fontSize: SizeConfig.screenWidth * 0.028,
                        fontWeight: FontWeight.w600,
                        letterSpacing: SizeConfig.screenWidth * 0.001,
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
          fontSize: SizeConfig.screenWidth * 0.03,
          fontWeight: FontWeight.w500,
          letterSpacing: SizeConfig.screenWidth * 0.0025,
        ),
      ),
    );
  }
}