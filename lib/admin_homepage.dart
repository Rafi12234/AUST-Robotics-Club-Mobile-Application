import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'admin_event_management_page.dart';
import 'Admin_Educational_Programs_Management_Page.dart';
import 'admin_research_projects_management_page.dart';
import 'admin_proposal_approval_page.dart';
import 'admin_achievement_management_page.dart';
import 'admin_member_id_management_page.dart';
import 'admin_governing_panel_page.dart';
import 'Admin_Membership_Management_Page.dart';
import 'Admin_Best_Panel_Members_Page.dart';
import 'Admin_Sponsor_Colab_Club_Management_Page.dart';
import 'Admin_Voice_of_AUSTRC_Page.dart';
import 'Admin_FAQ_Management_Page.dart';
import 'admin_governing_panel_page.dart';

// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentPurple = Color(0xFF8B5CF6);
const kAccentRed = Color(0xFFEF4444);
const kAccentBlue = Color(0xFF3B82F6);
const kAccentPink = Color(0xFFEC4899);
const kAccentTeal = Color(0xFF14B8A6);
const kAccentOrange = Color(0xFFFF6B35);
const kAccentIndigo = Color(0xFF6366F1);

// Card Configuration Model
class AdminCardConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final Widget destinationPage;

  const AdminCardConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    required this.destinationPage,
  });
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  // All admin cards configuration
  final List<AdminCardConfig> _adminCards = [
    AdminCardConfig(
      title: 'Events',
      subtitle: 'Manage all events',
      icon: Icons.event_rounded,
      gradientColors: [Color(0xFF1E3A5F), Color(0xFF2E5A88), Color(0xFF3B7CB8)],
      accentColor: kAccentBlue,
      destinationPage: const AdminEventPage(),
    ),
    AdminCardConfig(
      title: 'Research & Projects',
      subtitle: 'Research management',
      icon: Icons.science_rounded,
      gradientColors: [Color(0xFF4A1D6A), Color(0xFF6B2D8A), Color(0xFF8B3DAA)],
      accentColor: kAccentPurple,
      destinationPage: const AdminResearchProjectsPage(),
    ),
    AdminCardConfig(
      title: 'Educational Programs',
      subtitle: 'Training & mentorship',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF0D4D4D), Color(0xFF0F6B6B), Color(0xFF14B8A6)],
      accentColor: kAccentTeal,
      destinationPage: const AdminEducationalProgramsPage(),
    ),
    AdminCardConfig(
      title: 'Governing Panel',
      subtitle: 'Panel member management',
      icon: Icons.account_balance_rounded,
      gradientColors: [Color(0xFF306041), Color(0xFF49AC59), Color(0xFFA78BFA)],
      accentColor: kAccentPurple,
      destinationPage: const AdminGoverningPanelPage(),
    ),
    AdminCardConfig(
      title: 'Member IDs',
      subtitle: 'ID card management',
      icon: Icons.badge_rounded,
      gradientColors: [Color(0xFF7C2D12), Color(0xFFB45309), Color(0xFFD97706)],
      accentColor: kAccentOrange,
      destinationPage: const AdminMemberIdManagementPage(),
    ),
    AdminCardConfig(
      title: 'Proposal Approvals',
      subtitle: 'Review submissions',
      icon: Icons.approval_rounded,
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF3B5998), Color(0xFF4F7CAC)],
      accentColor: kAccentIndigo,
      destinationPage: const AdminProposalApprovalPage(),
    ),
    AdminCardConfig(
      title: 'Achievements',
      subtitle: 'Awards & recognition',
      icon: Icons.emoji_events_rounded,
      gradientColors: [Color(0xFF7C4700), Color(0xFFB8860B), Color(0xFFDAA520)],
      accentColor: kAccentGold,
      destinationPage: const AdminAchievementPage(),
    ),
    AdminCardConfig(
      title: 'Membership',
      subtitle: 'Member management',
      icon: Icons.group_add_rounded,
      gradientColors: [Color(0xFF701A75), Color(0xFFA21CAF), Color(0xFFD946EF)],
      accentColor: kAccentPink,
      destinationPage: const AdminMembershipManagementPage(),
    ),
    AdminCardConfig(
      title: 'Best Panel Members',
      subtitle: 'Top performers',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
      accentColor: kGreenLight,
      destinationPage: const AdminBestPanelMembersPage(),
    ),
  AdminCardConfig(
  title: 'Sponsor & Collaborated Club',
  subtitle: 'Manage sponsors & collaborators',
  icon: Icons.stars_rounded,
  gradientColors: const [
  Color(0xFF0F766E), // deep teal (anchor for contrast with white text)
  Color(0xFF0EA5E9), // bright cyan accent
  Color(0xFF6EE7B7), // soft mint highlight
  ],
  accentColor: kGreenLight, // can stay as is, still harmonizes with last stop
  destinationPage: const AdminSponsorsCollaboratorsPage(),
  ),
    AdminCardConfig(
      title: 'Voice of AUSTRC',
      subtitle: 'Feedback & suggestions',
      icon: Icons.record_voice_over_rounded,
      gradientColors: [Color(0xFF581C87), Color(0xFF7E22CE), Color(0xFFA78BFA)],
      accentColor: kAccentPurple,
      destinationPage: const AdminVoiceOfAUSTRCPage(),
    ),
    AdminCardConfig(
      title: 'FAQ Management',
      subtitle: 'Manage FAQs',
      icon: Icons.question_answer_rounded,
      gradientColors: [Color(0xFF854D0E), Color(0xFFD97706), Color(0xFFFFA500)],
      accentColor: kAccentOrange,
      destinationPage: const AdminFeedbackPage(),
    ),


  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _WelcomeCard(
                fadeAnimation: _headerFadeAnimation,
                slideAnimation: _headerSlideAnimation,
                pulseController: _pulseController,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildDashboardContent(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: kGreenDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGreenDark, kGreenMain, kGreenLight],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
          title: FadeTransition(
            opacity: _headerFadeAnimation,
            child: const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          background: Stack(
            children: List.generate(12, (index) {
              return Positioned(
                left: (index * 80.0) % MediaQuery.of(context).size.width,
                top: (index * 25.0) % 120,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.08 * (1 - _pulseController.value * 0.3),
                      child: Transform.rotate(
                        angle: _pulseController.value * 0.1,
                        child: Icon(
                          Icons.hexagon_outlined,
                          size: 24 + (index % 3) * 12,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Section Header
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 20),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kGreenMain, kGreenLight],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Management Tools',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: kGreenDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGreenLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.apps_rounded, size: 16, color: kGreenMain),
                      const SizedBox(width: 6),
                      Text(
                        '${_adminCards.length + 1} Tools',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kGreenMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cards Grid - 2 per row
        ...List.generate(
          (_adminCards.length / 2).ceil(),
              (rowIndex) {
            final startIndex = rowIndex * 2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _AdminCard(
                      config: _adminCards[startIndex],
                      index: startIndex,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: startIndex + 1 < _adminCards.length
                        ? _AdminCard(
                      config: _adminCards[startIndex + 1],
                      index: startIndex + 1,
                    )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Governing Panel Special Card
        // _GoverningPanelCard(index: _adminCards.length),
      ],
    );
  }
}

// ============================================
// WELCOME CARD
// ============================================
class _WelcomeCard extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final AnimationController pulseController;

  const _WelcomeCard({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kGreenDark, kGreenMain, kGreenLight],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Transform.rotate(
                          angle: (1 - value) * math.pi * 2,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Admin Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kAccentGold.withOpacity(0.5 * pulseController.value),
                            width: 3,
                          ),
                        ),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: kAccentGold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kAccentGold.withOpacity(0.6 * pulseController.value),
                                blurRadius: 12 * pulseController.value,
                                spreadRadius: 4 * pulseController.value,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: kAccentGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Manage all aspects of your organization from this central hub',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

// ============================================
// ADMIN CARD - REDESIGNED
// ============================================
class _AdminCard extends StatefulWidget {
  final AdminCardConfig config;
  final int index;

  const _AdminCard({
    required this.config,
    required this.index,
  });

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _hoverController;
  late AnimationController _shimmerController;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    Future.delayed(Duration(milliseconds: 150 + (widget.index * 80)), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _hoverController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _navigateToPage() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        widget.config.destinationPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        final slideValue = Curves.easeOutCubic.transform(_entryController.value);
        final scaleValue = Curves.elasticOut.transform(
          (_entryController.value).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - slideValue)),
          child: Transform.scale(
            scale: 0.8 + (0.2 * scaleValue),
            child: Opacity(
              opacity: _entryController.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _navigateToPage();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0)),
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.config.gradientColors[1].withOpacity(
                      _isHovered ? 0.45 : 0.3,
                    ),
                    blurRadius: _isHovered ? 28 : 20,
                    offset: Offset(0, _isHovered ? 14 : 10),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Gradient Background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.config.gradientColors,
                        ),
                      ),
                    ),

                    // Shimmer Effect
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Positioned(
                          left: -100 + (_shimmerController.value * 300),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Decorative Elements
                    Positioned(
                      right: -25,
                      top: -25,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 15,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon Container
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  widget.config.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              // Arrow
                              AnimatedBuilder(
                                animation: _hoverController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_hoverController.value * 4, 0),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Title
                          Text(
                            widget.config.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Subtitle Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.config.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}