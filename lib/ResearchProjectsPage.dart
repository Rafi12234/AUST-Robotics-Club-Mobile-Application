import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'Exclusive_Content_Page.dart';
// Main Research Projects List Page
class ResearchProjectsPage extends StatefulWidget {
  const ResearchProjectsPage({Key? key}) : super(key: key);

  @override
  State<ResearchProjectsPage> createState() => _ResearchProjectsPageState();
}

class _ResearchProjectsPageState extends State<ResearchProjectsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _particleController;
  late AnimationController _fabController;
  late AnimationController _pulseController;

  // Cache the stream to prevent rebuilding
  late final Stream<QuerySnapshot> _projectsStream;

  @override
  void initState() {
    super.initState();

    // Initialize the stream - fetch ALL projects, filter locally
    _projectsStream = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .snapshots();

    _headerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _particleController.dispose();
    _fabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Check if Premium_Content field is truthy (handles all variations)
  bool _isPremiumContent(Map<String, dynamic>? data) {
    if (data == null) return false;

    final value = data['Premium_Content'];

    if (value == null) return false;

    // Handle boolean
    if (value is bool) return value;

    // Handle string
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      return lowerValue == 'true' || lowerValue == 'yes' || lowerValue == '1';
    }

    // Handle int
    if (value is int) return value == 1;

    // Handle double
    if (value is double) return value == 1.0;

    return false;
  }

  void _toggleFabMenu() {
    if (_fabController.isAnimating) return;

    if (_fabController.status == AnimationStatus.completed) {
      _fabController.reverse();
    } else {
      _fabController.forward();
    }
  }

  void _closeFabMenu() {
    if (_fabController.status == AnimationStatus.completed) {
      _fabController.reverse();
    }
  }

  void _showProposalDialog(BuildContext context) {
    _closeFabMenu();
    Future.delayed(const Duration(milliseconds: 200), () {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Proposal Dialog',
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox();
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );
          return ScaleTransition(
            scale: curvedAnimation,
            child: FadeTransition(
              opacity: animation,
              child: const ProposalDialog(),
            ),
          );
        },
      );
    });
  }

  void _showExclusiveAccessDialog(BuildContext context) {
    _closeFabMenu();
    Future.delayed(const Duration(milliseconds: 200), () {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Exclusive Access Dialog',
        barrierColor: Colors.black.withOpacity(0.6),
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox();
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: animation,
              child: const ExclusiveAccessDialog(),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Background Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlesPainter(
                    animation: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Animated Header
              _buildSliverAppBar(context),

              // Exclusive Content Section
              SliverToBoxAdapter(
                child: _ExclusiveContentBanner(
                  onTap: () => _showExclusiveAccessDialog(context),
                  pulseController: _pulseController,
                ),
              ),

              // Projects List - Using cached stream with filtering
              _buildProjectsList(),

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // FAB with overlay - Separated from main content
          _FabOverlay(
            fabController: _fabController,
            onToggle: _toggleFabMenu,
            onExclusiveAccess: () => _showExclusiveAccessDialog(context),
            onSubmitProposal: () => _showProposalDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1B5E20),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final expandedHeight = 220.0;
          final collapsedHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final currentHeight = constraints.maxHeight;
          final collapseRatio = ((expandedHeight - currentHeight) /
              (expandedHeight - collapsedHeight))
              .clamp(0.0, 1.0);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D3B1F),
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated DNA Helix Pattern
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _headerController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _DNAHelixPainter(
                          animation: _headerController.value,
                          opacity: 1 - collapseRatio,
                        ),
                      );
                    },
                  ),
                ),

                // Content
                Positioned(
                  left: 24 + (48 * collapseRatio),
                  right: 24,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (collapseRatio < 0.5) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.science,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Innovation Hub',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        'Research & Projects',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32 - (12 * collapseRatio),
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      if (collapseRatio < 0.5) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Explore groundbreaking innovations',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _projectsStream,
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Error State
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading projects',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // No Data State
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Projects Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for amazing projects!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ FILTER: Show only NON-PREMIUM projects
        final allDocs = snapshot.data!.docs;

        final regularProjects = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          // Show if NOT premium (Premium_Content is false, null, or not set)
          return !_isPremiumContent(data);
        }).toList();

        // Empty Regular Projects State
        if (regularProjects.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Projects Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for amazing projects!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Hint about exclusive content
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A148C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4A148C).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Check out Exclusive Content for premium projects!',
                            style: TextStyle(
                              color: Color(0xFF4A148C),
                              fontSize: 12,
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
          );
        }

        // Display Regular (Non-Premium) Projects
        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final project = regularProjects[index];
                final projectName = project.id;
                final data = project.data() as Map<String, dynamic>?;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(-100 * (1 - value), 0),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ProjectCard(
                      projectName: projectName,
                      data: data,
                      index: index,
                    ),
                  ),
                );
              },
              childCount: regularProjects.length,
            ),
          ),
        );
      },
    );
  }
}

