import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================
/// AUST RC BRAND COLORS
/// ============================================
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kGreenDeep = Color(0xFF0F3D2E);
const kGreenAccent = Color(0xFF1A5C43);
const kGreenLight = Color(0xFFB8E6D5);
const kOnPrimary = Colors.white;

/// ============================================
/// SOCIAL MEDIA LINKS
/// ============================================
class SocialLinks {
  static const String facebook = 'https://www.facebook.com/AustRoboticsClub';
  static const String instagram = 'https://www.instagram.com/aust_robotics_club/';
  static const String linkedin = 'https://www.linkedin.com/company/aust-robotics-club/';
}

/// ============================================
/// DEVELOPER INFO CLASS
/// ============================================
class DeveloperInfo {
  final String name;
  final String role;
  final String department;
  final String imagePath;
  final String? githubUrl;
  final String? facebookUrl;

  const DeveloperInfo({
    required this.name,
    required this.role,
    required this.department,
    required this.imagePath,
    this.githubUrl,
    this.facebookUrl,
  });
}

/// ============================================
/// APPRECIATION MESSAGE CLASS
/// ============================================
class AppreciationMessage {
  final String name;
  final String position;
  final String imagePath;
  final String message;

  const AppreciationMessage({
    required this.name,
    required this.position,
    required this.imagePath,
    required this.message,
  });
}

/// ============================================
/// COMPACT FOOTER WIDGET
/// ============================================
class FooterPage extends StatelessWidget {
  const FooterPage({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open link'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('$feature - Coming Soon!'),
          ],
        ),
        backgroundColor: kGreenAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCreditsPage(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeveloperCreditsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A2E1F),
            Color(0xFF0F3D2E),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),

          // ======== LOGO & CLUB NAME ========
          _CompactHeader(),

          const SizedBox(height: 20),

          // ======== QUICK LINKS ========
          _QuickLinksRow(
            onContactTap: () => _showComingSoon(context, 'Contact Us'),
            onFaqTap: () => _showComingSoon(context, 'FAQ'),
            onPolicyTap: () => _showComingSoon(context, 'Policies & Privacy'),
          ),

          const SizedBox(height: 20),

          // ======== SOCIAL MEDIA ========
          _CompactSocialRow(
            onTap: (url) => _launchUrl(context, url),
          ),

          const SizedBox(height: 16),

          // ======== DIVIDER ========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  kGreenMain.withOpacity(0.4),
                  kGreenLight.withOpacity(0.6),
                  kGreenMain.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ======== DEVELOPERS SECTION ========
          _DevelopersSection(
            onInfoTap: () => _navigateToCreditsPage(context),
          ),

          const SizedBox(height: 12),

          // ======== COPYRIGHT ========
          _CompactCopyright(year: currentYear),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ============================================
