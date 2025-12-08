import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
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
      height: 140 + topInset,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF064E3B),
            Color(0xFF0B6B3A),
            Color(0xFF16A34A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Header Pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
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
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Back Button
                    _AnimatedBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),

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
                            child: const Text(
                              'Executive Panel',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
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
                                fontSize: 14,
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15 + animation.value * 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3 + animation.value * 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1 * animation.value),
                blurRadius: 15 * animation.value,
                spreadRadius: 3 * animation.value,
              ),
            ],
          ),
          child: const Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: 24,
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

  Future<void> _launch(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;

    // Ensure URL has a scheme
    String finalUrl = u;
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      finalUrl = 'https://$u';
    }

    final uri = Uri.tryParse(finalUrl);
    if (uri == null) return;

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Future<void> _mailto(String address) async {
    final a = address.trim();
    if (a.isEmpty) return;

    // Create Gmail compose URL that opens in browser
    final gmailUrl = Uri.parse('https://mail.google.com/mail/?view=cm&to=$a');

    try {
      if (await canLaunchUrl(gmailUrl)) {
        await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _ExecutivePanelPageState.brandStart.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                spreadRadius: 0,
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                blurRadius: 8,
                spreadRadius: -4,
                color: _ExecutivePanelPageState.brandStart.withOpacity(0.05),
                offset: const Offset(0, 4),
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
                          strokeWidth: 2.5,
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
                      height: 80,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      widget.name.isNotEmpty ? widget.name : '—',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Designation
                    if (widget.designation.trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _ExecutivePanelPageState.brandStart
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.designation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ExecutivePanelPageState.brandStart,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                    // Department
                    if (widget.department.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.department,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 16),

                    // Contact links
                    Column(
                      children: [
                        if (widget.email.trim().isNotEmpty)
                          _SocialButton(
                            icon: Icons.email_outlined,
                            label: widget.email,
                            color: _ExecutivePanelPageState.brandStart,
                            onTap: () => _mailto(widget.email),
                          ),
                        if (widget.facebook.trim().isNotEmpty)
                          _SocialButton(
                            icon: Icons.facebook_rounded,
                            label: 'Facebook Profile',
                            color: const Color(0xFF1877F2),
                            onTap: () => _launch(widget.facebook),
                          ),
                        if (widget.linkedIn.trim().isNotEmpty)
                          _SocialButton(
                            icon: Icons.work_outline_rounded,
                            label: 'LinkedIn Profile',
                            color: const Color(0xFF0A66C2),
                            onTap: () => _launch(widget.linkedIn),
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

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isPressed
                  ? widget.color.withOpacity(0.12)
                  : widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withOpacity(_isPressed ? 0.3 : 0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: widget.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: widget.color.withOpacity(0.7),
                ),
              ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 64,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Could not load the executive panel.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(
                fontSize: 14,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _ExecutivePanelPageState.brandStart.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: _ExecutivePanelPageState.brandStart,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No profiles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No executive panel members for this semester yet.',
              style: TextStyle(
                fontSize: 14,
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