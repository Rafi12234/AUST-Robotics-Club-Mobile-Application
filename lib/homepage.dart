// homepage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'governing_panel_page.dart';
import 'ResearchProjectsPage.dart';
import 'event_page.dart';
import 'achievement.dart';
import 'member_recruitment_page.dart';
import 'educational_mentorship_training_programs_page.dart';
import 'FancyFloatingButton.dart';
import 'size_config.dart';
import 'footer_page.dart'; // Footer import
import 'dart:math' as math;

/// AUST RC brand greens + white
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kOnPrimary = Colors.white;

class EventItem {
  final int number;
  final String imageUrl;
  final String title;

  EventItem({required this.number, required this.imageUrl, required this.title});
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Method to show the About Dialog
  void _showAboutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: const _AboutDialog(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      extendBodyBehindAppBar: false,

      // -------------------- AppBar with Info Button --------------------
      appBar: AppBar(
        toolbarHeight: SizeConfig.screenHeight * 0.08,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF005022),
        foregroundColor: kOnPrimary,
        elevation: 6,
        centerTitle: false,
        titleSpacing: SizeConfig.screenWidth * 0.04,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGreenDark, kGreenMain],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo2.png',
                height: SizeConfig.screenHeight * 0.045,
                width: SizeConfig.screenHeight * 0.045,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: const Text(
                      'RC',
                      style: TextStyle(
                        color: kOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AUST ROBOTICS CLUB',
                    style: TextStyle(
                      color: kOnPrimary,
                      fontSize: SizeConfig.screenWidth * 0.035,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TypewriterText(
                    text: 'Robotics for Building a Safer Future',
                    style: TextStyle(
                      color: const Color.fromARGB(217, 255, 255, 255),
                      fontSize: SizeConfig.screenWidth * 0.028,
                      fontWeight: FontWeight.w500,
                    ),
                    speed: const Duration(milliseconds: 60),
                    pause: const Duration(milliseconds: 900),
                  ),
                ],
              ),
            ),
          ],
        ),
        // ======== INFO BUTTON HERE ========
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _InfoButton(
              onTap: () => _showAboutDialog(context),
            ),
          ),
        ],
      ),
      // ------------------------------------------------------------------------------

      body: const SafeArea(
        child: HomeBody(),
      ),

      floatingActionButton: FancyFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      backgroundColor: Colors.white,
    );
  }
}

// ============================================
// INFO BUTTON WIDGET
// ============================================
class _InfoButton extends StatefulWidget {
  final VoidCallback onTap;

  const _InfoButton({required this.onTap});

  @override
  State<_InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<_InfoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1 + (0.1 * _pulseController.value)),
                    blurRadius: 8 + (4 * _pulseController.value),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================
// ABOUT DIALOG
// ============================================
class _AboutDialog extends StatefulWidget {
  const _AboutDialog();

  @override
  State<_AboutDialog> createState() => _AboutDialogState();
}