/// COMPACT HEADER
/// ============================================
class _CompactHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo2.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.smart_toy_rounded,
                size: 28,
                color: kGreenDark,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Club name & tagline
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, kGreenLight],
              ).createShader(bounds),
              child: const Text(
                'AUST ROBOTICS CLUB',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '🤖 Building a Safer Future',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================
/// QUICK LINKS ROW
/// ============================================
class _QuickLinksRow extends StatelessWidget {
  final VoidCallback onContactTap;
  final VoidCallback onFaqTap;
  final VoidCallback onPolicyTap;

  const _QuickLinksRow({
    required this.onContactTap,
    required this.onFaqTap,
    required this.onPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterLinkButton(
            icon: Icons.mail_outline_rounded,
            label: 'Contact Us',
            onTap: onContactTap,
          ),
          _VerticalDivider(),
          _FooterLinkButton(
            icon: Icons.help_outline_rounded,
            label: 'FAQ',
            onTap: onFaqTap,
          ),
          _VerticalDivider(),
          _FooterLinkButton(
            icon: Icons.privacy_tip_outlined,
            label: 'Policies & Privacy',
            onTap: onPolicyTap,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withOpacity(0.15),
    );
  }
}

class _FooterLinkButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_FooterLinkButton> createState() => _FooterLinkButtonState();
}

class _FooterLinkButtonState extends State<_FooterLinkButton> {
  bool _isPressed = false;

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: _isPressed ? kGreenLight : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isPressed ? kGreenLight : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// COMPACT SOCIAL MEDIA ROW WITH IMAGES
/// ============================================
class _CompactSocialRow extends StatelessWidget {
  final Function(String) onTap;

  const _CompactSocialRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CompactSocialButton(
          imagePath: 'assets/images/facebook.png',
          fallbackIcon: Icons.facebook_rounded,
          color: const Color(0xFF1877F2),
          url: SocialLinks.facebook,
          onTap: onTap,
        ),
        const SizedBox(width: 16),
        _CompactSocialButton(
          imagePath: 'assets/images/instagram.png',
          fallbackIcon: Icons.camera_alt_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
          ),
          url: SocialLinks.instagram,
          onTap: onTap,
        ),
        const SizedBox(width: 16),
        _CompactSocialButton(
          imagePath: 'assets/images/linkedin.png',
          fallbackIcon: Icons.business_center_rounded,
          color: const Color(0xFF0A66C2),
          url: SocialLinks.linkedin,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _CompactSocialButton extends StatefulWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final Color? color;
  final Gradient? gradient;
  final String url;
  final Function(String) onTap;

  const _CompactSocialButton({
    required this.imagePath,
    required this.fallbackIcon,
    this.color,
    this.gradient,
    required this.url,
    required this.onTap,
  });

  @override
  State<_CompactSocialButton> createState() => _CompactSocialButtonState();
}

class _CompactSocialButtonState extends State<_CompactSocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onTap(widget.url);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        decoration: BoxDecoration(
          gradient: widget.gradient ??
              LinearGradient(
                colors: [widget.color!, widget.color!.withOpacity(0.8)],
              ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (widget.color ?? Colors.purple).withOpacity(0.4),
              blurRadius: _isPressed ? 8 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.contain,
              color: Colors.white,
              errorBuilder: (_, __, ___) => Icon(
                widget.fallbackIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// DEVELOPERS SECTION (MODIFIED)
/// ============================================
class _DevelopersSection extends StatelessWidget {
  final VoidCallback onInfoTap;

  const _DevelopersSection({required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kGreenMain.withOpacity(0.15),
            kGreenDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kGreenMain.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Developed by"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.code_rounded,
                size: 16,
                color: kGreenLight.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Developed by',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kGreenLight.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // AUST Robotics Club + info button on the same row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AUST Robotics Club',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              // i button just beside the club name
              _InfoButton(onTap: onInfoTap),
            ],
          ),

          const SizedBox(height: 2),

          // Subtitle
          Text(
            'Web Development Team',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}


class _InfoButton extends StatefulWidget {
  final VoidCallback onTap;

  const _InfoButton({required this.onTap});

  @override
  State<_InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<_InfoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.9 : _scaleAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kGreenMain,
                    kGreenDark,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kGreenMain.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: kGreenLight.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ============================================
/// COMPACT COPYRIGHT
/// ============================================
class _CompactCopyright extends StatelessWidget {
  final int year;

  const _CompactCopyright({required this.year});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Made with love
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Made for',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            Text(
              ' AUST Robotics Club',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Copyright & University
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/AUST.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school,
                    size: 12,
                    color: kGreenDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '© $year AUST RC • AUST, Dhaka',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.35),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================
/// DEVELOPER CREDITS PAGE
/// ============================================
class DeveloperCreditsPage extends StatefulWidget {
  const DeveloperCreditsPage({super.key});

  @override
  State<DeveloperCreditsPage> createState() => _DeveloperCreditsPageState();
}

class _DeveloperCreditsPageState extends State<DeveloperCreditsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Developer Information
  final List<DeveloperInfo> developers = const [
    DeveloperInfo(
      name: 'Shajedul Kabir Rafi',
      role: 'Head Developer',
      department: 'Computer Science & Engineering',
      imagePath: 'assets/images/Head Developer.jfif',
      githubUrl: 'https://github.com/Rafi12234',
      facebookUrl: 'https://www.facebook.com/shajidul.kabir.5/',
    ),
    DeveloperInfo(
      name: 'Samanta Islam',
      role: 'Co-Developer',
      department: 'Computer Science & Engineering',
      imagePath: 'assets/images/Co Developer.jpg',
      githubUrl: 'https://github.com/Samanta503',
      facebookUrl: 'https://www.facebook.com/samanta.islam.750331',
    ),
  ];

  // Appreciation Messages
  final List<AppreciationMessage> appreciations = const [
    AppreciationMessage(
      name: 'Director',
      position: 'Director, AUST Robotics Club',
      imagePath: 'assets/images/Director.jpg',
      message:
      'On behalf of the AUST Robotics Club, I extend my heartfelt appreciation to our talented developers for successfully creating the official mobile application of ARC. This achievement reflects your dedication, creativity, and commitment to delivering a platform that strengthens communication and enhances the club experience for all members. Your hard work has turned a long-standing vision into reality, and we are immensely proud of the professionalism and passion you showed throughout the development journey. Thank you for your remarkable contribution and for setting a new benchmark for digital innovation within our club.',
    ),
    AppreciationMessage(
      name: 'Assistant Director',
      position: 'Assistant Director, AUST Robotics Club',
      imagePath: 'assets/images/Assistant Director.jpeg',
      message:
      'Congratulations to the developers behind the new ARC mobile app for achieving a milestone that will benefit our entire community. Your collaborative spirit, consistent effort, and problem-solving mindset have resulted in a polished and user-friendly application that truly represents the identity of AUST Robotics Club. This project showcases not only your technical expertise but also your dedication to helping the club grow digitally. We deeply appreciate your initiative and the countless hours you invested. Thank you for raising the standard of what we can accomplish together.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open link'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2E1F),
              Color(0xFF0F3D2E),
              Color(0xFF0B6B3A),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 120,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, kGreenLight],
                      ).createShader(bounds),
                      child: const Text(
                        'Development Team',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            kGreenDark.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeaderSection(),

                        const SizedBox(height: 30),

                        // Developers Section
                        _buildSectionTitle(
                          icon: Icons.code_rounded,
                          title: 'Meet Our Developers',
                        ),

                        const SizedBox(height: 16),

                        // Developer Cards
                        ...developers.map((dev) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _DeveloperCard(
                            developer: dev,
                            onSocialTap: _launchUrl,
                          ),
                        )),

                        const SizedBox(height: 30),

                        // Appreciation Section
                        _buildSectionTitle(
                          icon: Icons.favorite_rounded,
                          title: 'Words of Appreciation',
                        ),

                        const SizedBox(height: 16),

                        // Appreciation Cards
                        ...appreciations.map((appreciation) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AppreciationCard(appreciation: appreciation),
                        )),

                        const SizedBox(height: 30),

                        // Bottom Thank You
                        _buildThankYouSection(),

                        const SizedBox(height: 20),
                      ],
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

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kGreenMain.withOpacity(0.2),
            kGreenDark.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kGreenMain.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Club Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo2.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy_rounded,
                  size: 50,
                  color: kGreenDark,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, kGreenLight],
            ).createShader(bounds),
            child: const Text(
              'AUST ROBOTICS CLUB',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Web Development Team',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kGreenLight.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kGreenMain.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🚀 Building the Future of ARC',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kGreenMain, kGreenDark],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildThankYouSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kGreenMain.withOpacity(0.15),
            kGreenDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kGreenLight.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '💚',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for using the ARC App!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Built with passion and dedication',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// DEVELOPER CARD WIDGET
/// ============================================
class _DeveloperCard extends StatefulWidget {
  final DeveloperInfo developer;
  final Function(String) onSocialTap;

  const _DeveloperCard({
    required this.developer,
    required this.onSocialTap,
  });

  @override
  State<_DeveloperCard> createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<_DeveloperCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isLead = widget.developer.role == 'Head Developer';

    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLead
                ? [
              const Color(0xFF1A5C43).withOpacity(0.9),
              kGreenDark.withOpacity(0.8),
            ]
                : [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLead
                ? kGreenMain.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isLead ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isLead
                  ? kGreenMain.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Image
                Hero(
                  tag: 'dev_${widget.developer.name}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLead ? kGreenMain : Colors.white.withOpacity(0.2),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isLead
                              ? kGreenMain.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        widget.developer.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: kGreenAccent,
                          child: Icon(
                            Icons.person_rounded,
                            size: 35,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: isLead
                              ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          )
                              : LinearGradient(
                            colors: [
                              kGreenMain.withOpacity(0.3),
                              kGreenDark.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLead ? Icons.star_rounded : Icons.code_rounded,
                              size: 12,
                              color: isLead ? Colors.black87 : kGreenLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.developer.role,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isLead ? Colors.black87 : kGreenLight,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Name
                      Text(
                        widget.developer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Department
                      Text(
                        widget.developer.department,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Expand Icon
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Expanded Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Social Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.developer.githubUrl != null)
                          _SocialLinkButton(
                            icon: 'assets/images/github.png',
                            fallbackIcon: Icons.code_rounded,
                            label: 'GitHub',
                            color: const Color(0xFF333333),
                            onTap: () =>
                                widget.onSocialTap(widget.developer.githubUrl!),
                          ),
                        if (widget.developer.githubUrl != null &&
                            widget.developer.facebookUrl != null)
                          const SizedBox(width: 16),
                        if (widget.developer.facebookUrl != null)
                          _SocialLinkButton(
                            icon: 'assets/images/facebook.png',
                            fallbackIcon: Icons.facebook_rounded,
                            label: 'Facebook',
                            color: const Color(0xFF1877F2),
                            onTap: () =>
                                widget.onSocialTap(widget.developer.facebookUrl!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLinkButton extends StatefulWidget {
  final String icon;
  final IconData fallbackIcon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialLinkButton({
    required this.icon,
    required this.fallbackIcon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SocialLinkButton> createState() => _SocialLinkButtonState();
}

class _SocialLinkButtonState extends State<_SocialLinkButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: _isPressed ? 4 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              widget.icon,
              width: 18,
              height: 18,
              color: Colors.white,
              errorBuilder: (_, __, ___) => Icon(
                widget.fallbackIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// APPRECIATION CARD WIDGET
/// ============================================
class _AppreciationCard extends StatefulWidget {
  final AppreciationMessage appreciation;

  const _AppreciationCard({required this.appreciation});

  @override
  State<_AppreciationCard> createState() => _AppreciationCardState();
}

class _AppreciationCardState extends State<_AppreciationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D1B4E).withOpacity(0.6),
              const Color(0xFF1A1A2E).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.purple.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.appreciation.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.purple.withOpacity(0.3),
                        child: Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.4),
                              Colors.purple.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: Colors.purple[200],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.appreciation.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.purple[200],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.appreciation.position,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quote Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.format_quote_rounded,
                    color: Colors.purple[200],
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Message
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  Text(
                    widget.appreciation.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tap to read more',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple[200],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Colors.purple[200],
                      ),
                    ],
                  ),
                ],
              ),
              secondChild: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      widget.appreciation.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.7,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tap to collapse',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple[200],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 16,
                        color: Colors.purple[200],
                      ),
                    ],
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}