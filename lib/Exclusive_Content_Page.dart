import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ===================== Exclusive Content Page =====================
class ExclusiveContentPage extends StatefulWidget {
  final String verifiedId;

  const ExclusiveContentPage({
    Key? key,
    required this.verifiedId,
  }) : super(key: key);

  @override
  State<ExclusiveContentPage> createState() => _ExclusiveContentPageState();
}

class _ExclusiveContentPageState extends State<ExclusiveContentPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _welcomeController;

  // Cache the stream to prevent rebuilding
  late final Stream<QuerySnapshot> _exclusiveProjectsStream;

  @override
  void initState() {
    super.initState();

    // Initialize the stream once - only get Premium_Content = true
    _exclusiveProjectsStream = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .where('Premium_Content', isEqualTo: true)
        .snapshots();

    _headerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ExclusiveParticlesPainter(
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
              // Animated Header
              _buildSliverAppBar(context),

              // Welcome Banner
              SliverToBoxAdapter(
                child: _WelcomeBanner(
                  verifiedId: widget.verifiedId,
                  welcomeController: _welcomeController,
                  pulseController: _pulseController,
                ),
              ),

              // Category Chips


              // Exclusive Projects List
              _buildExclusiveProjectsList(),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: const Color(0xFF4A148C),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
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
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Colors.amber[300],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.amber[300],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final expandedHeight = 240.0;
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
                  Color(0xFF1A237E),
                  Color(0xFF4A148C),
                  Color(0xFF880E4F),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated Aurora Pattern
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _headerController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _AuroraPatternPainter(
                          animation: _headerController.value,
                          opacity: 1 - collapseRatio,
                        ),
                      );
                    },
                  ),
                ),

                // Floating Stars
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _FloatingStarsPainter(
                          animation: _pulseController.value,
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
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(-30 * (1 - value), 0),
                              child: Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_open_rounded,
                                  color: Colors.amber[300],
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Members Exclusive',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          'Exclusive Content',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32 - (12 * collapseRatio),
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (collapseRatio < 0.5) ...[
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1200),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 15 * (1 - value)),
                              child: Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            'Premium research & educational materials',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildExclusiveProjectsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _exclusiveProjectsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A148C).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
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

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: _buildErrorState(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        final projects = snapshot.data!.docs;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final project = projects[index];
                final projectName = project.id;
                final data = project.data() as Map<String, dynamic>?;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 600 + (index * 150)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ExclusiveProjectCard(
                      projectName: projectName,
                      data: data,
                      index: index,
                    ),
                  ),
                );
              },
              childCount: projects.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
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

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4A148C).withOpacity(0.1),
                    const Color(0xFF880E4F).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Exclusive Content Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Premium research and projects will appear here soon!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Welcome Banner =====================
class _WelcomeBanner extends StatelessWidget {
  final String verifiedId;
  final AnimationController welcomeController;
  final AnimationController pulseController;

  const _WelcomeBanner({
    required this.verifiedId,
    required this.welcomeController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: welcomeController,
      builder: (context, child) {
        final value = CurvedAnimation(
          parent: welcomeController,
          curve: Curves.easeOutBack,
        ).value;

        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A237E),
              Color(0xFF4A148C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A148C).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _WelcomePatternPainter(),
                ),
              ),
            ),

            Row(
              children: [
                // Avatar with Glow
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    return Container(
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
                            color: Colors.amber
                                .withOpacity(0.3 * pulseController.value),
                            blurRadius: 20,
                            spreadRadius: 5 * pulseController.value,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: Colors.amber[300],
                            size: 36,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF43A047),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              color: Colors.amber[300],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              verifiedId,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enjoy your premium access',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
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
    );
  }
}



// ===================== Exclusive Project Card =====================
class _ExclusiveProjectCard extends StatefulWidget {
  final String projectName;
  final Map<String, dynamic>? data;
  final int index;

  const _ExclusiveProjectCard({
    required this.projectName,
    required this.data,
    required this.index,
  });