class _AboutDialogState extends State<_AboutDialog>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimController;
  late AnimationController _contentAnimController;

  @override
  void initState() {
    super.initState();

    _logoAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentAnimController.forward();
    });
  }

  @override
  void dispose() {
    _logoAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Gradient
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0F3D2E),
                        Color(0xFF1A5C43),
                        Color(0xFF267556)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      // Logos Row with Animation
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _logoAnimController,
                          curve: Curves.elasticOut,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // AUST Logo
                            _LogoContainer(
                              imagePath: 'assets/images/AUST.png',
                              size: 70,
                            ),
                            const SizedBox(width: 20),
                            // Connecting Line with Glow
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // AUSTRC Logo
                            _LogoContainer(
                              imagePath: 'assets/images/logo2.png',
                              size: 70,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      FadeTransition(
                        opacity: _logoAnimController,
                        child: Column(
                          children: [
                            const Text(
                              'AUST ROBOTICS CLUB',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                '🤖 Robotics for Building a Safer Future',
                                style: TextStyle(
                                  color: Color(0xFFB8E6D5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _contentAnimController,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _contentAnimController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Description
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5FBF8),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE0F2E9),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: kGreenMain.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: kGreenMain,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'About Us',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F3D2E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'AUST Robotics Club is a leading club for students at Ahsanullah University of Science and Technology.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2D5A4A),
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        kGreenMain.withOpacity(0.1),
                                        kGreenDark.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: kGreenMain.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.format_quote_rounded,
                                        color: kGreenMain.withOpacity(0.6),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          '"Robotics for Building a Safer Future"',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F3D2E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'AUSTRC has a vibrant student community dedicated to advancing innovation in robotics. From microcontroller projects, and autonomous robots to large-scale initiatives like the Mars Rover, AI and autonomous quadcopters, we empower collaboration and bring ideas to life on both national and international stages.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4A7A6A),
                                    height: 1.7,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Highlights
                          Row(
                            children: [
                              Expanded(
                                child: _HighlightChip(
                                  icon: Icons.precision_manufacturing_rounded,
                                  label: 'Mars Rover',
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HighlightChip(
                                  icon: Icons.smart_toy_rounded,
                                  label: 'AI Projects',
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HighlightChip(
                                  icon: Icons.flight_rounded,
                                  label: 'Quadcopters',
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Close Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F3D2E),
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: kGreenDark.withOpacity(0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Got It!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// LOGO CONTAINER WIDGET
// ============================================
class _LogoContainer extends StatelessWidget {
  final String imagePath;
  final double size;

  const _LogoContainer({
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.grey[400],
                  size: size * 0.4,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================
// HIGHLIGHT CHIP WIDGET
// ============================================
class _HighlightChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HighlightChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// ========================== BODY CONTENT ===================================
class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        // Main content with padding
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              const _WelcomeCard(),
              SizedBox(height: SizeConfig.screenHeight * 0.015),
              const _RecentEventsCarousel(),
              SizedBox(height: SizeConfig.screenHeight * 0.001),
              Align(
                alignment: Alignment.centerRight,
                child: _ExploreEventsButton(),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.005),
              const _QuickActionsRow(),
              SizedBox(height: SizeConfig.screenHeight * 0.005),
              SizedBox(height: SizeConfig.screenHeight * 0.015),
              const _EducationalMentorshipSection(),
              SizedBox(height: SizeConfig.screenHeight * 0.03),

              // ========== NEW SECTIONS ==========
              const _OurSponsorsSection(),
              SizedBox(height: SizeConfig.screenHeight * 0.03),
              const _CollaboratedClubsSection(),
              SizedBox(height: SizeConfig.screenHeight * 0.03),
              // ====================================

              const VoiceOfAUSTRC(),
            ],
          ),
        ),

        // Footer Transition Section
        const _FooterTransitionSection(),

        // Footer
        const FooterPage(),
      ],
    );
  }
}

// ============================================
// CONTINUOUS MOVING CAROUSEL WIDGET
// ============================================
class ContinuousMovingCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double itemWidth;
  final double speed;
  final double itemSpacing;
  final BorderRadius? borderRadius;
  final BoxFit imageFit;

  const ContinuousMovingCarousel({
    super.key,
    required this.imageUrls,
    this.height = 100,
    this.itemWidth = 150,
    this.speed = 30,
    this.itemSpacing = 16,
    this.borderRadius,
    this.imageFit = BoxFit.contain,
  });

  @override
  State<ContinuousMovingCarousel> createState() => _ContinuousMovingCarouselState();
}

class _ContinuousMovingCarouselState extends State<ContinuousMovingCarousel>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _currentOffset = 0;
  bool _isPaused = false;

  double get _itemTotalWidth => widget.itemWidth + widget.itemSpacing;
  double get _totalContentWidth => widget.imageUrls.length * _itemTotalWidth;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imageUrls.isNotEmpty) {
        _startContinuousScroll();
      }
    });
  }

  void _startContinuousScroll() {
    const frameRate = Duration(milliseconds: 16); // ~60 FPS
    final pixelsPerFrame = widget.speed / 60;

    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(frameRate, (timer) {
      if (!_isPaused && _scrollController.hasClients && mounted) {
        _currentOffset += pixelsPerFrame;

        // Reset when we've scrolled through one complete set
        if (_currentOffset >= _totalContentWidth) {
          _currentOffset = _currentOffset % _totalContentWidth;
        }

        _scrollController.jumpTo(_currentOffset);
      }
    });
  }

  void _pauseScroll() {
    setState(() => _isPaused = true);
  }

  void _resumeScroll() {
    setState(() => _isPaused = false);
  }

  @override
  void didUpdateWidget(ContinuousMovingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls ||
        oldWidget.speed != widget.speed) {
      _scrollTimer?.cancel();
      _currentOffset = 0;
      if (widget.imageUrls.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startContinuousScroll();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(height: widget.height);
    }

    // Create 4 copies for seamless infinite scroll
    final List<String> extendedUrls = [
      ...widget.imageUrls,
      ...widget.imageUrls,
      ...widget.imageUrls,
      ...widget.imageUrls,
    ];

    return GestureDetector(
      onPanDown: (_) => _pauseScroll(),
      onPanEnd: (_) => _resumeScroll(),
      onPanCancel: _resumeScroll,
      child: SizedBox(
        height: widget.height,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: extendedUrls.length,
          itemBuilder: (context, index) {
            final url = extendedUrls[index];
            return _CarouselImageItem(
              imageUrl: url,
              width: widget.itemWidth,
              height: widget.height,
              spacing: widget.itemSpacing,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              imageFit: widget.imageFit,
            );
          },
        ),
      ),
    );
  }
}