// ===================== Separated FAB Overlay Widget =====================
class _FabOverlay extends StatelessWidget {
  final AnimationController fabController;
  final VoidCallback onToggle;
  final VoidCallback onExclusiveAccess;
  final VoidCallback onSubmitProposal;

  const _FabOverlay({
    required this.fabController,
    required this.onToggle,
    required this.onExclusiveAccess,
    required this.onSubmitProposal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fabController,
      builder: (context, child) {
        final isOpen = fabController.value > 0;

        return Stack(
          children: [
            // Overlay
            if (isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * fabController.value),
                  ),
                ),
              ),

            // FAB Menu Items
            Positioned(
              right: 16,
              bottom: 90,
              child: IgnorePointer(
                ignoring: !isOpen,
                child: Opacity(
                  opacity: fabController.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - fabController.value)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Exclusive Content Button
                        _FabMenuItem(
                          icon: Icons.workspace_premium,
                          label: 'Exclusive Content',
                          color: const Color(0xFFFF6B35),
                          onTap: onExclusiveAccess,
                          animationValue: fabController.value,
                          delay: 0.0,
                        ),
                        const SizedBox(height: 12),
                        // Submit Proposal Button
                        _FabMenuItem(
                          icon: Icons.add_circle_outline,
                          label: 'Submit Proposal',
                          color: const Color(0xFF2E7D32),
                          onTap: onSubmitProposal,
                          animationValue: fabController.value,
                          delay: 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main FAB
            Positioned(
              right: 16,
              bottom: 24,
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: fabController.value > 0.5
                          ? [const Color(0xFFD32F2F), const Color(0xFFE57373)]
                          : [const Color(0xFF1B5E20), const Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (fabController.value > 0.5
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF1B5E20))
                            .withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: fabController.value * (math.pi / 4),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===================== FAB Menu Item - Fixed Opacity =====================
class _FabMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double animationValue;
  final double delay;

  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.animationValue,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed: Properly clamp the delayed value between 0.0 and 1.0
    final double delayedValue;
    if (delay >= 1.0) {
      delayedValue = 0.0;
    } else {
      delayedValue = ((animationValue - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    }

    return Transform.translate(
      offset: Offset(30 * (1 - delayedValue), 0),
      child: Opacity(
        opacity: delayedValue, // Now guaranteed to be between 0.0 and 1.0
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== Separated Project Card Widget =====================
class _ProjectCard extends StatelessWidget {
  final String projectName;
  final Map<String, dynamic>? data;
  final int index;

  const _ProjectCard({
    required this.projectName,
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      [const Color(0xFF00695C), const Color(0xFF00897B)],
      [const Color(0xFF1565C0), const Color(0xFF1976D2)],
      [const Color(0xFF6A1B9A), const Color(0xFF7B1FA2)],
    ];
    final gradient = colors[index % colors.length];
    final coverUrl = (data?['Cover_Picture'] ?? '').toString();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProjectDetailPage(
                  projectName: projectName,
                  projectData: data ?? {},
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var tween = Tween<double>(begin: 0.0, end: 1.0);
              var fadeAnimation = animation.drive(tween);

              var scaleTween = Tween<double>(begin: 0.9, end: 1.0);
              var scaleAnimation = animation.drive(scaleTween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[1].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Hexagon Pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _HexagonPatternPainter(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Cover image box
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: coverUrl.isNotEmpty
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullScreenImagePage(imageUrl: coverUrl),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.photo_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          projectName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Exclusive Content Banner =====================
class _ExclusiveContentBanner extends StatefulWidget {
  final VoidCallback onTap;
  final AnimationController pulseController;

  const _ExclusiveContentBanner({
    required this.onTap,
    required this.pulseController,
  });

  @override
  State<_ExclusiveContentBanner> createState() => _ExclusiveContentBannerState();
}

class _ExclusiveContentBannerState extends State<_ExclusiveContentBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedBuilder(
              animation: widget.pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A237E),
                        Color(0xFF4A148C),
                        Color(0xFF880E4F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A148C).withOpacity(
                            (0.3 + (0.2 * widget.pulseController.value)).clamp(0.0, 1.0)),
                        blurRadius: 20 + (10 * widget.pulseController.value),
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer Effect
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _ShimmerPainter(
                                  animation: _shimmerController.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Floating Particles
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CustomPaint(
                            painter: _FloatingParticlesPainter(
                              animation: widget.pulseController.value,
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Row(
                        children: [
                          // Premium Icon with Glow
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.3),
                                  Colors.orange.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(
                                      (0.3 * widget.pulseController.value).clamp(0.0, 1.0)),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Colors.amber[300],
                                  size: 36,
                                ),
                                // Sparkle Effect
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Transform.scale(
                                    scale: 0.5 + (0.5 * widget.pulseController.value),
                                    child: Opacity(
                                      opacity: widget.pulseController.value.clamp(0.0, 1.0),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.amber.withOpacity(0.4),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber[300],
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'MEMBERS ONLY',
                                            style: TextStyle(
                                              color: Colors.amber[300],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Exclusive Research & Educational Content',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Access premium materials with your AUSTRC ID',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== Exclusive Access Dialog =====================
class ExclusiveAccessDialog extends StatefulWidget {
  const ExclusiveAccessDialog({Key? key}) : super(key: key);

  @override
  State<ExclusiveAccessDialog> createState() => _ExclusiveAccessDialogState();
}

class _ExclusiveAccessDialogState extends State<ExclusiveAccessDialog>
    with TickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  String _verifiedId = '';
  String _errorMessage = '';

  late AnimationController _shakeController;
  late AnimationController _successController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _verifyId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() => _errorMessage = 'Please enter your AUSTRC ID');
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      // Get all member documents from the Members collection
      final membersCollection = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_AUSTRC_ID')
          .collection('Members')
          .get();

      if (membersCollection.docs.isEmpty) {
        throw Exception('Database not available');
      }

      bool found = false;

      // Check each member document for matching AUSTRC_ID
      for (var memberDoc in membersCollection.docs) {
        final memberData = memberDoc.data();
        final austrcId = memberData['AUSTRC_ID'];

        if (austrcId == id) {
          found = true;
          break;
        }
      }

      if (found) {
        setState(() {
          _isVerified = true;
          _verifiedId = id;
        });
        _successController.forward();
        HapticFeedback.heavyImpact();
      } else {
        setState(() => _errorMessage = 'Invalid AUSTRC ID. Please try again.');
        _shakeController.forward().then((_) => _shakeController.reset());
        HapticFeedback.vibrate();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Verification failed. Please try again.');
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _proceedToExclusiveContent() {
    Navigator.pop(context); // Close the dialog first

    // Show welcome snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Welcome $_verifiedId! Accessing exclusive content...'),
          ],
        ),
        backgroundColor: const Color(0xFF4A148C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to Exclusive Content Page with smooth transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ExclusiveContentPage(
                verifiedId: _verifiedId,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shakeOffset = math.sin(_shakeAnimation.value * math.pi * 4) * 10;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A237E),
                        Color(0xFF4A148C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DialogPatternPainter(),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  _isVerified
                                      ? Icons.verified_user
                                      : Icons.workspace_premium,
                                  color: Colors.amber[300],
                                  size: 32,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isVerified ? 'Access Granted!' : 'Exclusive Access',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isVerified
                                ? 'Welcome to AUSTRC premium content'
                                : 'Verify your AUSTRC membership',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _isVerified
                      ? _buildSuccessContent()
                      : _buildVerificationContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4A148C).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4A148C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Members Only Content',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your AUSTRC ID to access exclusive research projects and educational materials.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'AUSTRC Member ID',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _errorMessage.isNotEmpty
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF4A148C).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _idController,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., AUSTRC001',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Color(0xFF4A148C),
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _errorMessage.isNotEmpty
                      ? Colors.red
                      : const Color(0xFF4A148C).withOpacity(0.2),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _errorMessage.isNotEmpty
                      ? Colors.red.withOpacity(0.5)
                      : const Color(0xFF4A148C).withOpacity(0.2),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF4A148C),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verifyId(),
          ),
        ),

        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyId,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A148C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF4A148C).withOpacity(0.4),
            ),
            child: _isVerifying
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 22),
                SizedBox(width: 10),
                Text(
                  'Verify ID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(text: 'Not a member yet? '),
                      TextSpan(
                        text: 'Join AUSTRC',
                        style: TextStyle(
                          color: Color(0xFF4A148C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                          text:
                          ' to get your exclusive ID and access premium content.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value.clamp(0.0, 2.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43A047).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF43A047).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF43A047).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified,
                color: Color(0xFF43A047),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _verifiedId,
                style: const TextStyle(
                  color: Color(0xFF43A047),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Your membership has been verified!',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                Icons.science_outlined,
                'Exclusive Research Papers',
                'Access in-depth research documents',
              ),
              const Divider(height: 20),
              _buildFeatureItem(
                Icons.school_outlined,
                'Educational Materials',
                'Premium learning resources',
              ),
              const Divider(height: 20),
              _buildFeatureItem(
                Icons.video_library_outlined,
                'Tutorial Videos',
                'Step-by-step project guides',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _proceedToExclusiveContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF43A047).withOpacity(0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Access Exclusive Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A148C),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          color: const Color(0xFF43A047).withOpacity(0.7),
          size: 20,
        ),
      ],
    );
  }
}

// ===================== Proposal Dialog =====================
class ProposalDialog extends StatefulWidget {
  const ProposalDialog({Key? key}) : super(key: key);

  @override
  State<ProposalDialog> createState() => _ProposalDialogState();
}

class _ProposalDialogState extends State<ProposalDialog> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _institutionalMailController =
  TextEditingController();

  bool _isVerified = false;
  bool _isVerifying = false;
  bool _isSubmitting = false;
  String _verifiedId = '';
  String _proposalType = 'Research';

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _institutionalMailController.dispose();
    super.dispose();
  }

  Future<void> _verifyId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your AUSTRC ID')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Get all member documents from the Members collection
      final membersCollection = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_AUSTRC_ID')
          .collection('Members')
          .get();

      if (membersCollection.docs.isEmpty) {
        throw Exception('Members collection not found');
      }

      bool found = false;

      // Check each member document for matching AUSTRC_ID
      for (var memberDoc in membersCollection.docs) {
        final memberData = memberDoc.data();
        final austrcId = memberData['AUSTRC_ID'];

        if (austrcId == id) {
          found = true;
          break;
        }
      }

      if (found) {
        setState(() {
          _isVerified = true;
          _verifiedId = id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid AUSTRC ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying ID: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _submitProposal() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final institutionalMail = _institutionalMailController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter project title')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter short description')),
      );
      return;
    }

    if (description.split(' ').length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description must be within 100 words')),
      );
      return;
    }

    if (institutionalMail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter institutional mail')),
      );
      return;
    }

    if (!institutionalMail.contains('@') || !institutionalMail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_Proposal_for_R&P')
          .collection('student_proposal_for_R&P')
          .doc(_verifiedId)
          .set({
        'Proposal': _proposalType,
        'Title': title,
        'Short_Des': description,
        'Institutional_Mail': institutionalMail,
        'Timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting proposal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Submit Proposal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (!_isVerified) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Step 1: Verify Your Identity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _idController,
                          decoration: InputDecoration(
                            hintText: 'Enter AUSTRC ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.badge),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Verify ID',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Verified: $_verifiedId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Proposal Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Research',
                                style: TextStyle(fontSize: 14)),
                            value: 'Research',
                            groupValue: _proposalType,
                            onChanged: (value) {
                              setState(() => _proposalType = value!);
                            },
                            activeColor: const Color(0xFF2E7D32),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Project',
                                style: TextStyle(fontSize: 14)),
                            value: 'Project',
                            groupValue: _proposalType,
                            onChanged: (value) {
                              setState(() => _proposalType = value!);
                            },
                            activeColor: const Color(0xFF2E7D32),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Title',
                    controller: _titleController,
                    hint: 'Enter project/research title',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Institutional Mail',
                    controller: _institutionalMailController,
                    hint: 'Enter your institutional email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Short Description (Max 100 words)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter a brief description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2E7D32),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitProposal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Submit Proposal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2E7D32),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== Project Detail Page =====================
class ProjectDetailPage extends StatefulWidget {
  final String projectName;
  final Map<String, dynamic> projectData;

  const ProjectDetailPage({
    Key? key,
    required this.projectName,
    required this.projectData,
  }) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Map<int, int> _sectionImageIndices = {};
  final Map<String, double> _imageAspect = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resolveImageAspect(String url) {
    if (url.isEmpty || _imageAspect.containsKey(url)) return;
    final img = Image.network(url);
    final ImageStream stream = img.image.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (h != 0) {
        if (mounted) {
          setState(() {
            _imageAspect[url] = w / h;
          });
        } else {
          _imageAspect[url] = w / h;
        }
      }
      stream.removeListener(listener!);
    }, onError: (error, stackTrace) {
      stream.removeListener(listener!);
    });
    stream.addListener(listener);
  }

  List<Map<String, dynamic>> _getOwners() {
    List<Map<String, dynamic>> owners = [];
    int ownerIndex = 1;
    while (true) {
      final nameKey = 'Owner_${ownerIndex}_Name';
      final designationKey = 'Owner_${ownerIndex}_Designation_Department';

      if (widget.projectData.containsKey(nameKey) &&
          widget.projectData[nameKey] != null) {
        owners.add({
          'name': widget.projectData[nameKey],
          'designation': widget.projectData[designationKey] ?? 'N/A',
        });
        ownerIndex++;
      }       else {
        break;
      }
    }
    return owners;
  }

  List<Map<String, dynamic>> _getSections() {
    List<Map<String, dynamic>> sections = [];
    int sectionIndex = 1;
    while (true) {
      final nameKey = 'Section_${sectionIndex}_Name';
      final descriptionKey = 'Section_${sectionIndex}_Description';

      if (widget.projectData.containsKey(nameKey) &&
          widget.projectData[nameKey] != null) {
        List<String> images = [];
        int imageIndex = 1;
        while (true) {
          final imageKey = 'Section_${sectionIndex}_Image_$imageIndex';
          if (widget.projectData.containsKey(imageKey) &&
              widget.projectData[imageKey] != null &&
              widget.projectData[imageKey].toString().isNotEmpty) {
            images.add(widget.projectData[imageKey]);
            imageIndex++;
          } else {
            break;
          }
        }

        sections.add({
          'name': widget.projectData[nameKey],
          'description': widget.projectData[descriptionKey] ?? '',
          'images': images,
        });
        sectionIndex++;
      } else {
        break;
      }
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final coverPhoto = widget.projectData['Cover_Picture'] ?? '';
    final title = widget.projectData['Title'] ?? widget.projectName;
    final subtitle = widget.projectData['Subtitle'] ?? '';
    final owners = _getOwners();
    final sections = _getSections();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Cover Photo Header
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverPhoto.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: coverPhoto,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          ),
                        ),
                        child: const Icon(
                          Icons.science,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        ),
                      ),
                      child: const Icon(
                        Icons.science,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                            height: 1.3,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Owners Section
                  if (owners.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Project Team',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...owners.asMap().entries.map((entry) {
                      final index = entry.key;
                      final owner = entry.value;
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(30 * (1 - value), 0),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                const Color(0xFF1B5E20).withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1B5E20),
                                      Color(0xFF43A047)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      owner['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      owner['designation'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Sections
                  ...sections.asMap().entries.map((entry) {
                    final sectionIndex = entry.key;
                    final section = entry.value;
                    final images = section['images'] as List<String>;
                    final description =
                        (section['description'] as String?) ?? '';

                    return TweenAnimationBuilder<double>(
                      duration:
                      Duration(milliseconds: 800 + (sectionIndex * 150)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1B5E20),
                                    Color(0xFF2E7D32)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B5E20)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${sectionIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      section['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Section Images
                            if (images.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  final currentIdx =
                                      _sectionImageIndices[sectionIndex] ?? 0;
                                  final currentUrl =
                                  images[currentIdx].toString();
                                  _resolveImageAspect(currentUrl);

                                  final screenWidth =
                                      MediaQuery.of(context).size.width;
                                  final aspect = _imageAspect[currentUrl];
                                  final targetHeight = aspect != null
                                      ? (screenWidth / aspect)
                                      : 260.0;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    height: targetHeight.clamp(200.0, 400.0),
                                    child: PageView.builder(
                                      controller:
                                      PageController(viewportFraction: 1),
                                      onPageChanged: (idx) {
                                        setState(() {
                                          _sectionImageIndices[sectionIndex] =
                                              idx;
                                        });
                                      },
                                      itemCount: images.length,
                                      itemBuilder: (context, imageIndex) {
                                        final url =
                                        images[imageIndex].toString();
                                        _resolveImageAspect(url);

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF1B5E20)
                                                    .withOpacity(0.2),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            FullScreenImagePage(
                                                                imageUrl: url),
                                                      ),
                                                    );
                                                  },
                                                  child: CachedNetworkImage(
                                                    imageUrl: url,
                                                    fit: BoxFit.contain,
                                                    placeholder:
                                                        (context, url) =>
                                                        Container(
                                                          color: Colors.grey[200],
                                                          child: const Center(
                                                            child:
                                                            CircularProgressIndicator(
                                                              color:
                                                              Color(0xFF2E7D32),
                                                            ),
                                                          ),
                                                        ),
                                                    errorWidget: (context, url,
                                                        error) =>
                                                        Container(
                                                          color: Colors.grey[200],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            size: 60,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  ),
                                                ),

                                                // Image Counter
                                                Positioned(
                                                  bottom: 12,
                                                  right: 12,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                    ),
                                                    child: Text(
                                                      '${imageIndex + 1}/${images.length}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),
                              // Image Indicators
                              if (images.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    images.length,
                                        (idx) {
                                      final currentIndex =
                                          _sectionImageIndices[sectionIndex] ??
                                              0;
                                      final active = currentIndex == idx;
                                      return AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 300),
                                        width: active ? 30 : 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          gradient: active
                                              ? const LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20),
                                              Color(0xFF2E7D32),
                                            ],
                                          )
                                              : null,
                                          color:
                                          active ? null : Colors.grey[300],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],

                            // Section Description (with copy icon)
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 48, 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF2E7D32)
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                        height: 1.7,
                                        letterSpacing: 0.3,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),

                                  // Copy button at top-right
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        tooltip: 'Copy description',
                                        icon: const Icon(Icons.copy_rounded,
                                            size: 20,
                                            color: Color(0xFF2E7D32)),
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: description),
                                          );
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 20),
                                                  SizedBox(width: 10),
                                                  Text('Description copied!'),
                                                ],
                                              ),
                                              backgroundColor:
                                              const Color(0xFF2E7D32),
                                              behavior:
                                              SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                              duration:
                                              const Duration(seconds: 2),
                                              margin: const EdgeInsets.all(16),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================ Full Screen Image Page =================
class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeImage() {
    _animationController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background
              Container(
                color: Colors.black.withOpacity(_fadeAnimation.value.clamp(0.0, 1.0)),
              ),

              // Image
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 60,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
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

              // Close Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: _closeImage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Copy Link Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.imageUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.link, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Image URL copied!'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Zoom Hint
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 30,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pinch,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pinch to zoom',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===================== Custom Painters =====================
class _ParticlesPainter extends CustomPainter {
  final double animation;

  _ParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = (i * 73.5 + animation * size.width) % size.width;
      final y = (i * 47.3) % size.height;
      canvas.drawCircle(Offset(x, y), 3 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DNAHelixPainter extends CustomPainter {
  final double animation;
  final double opacity;

  _DNAHelixPainter({required this.animation, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity((0.1 * opacity).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double x = 0; x < size.width; x += 10) {
      final y1 = size.height * 0.5 +
          math.sin((x / 30) + animation * 2 * math.pi) * 30;
      final y2 = size.height * 0.5 -
          math.sin((x / 30) + animation * 2 * math.pi) * 30;

      canvas.drawCircle(Offset(x, y1), 2, paint);
      canvas.drawCircle(Offset(x, y2), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HexagonPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double y = -20; y < size.height + 20; y += 40) {
      for (double x = -20; x < size.width + 20; x += 35) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60) * math.pi / 180;
          final px = x + 15 * math.cos(angle);
          final py = y + 15 * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShimmerPainter extends CustomPainter {
  final double animation;

  _ShimmerPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment(-1 + (2 * animation), 0),
        end: Alignment(1 + (2 * animation), 0),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloatingParticlesPainter extends CustomPainter {
  final double animation;

  _FloatingParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (i * 47 + animation * 100) % size.width;
      final y = (i * 31 + animation * 50) % size.height;
      canvas.drawCircle(Offset(x, y), 2 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DialogPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * 37).toDouble() % size.width;
      final y = (i * 23).toDouble() % size.height;
      canvas.drawCircle(Offset(x, y), 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}