  @override
  State<_ExclusiveProjectCard> createState() => _ExclusiveProjectCardState();
}

class _ExclusiveProjectCardState extends State<_ExclusiveProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xFF1A237E), const Color(0xFF3949AB)],
      [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
      [const Color(0xFF880E4F), const Color(0xFFAD1457)],
      [const Color(0xFF311B92), const Color(0xFF512DA8)],
      [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
    ];
    final gradient = gradients[widget.index % gradients.length];
    final coverUrl = (widget.data?['Cover_Picture'] ?? '').toString();
    final subtitle = (widget.data?['Subtitle'] ?? '').toString();

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _hoverController.reverse();
        // Navigate to detail page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ExclusiveProjectDetailPage(
                  projectName: widget.projectName,
                  projectData: widget.data ?? {},
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (0.02 * _hoverController.value),
            child: child,
          );
        },
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient[1].withOpacity(_isPressed ? 0.6 : 0.4),
                blurRadius: _isPressed ? 25 : 20,
                offset: Offset(0, _isPressed ? 12 : 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: _CardPatternPainter(),
                  ),
                ),
              ),

              // Premium Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
                        Icons.workspace_premium,
                        color: Colors.amber[300],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.amber[300],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Cover Image
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: coverUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withOpacity(0.1),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                            : const Icon(
                          Icons.science_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            widget.projectName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Spacer(),
                          // View Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'View Content',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 14,
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
      ),
    );
  }
}

// ===================== Exclusive Project Detail Page =====================
class ExclusiveProjectDetailPage extends StatefulWidget {
  final String projectName;
  final Map<String, dynamic> projectData;

  const ExclusiveProjectDetailPage({
    Key? key,
    required this.projectName,
    required this.projectData,
  }) : super(key: key);

  @override
  State<ExclusiveProjectDetailPage> createState() =>
      _ExclusiveProjectDetailPageState();
}

class _ExclusiveProjectDetailPageState extends State<ExclusiveProjectDetailPage>
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
    final ImageProvider img = CachedNetworkImageProvider(url);
    final ImageStream stream = img.resolve(const ImageConfiguration());
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
      } else {
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
      backgroundColor: const Color(0xFFF8F7FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Cover Photo Header
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF4A148C),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
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
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.amber[300],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.amber[300],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverPhoto.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: coverPhoto,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
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
                          colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
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
                          const Color(0xFF4A148C).withOpacity(0.8),
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
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
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
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A148C).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Premium Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Colors.amber[300],
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Exclusive Content',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
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
                  ),

                  // Owners Section
                  if (owners.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.people_rounded,
                      title: 'Project Team',
                      delay: 400,
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
                        child: _buildOwnerCard(owner),
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
                      child: _buildSection(
                        sectionIndex: sectionIndex,
                        section: section,
                        images: images,
                        description: description,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: delay + 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-30 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCard(Map<String, dynamic> owner) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A148C).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A148C).withOpacity(0.08),
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
                colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
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
                    color: Color(0xFF1A237E),
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
    );
  }

  Widget _buildSection({
    required int sectionIndex,
    required Map<String, dynamic> section,
    required List<String> images,
    required String description,
  }) {
    return Padding(
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
                colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A148C).withOpacity(0.3),
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
                final currentIdx = _sectionImageIndices[sectionIndex] ?? 0;
                final currentUrl = images[currentIdx].toString();
                _resolveImageAspect(currentUrl);

                final screenWidth = MediaQuery.of(context).size.width;
                final aspect = _imageAspect[currentUrl];
                final targetHeight =
                aspect != null ? (screenWidth / aspect) : 260.0;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: targetHeight.clamp(200.0, 400.0),
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 1),
                    onPageChanged: (idx) {
                      setState(() {
                        _sectionImageIndices[sectionIndex] = idx;
                      });
                    },
                    itemCount: images.length,
                    itemBuilder: (context, imageIndex) {
                      final url = images[imageIndex].toString();
                      _resolveImageAspect(url);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A148C).withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => _ExclusiveFullScreenImagePage(
                                          imageUrl: url),
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFF3E5F5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4A148C),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: const Color(0xFFF3E5F5),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4A148C),
                                        Color(0xFF880E4F)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${imageIndex + 1}/${images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
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
                        _sectionImageIndices[sectionIndex] ?? 0;
                    final active = currentIndex == idx;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: active ? 30 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: active
                            ? const LinearGradient(
                          colors: [
                            Color(0xFF4A148C),
                            Color(0xFF880E4F),
                          ],
                        )
                            : null,
                        color: active ? null : Colors.grey[300],
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 48, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4A148C).withOpacity(0.2),
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
                          size: 20, color: Color(0xFF4A148C)),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: description),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Description copied!'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF4A148C),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
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
    );
  }
}