class _CarouselImageItem extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double spacing;
  final BorderRadius borderRadius;
  final BoxFit imageFit;

  const _CarouselImageItem({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.spacing,
    required this.borderRadius,
    required this.imageFit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(right: spacing),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          imageUrl,
          fit: imageFit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: const AlwaysStoppedAnimation(kGreenMain),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF5F5F5),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey[400],
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================
// OUR SPONSORS SECTION
// ============================================
class _OurSponsorsSection extends StatelessWidget {
  const _OurSponsorsSection();

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Sponsor_Images');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kGreenDark.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handshake_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Sponsors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Partners powering our innovation',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB8E6D5),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber.withOpacity(0.8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Sponsors Carousel
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorBox('Failed to load sponsors');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonCarousel();
            }

            final urls = _extractImageUrls(snapshot.data?.data());

            if (urls.isEmpty) {
              return _buildEmptyBox('No sponsor images available');
            }

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
                  ),
                ),
                child: ContinuousMovingCarousel(
                  imageUrls: urls,
                  height: 80,
                  itemWidth: 140,
                  speed: 35,
                  itemSpacing: 20,
                  borderRadius: BorderRadius.circular(12),
                  imageFit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<String> _extractImageUrls(Map<String, dynamic>? data) {
    if (data == null) return [];

    final reg = RegExp(r'^Image_(\d+)$');
    final entries = <MapEntry<int, String>>[];

    data.forEach((key, value) {
      final match = reg.firstMatch(key);
      if (match != null && value is String && value.trim().isNotEmpty) {
        final num = int.tryParse(match.group(1)!);
        if (num != null) {
          entries.add(MapEntry(num, value.trim()));
        }
      }
    });

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => e.value).toList();
  }

  Widget _buildSkeletonCarousel() {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(kGreenMain),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// COLLABORATED CLUBS SECTION
// ============================================
class _CollaboratedClubsSection extends StatelessWidget {
  const _CollaboratedClubsSection();

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Collaborated_Clubs');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_3_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collaborated Clubs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Building together with amazing teams',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFBFDBFE),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.link_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Clubs Carousel
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorBox('Failed to load collaborated clubs');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonCarousel();
            }

            final urls = _extractImageUrls(snapshot.data?.data());

            if (urls.isEmpty) {
              return _buildEmptyBox('No collaborated clubs images available');
            }

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEFF6FF),
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                  ),
                ),
                child: ContinuousMovingCarousel(
                  imageUrls: urls,
                  height: 90,
                  itemWidth: 90,
                  speed: 40,
                  itemSpacing: 16,
                  borderRadius: BorderRadius.circular(45),
                  imageFit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<String> _extractImageUrls(Map<String, dynamic>? data) {
    if (data == null) return [];

    final reg = RegExp(r'^Image_(\d+)$');
    final entries = <MapEntry<int, String>>[];

    data.forEach((key, value) {
      final match = reg.firstMatch(key);
      if (match != null && value is String && value.trim().isNotEmpty) {
        final num = int.tryParse(match.group(1)!);
        if (num != null) {
          entries.add(MapEntry(num, value.trim()));
        }
      }
    });

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => e.value).toList();
  }

  Widget _buildSkeletonCarousel() {
    return Container(
      height: 122,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Color(0xFF2563EB)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      height: 122,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      height: 122,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FOOTER TRANSITION SECTION
// ============================================
class _FooterTransitionSection extends StatefulWidget {
  const _FooterTransitionSection();

  @override
  State<_FooterTransitionSection> createState() =>
      _FooterTransitionSectionState();
}

class _FooterTransitionSectionState extends State<_FooterTransitionSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFE8F5E9),
            Color(0xFFA5D6A7),
            Color(0xFF0A2E1F),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _TransitionPatternPainter(),
            ),
          ),

          // Center content
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 15 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated wave dots
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final delay = index * 0.15;
                        final animValue =
                        ((_waveController.value + delay) % 1.0);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.translate(
                            offset: Offset(0, -6 * animValue),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: kGreenMain.withOpacity(0.6 + (0.4 * animValue)),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: kGreenMain.withOpacity(0.4 * animValue),
                                    blurRadius: 8 * animValue,
                                    spreadRadius: 2 * animValue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Connect with us badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Connect With Us',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Transition Pattern Painter
class _TransitionPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle circles
    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.1 + i * 0.12);
      final y = size.height * (i.isEven ? 0.25 : 0.65);
      canvas.drawCircle(Offset(x, y), 25 + (i % 3) * 10, paint);
    }

    // Draw curved wave line
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final wavePath = Path()
      ..moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.5 + 15 * math.sin(x / 50);
      wavePath.lineTo(x, y);
    }

    canvas.drawPath(wavePath, wavePaint);

    // Second wave
    final wavePath2 = Path()
      ..moveTo(0, size.height * 0.6);

    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.6 + 10 * math.sin((x / 40) + 1);
      wavePath2.lineTo(x, y);
    }

    canvas.drawPath(wavePath2, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// WELCOME CARD
// ============================================
class _WelcomeCard extends StatefulWidget {
  const _WelcomeCard();

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F3D2E),
                Color(0xFF1A5C43),
                Color(0xFF267556),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kGreenDark.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: _WelcomePatternPainter(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: (1 - value) * 0.5,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: SizeConfig.screenHeight * 0.054,
                        width: SizeConfig.screenWidth * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handshake_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(30 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome to AUST Robotics Club!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                height: 1.3,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7FE5A9),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    "Explore our latest events and projects",
                                    style: TextStyle(
                                      color: Color(0xFFB8E6D5),
                                      fontSize: 13.5,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: -1.0, end: 2.0),
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.easeInOut,
                    builder: (context, shimmerValue, child) {
                      return CustomPaint(
                        painter: _WelcomeShimmerPainter(
                            shimmerProgress: shimmerValue),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final xPos = size.width * (0.2 + (i * 0.15));
      final yPos = size.height * (i.isEven ? 0.3 : 0.7);
      canvas.drawCircle(Offset(xPos, yPos), 40, circlePaint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * i / 6, 0),
        Offset(size.width * i / 6, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WelcomeShimmerPainter extends CustomPainter {
  final double shimmerProgress;

  _WelcomeShimmerPainter({required this.shimmerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(
          size.width * shimmerProgress - size.width * 0.3,
          0,
          size.width * 0.6,
          size.height,
        ),
      );

    canvas.drawRect(Offset.zero & size, shimmerPaint);
  }

  @override
  bool shouldRepaint(_WelcomeShimmerPainter oldDelegate) =>
      oldDelegate.shimmerProgress != shimmerProgress;
}

// ============================================
// RECENT EVENTS CAROUSEL
// ============================================
class _RecentEventsCarousel extends StatefulWidget {
  const _RecentEventsCarousel();

  @override
  State<_RecentEventsCarousel> createState() => _RecentEventsCarouselState();
}

class _RecentEventsCarouselState extends State<_RecentEventsCarousel>
    with AutomaticKeepAliveClientMixin {
  final _collectionRef = FirebaseFirestore.instance
      .collection('All_Data')
      .doc('Event_Page')
      .collection('All_Events_of_RC');

  late final PageController _controller;
  Timer? _timer;
  static const _autoSlideEvery = Duration(seconds: 3);
  static const _animDuration = Duration(milliseconds: 400);

  int? _lastCount;
  bool _didInitialJump = false;
  int _initialPage(int itemCount) => itemCount * 1000;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _ensureStartPosition(int itemCount) {
    if (_didInitialJump || itemCount <= 0) return;
    final start = _initialPage(itemCount);
    if (_controller.hasClients) {
      _controller.jumpToPage(start);
      _didInitialJump = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.hasClients) {
          _controller.jumpToPage(start);
          _didInitialJump = true;
        }
      });
    }
  }

  void _ensureAutoTimer(int itemCount) {
    if (_timer != null || itemCount <= 1) return;
    _timer = Timer.periodic(_autoSlideEvery, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(duration: _animDuration, curve: Curves.easeOut);
    });
  }

  int _getOrderValue(dynamic orderValue) {
    if (orderValue == null) return 999;
    if (orderValue is int) return orderValue;
    if (orderValue is String) {
      return int.tryParse(orderValue) ?? 999;
    }
    return 999;
  }

  List<EventItem> _extractEventsFromDocs(List<QueryDocumentSnapshot> docs) {
    final items = <EventItem>[];

    for (var i = 0; i < docs.length; i++) {
      final doc = docs[i];
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final coverPicture = (data['Cover_Picture'] as String?)?.trim() ?? '';
      final eventName = (data['Event_Name'] as String?)?.trim() ?? doc.id;
      final order = _getOrderValue(data['Order']);

      if ((order == 1 || order == 2 || order == 3) && coverPicture.isNotEmpty) {
        items.add(EventItem(
          number: order,
          imageUrl: coverPicture,
          title: eventName,
        ));
      }
    }

    items.sort((a, b) => a.number.compareTo(b.number));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _collectionRef.orderBy('Order', descending: false).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _errorBox('Failed to load recent events.\n${snap.error}');
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return _skeleton(height: 200);
        }

        final docs = snap.data?.docs ?? [];
        final events = _extractEventsFromDocs(docs);

        if (events.isEmpty) {
          _timer?.cancel();
          _timer = null;
          _didInitialJump = false;
          _lastCount = 0;
          return _emptyBox(
              'No events with Order 1, 2, 3 found.\nSet event Order to 1, 2, or 3 in Admin Panel.');
        }

        if (_lastCount != events.length) {
          _lastCount = events.length;
          _didInitialJump = false;
          _timer?.cancel();
          _timer = null;
        }

        _ensureStartPosition(events.length);
        _ensureAutoTimer(events.length);

        return SizedBox(
          height: SizeConfig.screenHeight * 0.19,
          child: PageView.builder(
            controller: _controller,
            allowImplicitScrolling: true,
            itemBuilder: (context, index) {
              final item = events[index % events.length];
              return _PosterCard(item: item);
            },
          ),
        );
      },
    );
  }

  Widget _skeleton({double height = 200}) => Container(
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F3F1),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _emptyBox(String message) => Container(
    height: 160,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black54),
    ),
  );

  Widget _errorBox(String message) => Container(
    height: 160,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFCDD2)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFB00020)),
    ),
  );
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.item});
  final EventItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFF5F5F5),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFDECEC),
                    alignment: Alignment.center,
                    child: const Text(
                      'Image error',
                      style: TextStyle(color: Color(0xFFB00020)),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// TYPEWRITER TEXT
// ============================================
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 80),
    this.pause = const Duration(milliseconds: 800),
  });

  final String text;
  final TextStyle? style;
  final Duration speed;
  final Duration pause;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _index = 0;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.speed, (t) {
      if (!mounted) return;
      if (_index < widget.text.length) {
        setState(() => _index++);
      } else {
        _timer?.cancel();
        Future.delayed(widget.pause, () {
          if (!mounted) return;
          setState(() => _index = 0);
          _start();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.speed != widget.speed ||
        oldWidget.pause != widget.pause) {
      _index = 0;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible =
    widget.text.substring(0, _index.clamp(0, widget.text.length));
    return Text(
      visible,
      style: widget.style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ============================================
// EXPLORE EVENTS BUTTON (continued)
// ============================================
class _ExploreEventsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 17),
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A5C43), Color(0xFF0F3D2E)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.039,
                    vertical: SizeConfig.screenHeight * 0.01,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore All Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: SizeConfig.screenHeight * 0.014,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(4 * value, 0),
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 13),
      ],
    );
  }
}

