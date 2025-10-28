import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

// Main Best Panel Members Page - Semester List
class BestPanelMembersPage extends StatefulWidget {
  const BestPanelMembersPage({Key? key}) : super(key: key);

  @override
  State<BestPanelMembersPage> createState() => _BestPanelMembersPageState();
}

class _BestPanelMembersPageState extends State<BestPanelMembersPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hall of Excellence',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Best Panel Members',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Trophy Icon
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating glow rings
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.amber
                                    .withOpacity(0.4 * _glowController.value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Trophy Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Select a semester to view our outstanding performers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Semester List - Dynamically fetched
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('All_Data')
                      .doc('Best Panel Members')
                      .collection('Semesters')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load semesters',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final semesters = snapshot.data?.docs ?? [];

                    if (semesters.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.calendar_today_outlined,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No semesters available yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: semesters.length,
                      itemBuilder: (context, index) {
                        final semesterDoc = semesters[index];
                        final semesterName = semesterDoc.id;

                        return TweenAnimationBuilder<double>(
                          duration:
                          Duration(milliseconds: 400 + (index * 100)),
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
                          child: _buildSemesterCard(
                            context,
                            semesterName,
                            index,
                          ),
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

  Widget _buildSemesterCard(BuildContext context, String semester, int index) {
    final colors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
    ];
    final cardColor = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PanelMembersDetailPage(semester: semester),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var scaleTween = Tween<double>(begin: 0.8, end: 1.0);
                var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                return ScaleTransition(
                  scale: animation.drive(
                      scaleTween.chain(CurveTween(curve: Curves.easeOutCubic))),
                  child: FadeTransition(
                    opacity: animation.drive(fadeTween),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cardColor[1].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Medal Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cardColor,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor[1].withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Semester Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View Outstanding Members',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF1B5E20),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Panel Members Detail Page
class PanelMembersDetailPage extends StatefulWidget {
  final String semester;

  const PanelMembersDetailPage({Key? key, required this.semester})
      : super(key: key);

  @override
  State<PanelMembersDetailPage> createState() => _PanelMembersDetailPageState();
}

class _PanelMembersDetailPageState extends State<PanelMembersDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showTitle = false;
  List<DocumentSnapshot>? _cachedTeams;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset > 100 && !_showTitle) {
          setState(() => _showTitle = true);
        } else if (_scrollController.offset <= 100 && _showTitle) {
          setState(() => _showTitle = false);
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Curved Header
          SliverAppBar(
            expandedHeight: 180,
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
                final expandedHeight = 180.0;
                final collapsedHeight =
                    kToolbarHeight + MediaQuery.of(context).padding.top;
                final currentHeight = constraints.maxHeight;
                final collapseRatio = ((expandedHeight - currentHeight) /
                    (expandedHeight - collapsedHeight))
                    .clamp(0.0, 1.0);

                final leftPadding = 24.0 + (48.0 * collapseRatio);

                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1B5E20),
                        Color(0xFF2E7D32),
                        Color(0xFF43A047),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative Stars
                      ...List.generate(20, (index) {
                        return Positioned(
                          left: (index * 37.3) %
                              MediaQuery.of(context).size.width,
                          top: (index * 23.7) % 180,
                          child: Icon(
                            Icons.star,
                            size: 10 + (index % 3) * 5,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        );
                      }),
                      // Title
                      Positioned(
                        left: leftPadding,
                        right: 24,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              // decoration: BoxDecoration(
                              //   color: Colors.amber.withOpacity(0.2),
                              //   borderRadius: BorderRadius.circular(20),
                              //   border: Border.all(
                              //     color: Colors.amber.withOpacity(0.5),
                              //     width: 1.5,
                              //   ),
                              // ),
                              // child: Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: const [
                              //     Icon(Icons.emoji_events,
                              //         color: Colors.amber, size: 16),
                              //     SizedBox(width: 6),
                              //     Text(
                              //       'Best Performers',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 12,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  widget.semester,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28 - (8 * collapseRatio),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "font1"
                                  ),
                                ),
                                Text(
                                  "'s Best Panel Members",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28 - (8 * collapseRatio),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "font1"
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Team Members List - FIXED VERSION
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Best Panel Members')
                .collection('Semesters')
                .doc(widget.semester)
                .collection('Informations')
                .snapshots(),
            builder: (context, snapshot) {
              // Update cache only when data actually changes
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                _cachedTeams = snapshot.data!.docs;
              }

              if (snapshot.connectionState == ConnectionState.waiting && _cachedTeams == null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load members',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_cachedTeams == null || _cachedTeams!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.people_outline,
                              size: 80, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No members found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final teams = _cachedTeams!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final team = teams[index];
                    final data = team.data() as Map<String, dynamic>;
                    final teamName = team.id;
                    final memberName = data['Name'] ?? 'Unknown';
                    final imageUrl = data['Image'] ?? '';
                    final department = data['Department'] ?? 'N/A';

                    return _buildMemberCard(
                      teamName,
                      memberName,
                      imageUrl,
                      department,
                      index,
                    );
                  },
                  childCount: teams.length,
                ),
              );
            },
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
      String teamName,
      String memberName,
      String imageUrl,
      String department,
      int index,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Team Name Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      teamName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Best',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Member Image with Decorative Border
            Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative circles
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1B5E20).withOpacity(0.1),
                          const Color(0xFF43A047).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Image Container
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                        errorWidget: (context, url, error) =>
                            Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Star badge
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Member Info
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Text(
                    memberName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1B5E20).withOpacity(0.1),
                          const Color(0xFF43A047).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          color: Color(0xFF1B5E20),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          department,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
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