// ===================== Exclusive Full Screen Image Page =====================
class _ExclusiveFullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  const _ExclusiveFullScreenImagePage({required this.imageUrl});

  @override
  State<_ExclusiveFullScreenImagePage> createState() =>
      _ExclusiveFullScreenImagePageState();
}

class _ExclusiveFullScreenImagePageState
    extends State<_ExclusiveFullScreenImagePage>
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
              Container(
                color: Colors.black
                    .withOpacity(_fadeAnimation.value.clamp(0.0, 1.0)),
              ),
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A148C).withOpacity(0.8),
                            const Color(0xFF880E4F).withOpacity(0.8),
                          ],
                        ),
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
                          backgroundColor: const Color(0xFF4A148C),
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A148C).withOpacity(0.8),
                            const Color(0xFF880E4F).withOpacity(0.8),
                          ],
                        ),
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A148C).withOpacity(0.6),
                            const Color(0xFF880E4F).withOpacity(0.6),
                          ],
                        ),
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
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pinch to zoom',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
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
class _ExclusiveParticlesPainter extends CustomPainter {
  final double animation;

  _ExclusiveParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A148C).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final x = (i * 67.5 + animation * size.width * 0.5) % size.width;
      final y = (i * 43.3 + animation * 20) % size.height;
      canvas.drawCircle(Offset(x, y), 2 + (i % 4).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AuroraPatternPainter extends CustomPainter {
  final double animation;
  final double opacity;

  _AuroraPatternPainter({required this.animation, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Aurora wave 1
    paint.color = Colors.purple.withOpacity(0.1 * opacity);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.6 +
          math.sin((x / 50) + animation * 2 * math.pi) * 40 +
          math.cos((x / 30) + animation * math.pi) * 20;
      path1.lineTo(x, y);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Aurora wave 2
    paint.color = Colors.pink.withOpacity(0.08 * opacity);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.5 +
          math.sin((x / 40) + animation * 2.5 * math.pi + 1) * 35 +
          math.cos((x / 35) + animation * 1.5 * math.pi) * 25;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);

    // Aurora wave 3
    paint.color = Colors.indigo.withOpacity(0.06 * opacity);
    final path3 = Path();
    path3.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.7 +
          math.sin((x / 60) + animation * 1.8 * math.pi + 2) * 30;
      path3.lineTo(x, y);
    }
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloatingStarsPainter extends CustomPainter {
  final double animation;
  final double opacity;

  _FloatingStarsPainter({required this.animation, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6 * opacity)
      ..style = PaintingStyle.fill;

    // Draw stars at various positions
    final starPositions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.7, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.55),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final pos = starPositions[i];
      final twinkle = (math.sin(animation * 2 * math.pi + i * 0.5) + 1) / 2;
      final starSize = 1.5 + twinkle * 1.5;

      paint.color = Colors.white.withOpacity((0.3 + twinkle * 0.5) * opacity);
      canvas.drawCircle(pos, starSize, paint);

      // Add glow effect
      paint.color = Colors.white.withOpacity((0.1 + twinkle * 0.2) * opacity);
      canvas.drawCircle(pos, starSize * 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WelcomePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 15; i++) {
      final x = (i * 53).toDouble() % size.width;
      final y = (i * 37).toDouble() % size.height;
      canvas.drawCircle(Offset(x, y), 25 + (i % 3) * 10, paint);
    }

    // Draw diagonal lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = Colors.white.withOpacity(0.03);

    for (double i = -size.height; i < size.width + size.height; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.9),
      40,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      30,
      paint,
    );

    // Hexagon pattern
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = Colors.white.withOpacity(0.03);

    for (double y = -10; y < size.height + 20; y += 35) {
      for (double x = -10; x < size.width + 20; x += 30) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60) * math.pi / 180;
          final px = x + 12 * math.cos(angle);
          final py = y + 12 * math.sin(angle);
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

// ===================== Statistics Section Widget =====================
class _StatisticsSection extends StatelessWidget {
  final AnimationController animationController;

  const _StatisticsSection({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final value = CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
        ).value;

        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A148C).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.science_outlined,
              value: '15+',
              label: 'Research',
              color: const Color(0xFF4A148C),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.build_outlined,
              value: '25+',
              label: 'Projects',
              color: const Color(0xFF880E4F),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.video_library_outlined,
              value: '50+',
              label: 'Tutorials',
              color: const Color(0xFF1A237E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey[200],
    );
  }
}

// ===================== Featured Content Card =====================
class _FeaturedContentCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;
  final int index;

  const _FeaturedContentCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
    required this.index,
  });

  @override
  State<_FeaturedContentCard> createState() => _FeaturedContentCardState();
}