// ============================================
// QUICK ACTIONS ROW
// ============================================
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kGreenDark.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.smart_button_sharp, color: Colors.white, size: 28),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Action Buttons',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All important options are in one place ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB8E6D5),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.9,
            children: [
              _QuickActionCard(
                label: 'Governing\nPanel',
                icon: Icons.groups_rounded,
                primary: const Color(0xFF0B6B3A),
                secondary: const Color(0xFF16A34A),
                delay: 0,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GoverningPanelPage()),
                  );
                },
              ),
              _QuickActionCard(
                label: 'Research &\nProjects',
                icon: Icons.biotech_rounded,
                primary: const Color(0xFF065F46),
                secondary: const Color(0xFF22C55E),
                delay: 100,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ResearchProjectsPage()),
                  );
                },
              ),
              _QuickActionCard(
                label: 'Member\nRecruitment',
                icon: Icons.event_available_rounded,
                primary: const Color(0xFF047857),
                secondary: const Color(0xFF10B981),
                delay: 200,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MemberRecruitmentPage()),
                  );
                },
              ),
              _QuickActionCard(
                label: 'Achievements',
                icon: Icons.emoji_events_rounded,
                primary: const Color(0xFF4D7C0F),
                secondary: const Color(0xFF84CC16),
                delay: 300,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AchievementPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.delay,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color primary;
  final Color secondary;
  final int delay;
  final VoidCallback? onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _entryController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _pressController.dispose();
    _entryController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _entryAnimation,
      child: FadeTransition(
        opacity: _entryAnimation,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _shimmerController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _pressController.forward(),
                onTapUp: (_) {
                  _pressController.reverse();
                  widget.onTap?.call();
                },
                onTapCancel: () => _pressController.reverse(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        widget.primary,
                        widget.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primary
                            .withOpacity(0.4 * _elevationAnimation.value),
                        blurRadius: 16 * _elevationAnimation.value,
                        offset: Offset(0, 8 * _elevationAnimation.value),
                        spreadRadius: 2 * _elevationAnimation.value,
                      ),
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.1 * _elevationAnimation.value),
                        blurRadius: 8 * _elevationAnimation.value,
                        offset: Offset(0, 4 * _elevationAnimation.value),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomPaint(
                            painter: _ShimmerPainter(
                              animation: _shimmerController,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.all(SizeConfig.screenWidth * 0.022),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                size: SizeConfig.screenWidth * 0.050,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: SizeConfig.screenWidth * 0.035,
                                height: 1.2,
                                letterSpacing: 0.3,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _ShimmerPainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final progress = animation.value;
    final shimmerWidth = size.width * 0.3;
    final startX = -shimmerWidth + (size.width + shimmerWidth * 2) * progress;

    final path = Path()
      ..moveTo(startX, 0)
      ..lineTo(startX + shimmerWidth, 0)
      ..lineTo(startX + shimmerWidth * 1.5, size.height)
      ..lineTo(startX + shimmerWidth * 0.5, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) => true;
}

// ============================================
// EDUCATIONAL & MENTORSHIP SECTION
// ============================================
class _EducationalProgramItem {
  final int order;
  final String imageUrl;
  final String name;

  _EducationalProgramItem({
    required this.order,
    required this.imageUrl,
    required this.name,
  });

  factory _EducationalProgramItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    // Get Order field (handle both int and string)
    int order = 999;
    if (data['Order'] != null) {
      if (data['Order'] is int) {
        order = data['Order'] as int;
      } else if (data['Order'] is String) {
        order = int.tryParse(data['Order'] as String) ?? 999;
      }
    }

    // Get Image_1
    final imageUrl = (data['Image_1'] as String?)?.trim() ?? '';

    // Get Name (use document ID as fallback)
    final name = (data['Name'] as String?)?.trim() ?? doc.id;

    return _EducationalProgramItem(
      order: order,
      imageUrl: imageUrl,
      name: name,
    );
  }
}

class _EducationalMentorshipSection extends StatelessWidget {
  const _EducationalMentorshipSection();

  @override
  Widget build(BuildContext context) {
    // New collection reference
    final collectionRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Educational, Mentorship & Training Programs')
        .collection('educational, mentorship & training programs');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(1, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kGreenDark.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Educational & Mentorship',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Training Programs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB8E6D5),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // StreamBuilder for Collection
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: collectionRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _EMErrorBox('Failed to load educational programs.');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _EMSkeletonList();
            }

            final docs = snapshot.data?.docs ?? [];

            // Convert to items and filter
            final allItems = docs
                .map((doc) => _EducationalProgramItem.fromFirestore(doc))
                .where((item) =>
            item.order >= 1 &&
                item.order <= 3 &&
                item.imageUrl.isNotEmpty)
                .toList();

            // Sort by order
            allItems.sort((a, b) => a.order.compareTo(b.order));

            // Take only top 3
            final displayItems = allItems.take(3).toList();

            if (displayItems.isEmpty) {
              return const _EMEmptyBox(
                'No programs with Order 1, 2, or 3 found.\nSet Order to 1, 2, or 3 in Admin Panel.',
              );
            }

            return SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayItems.length,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, index) {
                  return _EducationalProgramCard(
                    item: displayItems[index],
                    index: index,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Explore All Programs Button
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A5C43), Color(0xFF0F3D2E)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: kGreenMain.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationalProgramsPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.039,
                      vertical: SizeConfig.screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore All Programs',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: SizeConfig.screenHeight * 0.014,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(4 * value, 0),
                              child: child,
                            );
                          },
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EducationalProgramCard extends StatefulWidget {
  const _EducationalProgramCard({
    required this.item,
    required this.index,
  });

  final _EducationalProgramItem item;
  final int index;

  @override
  State<_EducationalProgramCard> createState() =>
      _EducationalProgramCardState();
}

class _EducationalProgramCardState extends State<_EducationalProgramCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset((1 - animValue) * 50, 0),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -6.0 : 0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFE8F5E9),
                              Color(0xFFC8E6C9),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(kGreenDark),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Color(0xFFB00020),
                      ),
                    ),
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Program Name
                      Text(
                        widget.item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Shine Effect on Hover
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Skeleton Loader
class _EMSkeletonList extends StatelessWidget {
  const _EMSkeletonList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, i) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFF1F8F4),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Modern Empty State
