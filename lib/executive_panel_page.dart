import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExecutivePanelPage extends StatelessWidget {
  final String semesterId;

  const ExecutivePanelPage({
    Key? key,
    required this.semesterId,
  }) : super(key: key);

  static const Color brandStart = Color(0xFF0B6B3A);
  static const Color brandEnd = Color(0xFF16A34A);
  static const Color bgGradientStart = Color(0xFFE8F5E9);
  static const Color bgGradientEnd = Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Governing_Panel')
        .collection('Semesters')
        .doc(semesterId)
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
              _Header(semesterId: semesterId),
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
                              valueColor: AlwaysStoppedAnimation<Color>(brandStart),
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
                        final designation = (data['Designation'] ?? '').toString();
                        final department = (data['Department'] ?? '').toString();
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
  const _Header({required this.semesterId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ExecutivePanelPage.brandStart, ExecutivePanelPage.brandEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: ExecutivePanelPage.brandStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Executive Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    semesterId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
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

class _ProfileCardState extends State<_ProfileCard> with SingleTickerProviderStateMixin {
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
              color: ExecutivePanelPage.brandStart.withOpacity(0.08),
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
                color: ExecutivePanelPage.brandStart.withOpacity(0.05),
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
                        ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ExecutivePanelPage.brandStart),
                            strokeWidth: 2.5,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _ImageFallback(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ExecutivePanelPage.brandStart.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.designation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ExecutivePanelPage.brandStart,
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
                            color: ExecutivePanelPage.brandStart,
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
            ExecutivePanelPage.brandStart.withOpacity(0.1),
            ExecutivePanelPage.brandEnd.withOpacity(0.05),
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
            color: ExecutivePanelPage.brandStart.withOpacity(0.6),
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
                color: ExecutivePanelPage.brandStart.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: ExecutivePanelPage.brandStart,
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