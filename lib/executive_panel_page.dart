import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'size_config.dart';

class ExecutivePanelPage extends StatefulWidget {
  final String semesterId;

  const ExecutivePanelPage({
    Key? key,
    required this.semesterId,
  }) : super(key: key);

  @override
  State<ExecutivePanelPage> createState() => _ExecutivePanelPageState();
}

class _ExecutivePanelPageState extends State<ExecutivePanelPage>
    with SingleTickerProviderStateMixin {
  static const Color brandStart = Color(0xFF0B6B3A);
  static const Color brandEnd = Color(0xFF16A34A);
  static const Color bgGradientStart = Color(0xFFE8F5E9);
  static const Color bgGradientEnd = Color(0xFFF1F8E9);

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final query = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Governing_Panel')
        .collection('Semesters')
        .doc(widget.semesterId)
        .collection('Executive_Panel')
        .orderBy('Order');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart, bgGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _Header(
                semesterId: widget.semesterId,
                floatingController: _floatingController,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: query.snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(brandStart),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading profiles...',
                              style: TextStyle(
                                color: brandStart,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return const _ErrorState();
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const _EmptyState();
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        SizeConfig.screenWidth * 0.02,
                        SizeConfig.screenHeight * 0.02,
                        SizeConfig.screenWidth * 0.02,
                        SizeConfig.screenHeight * 0.02,
                      ),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => SizedBox(height: SizeConfig.screenHeight * 0.025),
                      itemBuilder: (context, i) {
                        final data = docs[i].data();

                        final name = (data['Name'] ?? '').toString();
                        final designation =
                        (data['Designation'] ?? '').toString();
                        final department =
                        (data['Department'] ?? '').toString();
                        final email = (data['Email'] ?? '').toString();
                        final imageUrl = (data['Image'] ?? '').toString();
                        final facebook = (data['Facebook'] ?? '').toString();
                        final linkedIn = (data['LinkedIn'] ?? '').toString();

                        return _ProfileCard(
                          imageUrl: imageUrl,
                          name: name,
                          designation: designation,
                          department: department,
                          email: email,
                          facebook: facebook,
                          linkedIn: linkedIn,
                          index: i,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String semesterId;
  final AnimationController floatingController;

  const _Header({
    required this.semesterId,
    required this.floatingController,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      height: SizeConfig.screenHeight * 0.1 + topInset,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF064E3B),
            Color(0xFF0B6B3A),
            Color(0xFF16A34A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeConfig.screenWidth * 0.09),
          bottomRight: Radius.circular(SizeConfig.screenWidth * 0.09),
        ),
      ),
      child: Stack(
        children: [
          // Header Pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(SizeConfig.screenWidth * 0.1),
                bottomRight: Radius.circular(SizeConfig.screenWidth * 0.1),
              ),
              child: CustomPaint(
                painter: _HeaderPatternPainter(
                  animation: floatingController,
                ),
              ),
            ),
          ),

          // Header Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              SizeConfig.screenWidth * 0.03,
              topInset + SizeConfig.screenHeight * 0.02,
              SizeConfig.screenWidth * 0.03,
              SizeConfig.screenHeight * 0.02,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Back Button
                    _AnimatedBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.03),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(30 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              'Executive Panel',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.06,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.003),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(30 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              semesterId,
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.03,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Decorative Badge
                    _HeaderBadge(animation: floatingController),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// HEADER PATTERN PAINTER
// ============================================
class _HeaderPatternPainter extends CustomPainter {
  final AnimationController animation;

  _HeaderPatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Animated circles
    for (var i = 0; i < 6; i++) {
      final progress = (animation.value + i * 0.15) % 1.0;
      final x = size.width * (0.1 + i * 0.18);
      final y = size.height * (0.3 + math.sin(progress * math.pi * 2) * 0.1);
      final radius = 20.0 + i * 8;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Grid lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderPatternPainter oldDelegate) => true;
}

// ============================================
// ANIMATED BACK BUTTON
// ============================================
class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.onTap});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.016),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: SizeConfig.screenWidth * 0.005,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: SizeConfig.screenWidth * 0.045,
        ),
      ),
    );
  }
}

// ============================================
// HEADER BADGE
// ============================================
class _HeaderBadge extends StatelessWidget {
  final AnimationController animation;