class _FeaturedContentCardState extends State<_FeaturedContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

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
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A148C).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: widget.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4A148C),
                              Color(0xFF880E4F)
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4A148C),
                              Color(0xFF880E4F)
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.science,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    )
                        : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
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
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Shimmer Effect
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _CardShimmerPainter(
                            animation: _shimmerController.value,
                          ),
                        );
                      },
                    ),
                  ),

                  // Premium Badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'View Now',
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
          ),
        ),
      ),
    );
  }
}

class _CardShimmerPainter extends CustomPainter {
  final double animation;

  _CardShimmerPainter({required this.animation});

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
        begin: Alignment(-1 + (3 * animation), -1),
        end: Alignment(1 + (3 * animation), 1),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ===================== Locked Content Overlay =====================
class _LockedContentOverlay extends StatelessWidget {
  final VoidCallback onUnlock;

  const _LockedContentOverlay({
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: Colors.amber[300],
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Premium Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verify your membership to access',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onUnlock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_open, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Unlock Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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

// ===================== Progress Indicator Widget =====================
class _ContentProgressIndicator extends StatelessWidget {
  final double progress;
  final Color color;

  const _ContentProgressIndicator({
    required this.progress,
    this.color = const Color(0xFF4A148C),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== Bookmark Button Widget =====================
class _BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onToggle;

  const _BookmarkButton({
    required this.isBookmarked,
    required this.onToggle,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.isBookmarked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBookmarked != oldWidget.isBookmarked) {
      if (widget.isBookmarked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onToggle();
        HapticFeedback.lightImpact();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_controller.value * 0.2) - (_controller.value * 0.2),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isBookmarked
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isBookmarked
                      ? Colors.amber.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Icon(
                widget.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: widget.isBookmarked ? Colors.amber : Colors.grey,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===================== Rating Widget =====================
class _RatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingWidget({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          IconData icon;
          Color color;

          if (rating >= starValue) {
            icon = Icons.star_rounded;
            color = Colors.amber;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half_rounded;
            color = Colors.amber;
          } else {
            icon = Icons.star_outline_rounded;
            color = Colors.grey[300]!;
          }

          return Icon(icon, color: color, size: 16);
        }),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

// ===================== Content Type Badge =====================
class _ContentTypeBadge extends StatelessWidget {
  final String type;
  final Color color;
  final IconData icon;

  const _ContentTypeBadge({
    required this.type,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}