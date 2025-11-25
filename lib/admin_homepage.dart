import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'admin_event_management_page.dart';
import 'educational_mentorship_training_programs_page.dart';
import 'admin_research_projects_management_page.dart';
import 'admin_proposal_approval_page.dart';
import 'admin_achievement_management_page.dart';
import 'admin_member_id_management_page.dart';
import 'admin_governing_panel_page.dart';

// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentPurple = Color(0xFF6366F1);
const kAccentRed = Color(0xFFEF4444);
const kAccentBlue = Color(0xFF3B82F6);

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

  @override
  void initState() {
    super.initState();

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
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(),

          // Welcome Card
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

          // Dashboard Stats Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _DashboardStatsGrid(),
            ),
          ),

          // Bottom Spacing
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kGreenDark,
              kGreenMain,
              kGreenLight,
            ],
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
            children: [
              // Animated background pattern
              ...List.generate(15, (index) {
                return Positioned(
                  left: (index * 73.5) % MediaQuery.of(context).size.width,
                  top: (index * 31.2) % 120,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.1 * (1 - _pulseController.value * 0.5),
                        child: Icon(
                          Icons.hexagon,
                          size: 20 + (index % 3) * 10,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kGreenDark,
                kGreenMain,
                kGreenLight,
              ],
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
                  // Animated Icon
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
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
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pulse indicator
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: kAccentGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kAccentGold.withOpacity(
                                  0.8 * (1 - pulseController.value)),
                              blurRadius: 15 * pulseController.value,
                              spreadRadius: 5 * pulseController.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Manage all aspects of your application from this central hub',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13,
                          height: 1.4,
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

class _DashboardStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Section Title
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
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kGreenMain, kGreenLight],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Grid Layout - 2 cards per row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Events',
                icon: Icons.event_rounded,
                gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                collectionPath: 'All_Data/Event_Page/All_Events_of_RC',
                index: 0,
                destinationPage: const AdminEventPage(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Research & Projects',
                icon: Icons.science_rounded,
                gradient: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
                collectionPath: 'All_Data/Research_Projects/research_projects',
                index: 1,
                destinationPage: const AdminResearchProjectsPage(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Educational Programs',
                icon: Icons.school_rounded,
                gradient: [const Color(0xFF10B981), const Color(0xFF14B8A6)],
                collectionPath:
                'All_Data/Educational, Mentorship & Training Programs/educational, mentorship & training programs',
                index: 2,
                destinationPage: const EducationalProgramsPage(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Member IDs',
                icon: Icons.badge_rounded,
                gradient: [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
                collectionPath: 'All_Data/Student_AUSTRC_ID/dummy',
                index: 3,
                destinationPage: const AdminMemberIdManagementPage(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Proposal Approvals',
                icon: Icons.approval_rounded,
                gradient: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                collectionPath: 'All_Data/Student_Proposal_for_R&P/student_proposal_for_R&P',
                index: 4,
                destinationPage: const AdminProposalApprovalPage(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Manage Achievements',
                icon: Icons.workspace_premium_rounded,
                gradient: [const Color(0xFFFF6B35), const Color(0xFFF7931E)],
                collectionPath: 'All_Data/Achievement/achievement',
                index: 5,
                destinationPage: const AdminAchievementPage(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _GoverningPanelCard(index: 6),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String collectionPath;
  final int index;
  final Widget destinationPage;

  // Static timestamp for shimmer synchronization
  static final int _shimmerStartTime = DateTime.now().millisecondsSinceEpoch;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.collectionPath,
    required this.index,
    required this.destinationPage,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.index * 120)),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Synchronize shimmer across all cards using static timestamp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = now - _StatCard._shimmerStartTime;
        final offset = (elapsed % 2500) / 2500.0;
        _shimmerController.value = offset;
        _shimmerController.repeat();
      }
    });

    Future.delayed(Duration(milliseconds: 100 + (widget.index * 150)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse collection path
    final pathParts = widget.collectionPath.split('/');
    final collectionRef = FirebaseFirestore.instance
        .collection(pathParts[0])
        .doc(pathParts[1])
        .collection(pathParts[2]);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        widget.destinationPage,
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // Enhanced multi-layer transition
                      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOut),
                      );
                      final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      );
                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      );

                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: ScaleTransition(
                          scale: scaleAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..scale(_isPressed ? 0.94 : (_isHovered ? 1.03 : 1.0))
                  ..rotateZ(_isHovered ? -0.01 : 0),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradient[0].withOpacity(_isHovered ? 0.45 : 0.3),
                        blurRadius: _isHovered ? 32 : 24,
                        offset: Offset(0, _isHovered ? 16 : 12),
                        spreadRadius: _isHovered ? 2 : 0,
                      ),
                      BoxShadow(
                        color: widget.gradient[1].withOpacity(0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Gradient Background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.gradient[0],
                                widget.gradient[1],
                                widget.gradient[1],
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),

                        // Shimmer Effect
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Positioned(
                              left: _shimmerAnimation.value * MediaQuery.of(context).size.width * 0.5,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Decorative circles
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Row - Icon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: Duration(milliseconds: 700 + (widget.index * 100)),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Transform.rotate(
                                          angle: (1 - value) * math.pi * 0.5,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.25),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.4),
                                                width: 2.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              widget.icon,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Arrow button
                                  AnimatedBuilder(
                                    animation: _hoverController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(_hoverController.value * 3, 0),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              // Bottom Section - Title & Count
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  // Special handling for Member IDs
                                  widget.title == 'Member IDs'
                                      ? StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('All_Data')
                                              .doc('Student_AUSTRC_ID')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return SizedBox(
                                                height: 32,
                                                width: 32,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation(
                                                    Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                              );
                                            }

                                            if (snapshot.hasError) {
                                              return Text(
                                                'Error',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              );
                                            }

                                            // Count Member_X fields
                                            final data = snapshot.data?.data() as Map<String, dynamic>?;
                                            int count = 0;
                                            if (data != null) {
                                              data.forEach((key, value) {
                                                if (key.startsWith('Member_')) {
                                                  count++;
                                                }
                                              });
                                            }

                                            return TweenAnimationBuilder<int>(
                                              tween: IntTween(begin: 0, end: count),
                                              duration: const Duration(milliseconds: 1500),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, child) {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      value.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 42,
                                                        fontWeight: FontWeight.w900,
                                                        letterSpacing: -0.5,
                                                        height: 1,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 6),
                                                      child: Text(
                                                        'total',
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.85),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        )
                                      : StreamBuilder<QuerySnapshot>(
                                    stream: collectionRef.snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return SizedBox(
                                          height: 32,
                                          width: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Text(
                                          'Error',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        );
                                      }

                                      final count = snapshot.data?.docs.length ?? 0;

                                      return TweenAnimationBuilder<int>(
                                        tween: IntTween(begin: 0, end: count),
                                        duration: const Duration(milliseconds: 1500),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                value.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -0.5,
                                                  height: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 6),
                                                child: Text(
                                                  'total',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.85),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoverningPanelCard extends StatefulWidget {
  final int index;

  const _GoverningPanelCard({required this.index});

  @override
  State<_GoverningPanelCard> createState() => _GoverningPanelCardState();
}

class _GoverningPanelCardState extends State<_GoverningPanelCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.index * 120)),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: 100 + (widget.index * 150)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminGoverningPanelPage(),
                  ),
                );
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.identity()
                      ..scale(_isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0)),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withOpacity(_isHovered ? 0.5 : 0.35),
                            blurRadius: _isHovered ? 32 : 26,
                            offset: Offset(0, _isHovered ? 16 : 12),
                            spreadRadius: _isHovered ? 2 : 0,
                          ),
                          BoxShadow(
                            color: kAccentGold.withOpacity(0.35 * _glowAnimation.value),
                            blurRadius: 25 * _glowAnimation.value,
                            offset: const Offset(0, 0),
                            spreadRadius: 5 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                        // Gradient Background
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF334155),
                                Color(0xFF475569),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),

                        // Animated glow accent
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: -60,
                              right: -60,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      kAccentGold.withOpacity(0.25 * _glowAnimation.value),
                                      kAccentGold.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Decorative pattern
                        Positioned(
                          left: -40,
                          bottom: -40,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                                width: 30,
                              ),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              // Animated Icon with glow
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 700 + (widget.index * 100)),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: AnimatedBuilder(
                                      animation: _glowAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: kAccentGold,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: kAccentGold.withOpacity(0.5 * _glowAnimation.value),
                                                blurRadius: 24 * _glowAnimation.value,
                                                offset: const Offset(0, 4),
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.groups_rounded,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 24),

                              // Content Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Title
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: 1),
                                      duration: Duration(milliseconds: 800 + (widget.index * 100)),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(20 * (1 - value), 0),
                                            child: const Text(
                                              'Governing Panel',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    // Subtitle with icon
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kAccentGold.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: kAccentGold.withOpacity(0.4),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.admin_panel_settings_rounded,
                                                color: kAccentGold,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Manage Panel',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.95),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow with animation
                              AnimatedBuilder(
                                animation: _hoverController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_hoverController.value * 5, 0),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ), // closes AnimatedBuilder
        ), // closes GestureDetector
      ), // closes MouseRegion
    ), // closes ScaleTransition
  ), // Closes SlideTransition
); // Closes FadeTransition (return statement)
}
}