  const _HeaderBadge({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15 + animation.value * 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3 + animation.value * 0.2),
              width: SizeConfig.screenWidth * 0.005,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1 * animation.value),
                blurRadius: SizeConfig.screenWidth * 0.04 * animation.value,
                spreadRadius: SizeConfig.screenWidth * 0.008 * animation.value,
              ),
            ],
          ),
          child: Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: SizeConfig.screenWidth * 0.06,
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String facebook;
  final String linkedIn;
  final int index;

  const _ProfileCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.facebook,
    required this.linkedIn,
    required this.index,
  }) : super(key: key);

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launch(String url, String platform) async {
    final u = url.trim();

    // Check if the field value is "N/A" or other invalid placeholder values
    final lowerU = u.toLowerCase();
    bool isNotAvailable = u.isEmpty ||
        lowerU == 'n/a' ||
        lowerU == 'na' ||
        lowerU == 'n.a' ||
        lowerU == 'n.a.' ||
        u == '-' ||
        u == '--' ||
        lowerU == 'null' ||
        lowerU == 'not available' ||
        lowerU == 'none' ||
        lowerU == 'no' ||
        lowerU == 'nil';

    if (isNotAvailable) {
      _showNotAvailableMessage(platform);
      return;
    }

    // Valid URL found - try to launch it
    String finalUrl = u;
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      finalUrl = 'https://$u';
    }

    final uri = Uri.tryParse(finalUrl);
    if (uri == null) {
      _showNotAvailableMessage(platform);
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // Only show error if launch actually fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $platform'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showNotAvailableMessage(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              platform == 'Facebook' ? Icons.facebook_rounded : Icons.work_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Currently $platform is not available',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: platform == 'Facebook'
            ? const Color(0xFF1877F2)
            : const Color(0xFF0A66C2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _mailto(String address) async {
    final a = address.trim();

    // Check if email is "N/A" or other invalid placeholder values
    final lowerA = a.toLowerCase();
    bool isNotAvailable = a.isEmpty ||
        lowerA == 'n/a' ||
        lowerA == 'na' ||
        lowerA == 'n.a' ||
        lowerA == 'n.a.' ||
        a == '-' ||
        a == '--' ||
        lowerA == 'null' ||
        lowerA == 'not available' ||
        lowerA == 'none' ||
        lowerA == 'no' ||
        lowerA == 'nil';

    if (isNotAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Email is not available',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          backgroundColor: _ExecutivePanelPageState.brandStart,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create Gmail compose URL that opens in browser
    final gmailUrl = Uri.parse('https://mail.google.com/mail/?view=cm&to=$a');

    try {
      if (await canLaunchUrl(gmailUrl)) {
        await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to mailto if Gmail URL fails
        final mailtoUri = Uri(scheme: 'mailto', path: a);
        if (await canLaunchUrl(mailtoUri)) {
          await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      // Fallback to mailto if Gmail URL fails
      final mailtoUri = Uri(scheme: 'mailto', path: a);
      try {
        if (await canLaunchUrl(mailtoUri)) {
          await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Error launching email: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = widget.imageUrl.trim().isNotEmpty;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
            border: Border.all(
              color: _ExecutivePanelPageState.brandStart.withOpacity(0.08),
              width: SizeConfig.screenWidth * 0.004,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: SizeConfig.screenWidth * 0.05,
                spreadRadius: 0,
                color: Colors.black.withOpacity(0.08),
                offset: Offset(0, SizeConfig.screenHeight * 0.01),
              ),
              BoxShadow(
                blurRadius: SizeConfig.screenWidth * 0.02,
                spreadRadius: -4,
                color: _ExecutivePanelPageState.brandStart.withOpacity(0.05),
                offset: Offset(0, SizeConfig.screenHeight * 0.005),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image with overlay gradient
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 16,
                    child: hasImg
                        ? CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _ExecutivePanelPageState.brandStart),
                          strokeWidth: SizeConfig.screenWidth * 0.003,
                        ),
                      ),
                      errorWidget: (context, url, error) => _ImageFallback(),
                    )
                        : _ImageFallback(),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: SizeConfig.screenHeight * 0.1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content section
              Padding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      widget.name.isNotEmpty ? widget.name : '—',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.05,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.01),

                    // Designation
                    if (widget.designation.trim().isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.008),
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.screenWidth * 0.03,
                            vertical: SizeConfig.screenHeight * 0.008),
                        decoration: BoxDecoration(
                          color: _ExecutivePanelPageState.brandStart
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                        ),
                        child: Text(
                          widget.designation,
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            color: _ExecutivePanelPageState.brandStart,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                    // Department
                    if (widget.department.trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: SizeConfig.screenHeight * 0.005,
                          bottom: SizeConfig.screenHeight * 0.005,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: SizeConfig.screenWidth * 0.04,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: SizeConfig.screenWidth * 0.015),
                            Expanded(
                              child: Text(
                                widget.department,
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.035,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: SizeConfig.screenHeight * 0.007),
                    Divider(color: Colors.grey.shade200, height: 1),
                    SizedBox(height: SizeConfig.screenHeight * 0.02),

                    // Contact links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIconButton(
                          imagePath: 'assets/images/mail.png',
                          onTap: () => _mailto(widget.email),
                        ),
                        SizedBox(width: SizeConfig.screenWidth * 0.06),
                        _SocialIconButton(
                          imagePath: 'assets/images/facebook.png',
                          onTap: () => _launch(widget.facebook, 'Facebook'),
                        ),
                        SizedBox(width: SizeConfig.screenWidth * 0.06),
                        _SocialIconButton(
                          imagePath: 'assets/images/linkedin.png',
                          onTap: () => _launch(widget.linkedIn, 'LinkedIn'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        child: Container(
          width: SizeConfig.screenWidth * 0.12,
          height: SizeConfig.screenWidth * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.15 : 0.1),
                blurRadius: _isPressed ? 8 : 12,
                spreadRadius: _isPressed ? 0 : 2,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _ExecutivePanelPageState.brandStart.withOpacity(0.1),
            _ExecutivePanelPageState.brandEnd.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: SizeConfig.screenWidth * 0.16,
            color: _ExecutivePanelPageState.brandStart.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: SizeConfig.screenWidth * 0.16,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.025),
            Text(
              'Could not load the executive panel.',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.045,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.035,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.06),
              decoration: BoxDecoration(
                color: _ExecutivePanelPageState.brandStart.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: _ExecutivePanelPageState.brandStart,
                size: SizeConfig.screenWidth * 0.16,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.025),
            Text(
              'No profiles found',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.045,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Text(
              'No executive panel members for this semester yet.',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.035,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