class _EMEmptyBox extends StatelessWidget {
  const _EMEmptyBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Error State
class _EMErrorBox extends StatelessWidget {
  const _EMErrorBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F5), Color(0xFFFFEBEE)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB00020), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB00020),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// VOICE OF AUSTRC
// ============================================
class VoiceOfAUSTRC extends StatefulWidget {
  const VoiceOfAUSTRC({super.key});

  @override
  State<VoiceOfAUSTRC> createState() => _VoiceOfAUSTRCState();
}

class _VoiceOfAUSTRCState extends State<VoiceOfAUSTRC>
    with AutomaticKeepAliveClientMixin {
  final _docRef =
  FirebaseFirestore.instance.collection('All_Data').doc('Voice_of_AUSTRC');

  late final PageController _controller;
  Timer? _timer;

  // Slide config
  static const _autoSlideEvery = Duration(seconds: 3);
  static const _animDuration = Duration(milliseconds: 500);

  int _initialPageIndex = 5000;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.9,
      initialPage: _initialPageIndex,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _startTimer(List<String> urls) {
    _timer?.cancel();
    if (urls.length <= 1) return;

    _timer = Timer.periodic(_autoSlideEvery, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(
        duration: _animDuration,
        curve: Curves.easeOut,
      );
    });
  }

  /// Extract fields like Voice_1, Voice_2 and sort by number ascending
  List<String> _extractUrls(Map<String, dynamic>? data) {
    if (data == null) return [];
    final reg = RegExp(r'^Voice_(\d+)$');
    final entries = <MapEntry<int, String>>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1)!);
        if (n != null) entries.add(MapEntry(n, value.trim()));
      }
    });

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => e.value).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kGreenDark.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.white, size: 28),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice of AUSTRC',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Voices from our dedicated members',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB8E6D5),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _docRef.snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return _errorBox('Failed to load posters.\n${snap.error}');
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return _skeleton();
            }

            final urls = _extractUrls(snap.data?.data());
            if (urls.isEmpty) {
              return _emptyBox('No posters yet.\nAdd Voice_1, Voice_2 …');
            }
            _startTimer(urls);
            return SizedBox(
              height: SizeConfig.screenHeight * 0.4,
              width: SizeConfig.screenWidth * 0.94,
              child: PageView.builder(
                controller: _controller,
                allowImplicitScrolling: true,
                itemBuilder: (context, index) {
                  final url = urls[index % urls.length];
                  return _VoicePosterCard(url: url);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _skeleton() => Container(
    height: 200,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F3F1),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: const SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _emptyBox(String message) => Container(
    height: 150,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black54),
    ),
  );

  Widget _errorBox(String message) => Container(
    height: 150,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFCDD2)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFB00020)),
    ),
  );
}

/// Single poster card with rounded corners and shadow
class _VoicePosterCard extends StatelessWidget {
  final String url;
  const _VoicePosterCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xFFF5F5F5),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFFDECEC),
              alignment: Alignment.center,
              child: const Text(
                'Image error',
                style: TextStyle(color: Color(0xFFB00020)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}