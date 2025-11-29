import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'FAQ_page.dart';

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
  static const String instagram =
      'https://www.instagram.com/aust_robotics_club/';
  static const String linkedin =
      'https://www.linkedin.com/company/aust-robotics-club/';
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
  final String semester;

  const AppreciationMessage({
    required this.name,
    required this.position,
    required this.imagePath,
    required this.message,
    required this.semester,
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
            const Icon(Icons.construction_rounded,
                color: Colors.white, size: 18),
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
  void _navigateToFAQPage(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FAQFeedbackPage(),
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
            onFaqTap: () => _navigateToFAQPage(context),
            onPolicyTap: () => _showComingSoon(context, 'Policies & Privacy'),
          ),

          const SizedBox(height: 20),

          // ======== SOCIAL MEDIA - SIMPLE ICONS ========
          _SimpleSocialRow(
            onFacebookTap: () => _launchUrl(context, SocialLinks.facebook),
            onInstagramTap: () => _launchUrl(context, SocialLinks.instagram),
            onLinkedInTap: () => _launchUrl(context, SocialLinks.linkedin),
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
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo2.png',
              width: 46,
              height: 46,
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
          color:
          _isPressed ? Colors.white.withOpacity(0.1) : Colors.transparent,
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
/// SIMPLE SOCIAL MEDIA ROW - JUST ICONS
/// ============================================
class _SimpleSocialRow extends StatelessWidget {
  final VoidCallback onFacebookTap;
  final VoidCallback onInstagramTap;
  final VoidCallback onLinkedInTap;

  const _SimpleSocialRow({
    required this.onFacebookTap,
    required this.onInstagramTap,
    required this.onLinkedInTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook
        _SimpleSocialIcon(
          imagePath: 'assets/images/facebook.png',
          onTap: onFacebookTap,
        ),
        const SizedBox(width: 32),
        // Instagram
        _SimpleSocialIcon(
          imagePath: 'assets/images/instagram.png',
          onTap: onInstagramTap,
        ),
        const SizedBox(width: 32),
        // LinkedIn
        _SimpleSocialIcon(
          imagePath: 'assets/images/linkedin.png',
          onTap: onLinkedInTap,
        ),
      ],
    );
  }
}

/// ============================================
/// SIMPLE SOCIAL ICON - NO BACKGROUND/BORDER
/// ============================================
class _SimpleSocialIcon extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _SimpleSocialIcon({
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_SimpleSocialIcon> createState() => _SimpleSocialIconState();
}

class _SimpleSocialIconState extends State<_SimpleSocialIcon> {
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
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Image.asset(
            widget.imagePath,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.link,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// DEVELOPERS SECTION
/// ============================================
class _DevelopersSection extends StatelessWidget {
  final VoidCallback onInfoTap;

  const _DevelopersSection({required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.code_rounded,
                size: 16,
                color: kGreenLight.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Developed by',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kGreenLight.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'AUST Robotics Club',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Web Development Team',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onInfoTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kGreenMain, kGreenDark],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: kGreenMain.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Meet the Developers',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
/// DEVELOPER CREDITS PAGE - LIGHT THEME
/// ============================================
class DeveloperCreditsPage extends StatelessWidget {
  const DeveloperCreditsPage({super.key});

  static const List<DeveloperInfo> developers = [
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

  static const List<AppreciationMessage> appreciations = [
    AppreciationMessage(
      name: 'Ahnaf Amer',
      position: 'Director',
      imagePath: 'assets/images/Director.jpg',
      semester: 'Fall 2024',
      message:
      'On behalf of the AUST Robotics Club, I extend my heartfelt appreciation to our talented developers for successfully creating the official mobile application of ARC. This achievement reflects your dedication, creativity, and commitment to delivering a platform that strengthens communication and enhances the club experience for all members. Your hard work has turned a long-standing vision into reality, and we are immensely proud of the professionalism and passion you showed throughout the development journey. Thank you for your remarkable contribution and for setting a new benchmark for digital innovation within our club.',
    ),
    AppreciationMessage(
      name: 'Saobia Tinni',
      position: 'Assistant Director',
      imagePath: 'assets/images/Assistant Director.jpeg',
      semester: 'Fall 2024',
      message:
      'Congratulations to the developers behind the new ARC mobile app for achieving a milestone that will benefit our entire community. Your collaborative spirit, consistent effort, and problem-solving mindset have resulted in a polished and user-friendly application that truly represents the identity of AUST Robotics Club. This project showcases not only your technical expertise but also your dedication to helping the club grow digitally. We deeply appreciate your initiative and the countless hours you invested. Thank you for raising the standard of what we can accomplish together.',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kGreenMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: kGreenDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Development Team',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kGreenDark,
                      ),
                    ),
                  ),
                  // Club Logo
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: kGreenMain.withOpacity(0.2),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo2.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.smart_toy_rounded,
                        size: 24,
                        color: kGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [kGreenMain, kGreenDark],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kGreenMain.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.code_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'AUST Robotics Club',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Web Development Team',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Developers Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kGreenMain.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              color: kGreenMain,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Our Developers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Developer Cards
                    ...developers.map((dev) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: _DeveloperCardLight(
                        developer: dev,
                        onGithubTap: () =>
                            _launchUrl(context, dev.githubUrl!),
                        onFacebookTap: () =>
                            _launchUrl(context, dev.facebookUrl!),
                      ),
                    )),

                    const SizedBox(height: 32),

                    // Appreciation Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Words of Appreciation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Directors Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: appreciations
                            .map((appreciation) => Expanded(
                          child: _DirectorAvatar(
                            appreciation: appreciation,
                          ),
                        ))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Appreciation Messages
                    ...appreciations.map((appreciation) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: _AppreciationCardLight(
                        appreciation: appreciation,
                      ),
                    )),

                    const SizedBox(height: 32),

                    // Thank You Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kGreenMain.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kGreenMain.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '💚',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Thank you for using the AUST Robotics Club Official Mobile App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: kGreenDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Built with passion and dedication',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// DEVELOPER CARD - LIGHT THEME
/// ============================================
class _DeveloperCardLight extends StatelessWidget {
  final DeveloperInfo developer;
  final VoidCallback onGithubTap;
  final VoidCallback onFacebookTap;

  const _DeveloperCardLight({
    required this.developer,
    required this.onGithubTap,
    required this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLead = developer.role == 'Head Developer';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLead
              ? kGreenMain.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
          width: isLead ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLead
                ? kGreenMain.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image - Larger
          Container(
            width: isLead ? 120 : 100,
            height: isLead ? 120 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLead ? kGreenMain : kGreenMain.withOpacity(0.5),
                width: isLead ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                developer.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kGreenMain.withOpacity(0.1),
                  child: Icon(
                    Icons.person_rounded,
                    size: isLead ? 60 : 50,
                    color: kGreenMain.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: isLead
                  ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              )
                  : LinearGradient(
                colors: [
                  kGreenMain.withOpacity(0.15),
                  kGreenMain.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLead ? Icons.star_rounded : Icons.code_rounded,
                  size: 14,
                  color: isLead ? Colors.black87 : kGreenMain,
                ),
                const SizedBox(width: 6),
                Text(
                  developer.role,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLead ? Colors.black87 : kGreenMain,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            developer.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 4),

          // Department
          Text(
            developer.department,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Social Links - Just Icons (No Background)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GitHub
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onGithubTap();
                },
                child: Image.asset(
                  'assets/images/github.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.code_rounded,
                    size: 36,
                    color: Color(0xFF333333),
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // Facebook
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onFacebookTap();
                },
                child: Image.asset(
                  'assets/images/facebook.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.facebook_rounded,
                    size: 36,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// DIRECTOR AVATAR - SMALL ROUND
/// ============================================
class _DirectorAvatar extends StatelessWidget {
  final AppreciationMessage appreciation;

  const _DirectorAvatar({required this.appreciation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Small Round Image
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              appreciation.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.amber.withOpacity(0.1),
                child: Icon(
                  Icons.person_rounded,
                  size: 35,
                  color: Colors.amber.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Name
        Text(
          appreciation.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 2),

        // Position
        Text(
          appreciation.position,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 2),

        // Semester
        Text(
          '(${appreciation.semester})',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

/// ============================================
/// APPRECIATION CARD - LIGHT THEME
/// ============================================
class _AppreciationCardLight extends StatefulWidget {
  final AppreciationMessage appreciation;

  const _AppreciationCardLight({required this.appreciation});

  @override
  State<_AppreciationCardLight> createState() => _AppreciationCardLightState();
}

class _AppreciationCardLightState extends State<_AppreciationCardLight> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Small Avatar
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.appreciation.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.amber.withOpacity(0.1),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 25,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Name & Position
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appreciation.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.appreciation.position,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            ' (${widget.appreciation.semester})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Expand Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quote Icon
            Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: Colors.amber.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Message
            AnimatedCrossFade(
              firstChild: Text(
                widget.appreciation.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
              secondChild: Text(
                widget.appreciation.message,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),

            const SizedBox(height: 8),

            // Tap to expand/collapse hint
            Center(
              child: Text(
                _isExpanded ? 'Tap to collapse' : 'Tap to read more',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}