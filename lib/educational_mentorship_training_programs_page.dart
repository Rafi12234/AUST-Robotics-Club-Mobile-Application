import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'size_config.dart';

// Main Educational Programs List Page
class EducationalProgramsPage extends StatefulWidget {
  const EducationalProgramsPage({Key? key}) : super(key: key);

  @override
  State<EducationalProgramsPage> createState() =>
      _EducationalProgramsPageState();
}

class _EducationalProgramsPageState extends State<EducationalProgramsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Creative Floating Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProgramHeaderDelegate(
              minHeight: SizeConfig.screenHeight* 0.1,
              maxHeight: SizeConfig.screenWidth * 0.55,
              animation: _headerController,
            ),
          ),

          // Programs List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Educational, Mentorship & Training Programs')
                .collection('educational, mentorship & training programs')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.2,
                          height: SizeConfig.screenWidth * 0.2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            ),
                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: SizeConfig.screenWidth * 0.008,
                            ),
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
                        Container(
                          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: SizeConfig.screenWidth * 0.15,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.025),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.075),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1B5E20).withOpacity(0.1),
                                const Color(0xFF43A047).withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: SizeConfig.screenWidth * 0.2,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.03),
                        Text(
                          'No Programs Available',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.01),
                        Text(
                          'Check back soon for exciting programs!',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.035,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort programs by Order field
              final programs = snapshot.data!.docs.toList();
              programs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                // Get Order values, default to a large number if not present
                final aOrder = aData['Order'] ?? 999999;
                final bOrder = bData['Order'] ?? 999999;

                // Convert to int if they're stored as strings or other types
                int aOrderInt;
                int bOrderInt;

                try {
                  aOrderInt = aOrder is int ? aOrder : int.parse(aOrder.toString());
                } catch (e) {
                  aOrderInt = 999999;
                }

                try {
                  bOrderInt = bOrder is int ? bOrder : int.parse(bOrder.toString());
                } catch (e) {
                  bOrderInt = 999999;
                }

                return aOrderInt.compareTo(bOrderInt);
              });

              return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  SizeConfig.screenWidth * 0.03,
                  SizeConfig.screenHeight * 0.015,
                  SizeConfig.screenWidth * 0.03,
                  SizeConfig.screenHeight * 0.015,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final program = programs[index];
                      final data = program.data() as Map<String, dynamic>;
                      final name = data['Name'] ?? 'Untitled Program';

                      // Get first image
                      String? previewImage;
                      for (int i = 1; i <= 10; i++) {
                        if (data.containsKey('Image_$i') &&
                            data['Image_$i'] != null &&
                            data['Image_$i'].toString().isNotEmpty) {
                          previewImage = data['Image_$i'];
                          break;
                        }
                      }

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 150)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(50 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.015),
                          child: _buildProgramCard(
                            context,
                            name,
                            previewImage,
                            index,
                                () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) =>
                                      ProgramDetailPage(
                                        programId: program.id,
                                        programData: data,
                                      ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutQuart;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);
                                    var fadeAnimation = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(animation);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: FadeTransition(
                                        opacity: fadeAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration:
                                  const Duration(milliseconds: 600),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    childCount: programs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(
      BuildContext context,
      String name,
      String? imageUrl,
      int index,
      VoidCallback onTap,
      ) {
    final colors = [
      [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      [const Color(0xFF2E7D32), const Color(0xFF43A047)],
      [const Color(0xFF388E3C), const Color(0xFF4CAF50)],
    ];
    final gradientColors = colors[index % colors.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.06),
      child: Container(
        height: SizeConfig.screenHeight * 0.14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0],
              gradientColors[1],
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: SizeConfig.screenWidth * 0.05,
              offset: Offset(0, SizeConfig.screenHeight * 0.012),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circles
            Positioned(
              right: -SizeConfig.screenWidth * 0.05,
              top: -SizeConfig.screenWidth * 0.05,
              child: Container(
                width: SizeConfig.screenWidth * 0.25,
                height: SizeConfig.screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -SizeConfig.screenWidth * 0.075,
              bottom: -SizeConfig.screenWidth * 0.075,
              child: Container(
                width: SizeConfig.screenWidth * 0.3,
                height: SizeConfig.screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
              child: Row(
                children: [
                  // Left Side - Image/Icon
                  Container(
                    width: SizeConfig.screenWidth * 0.22,
                    height: SizeConfig.screenWidth * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: SizeConfig.screenWidth * 0.025,
                          offset: Offset(0, SizeConfig.screenHeight * 0.006),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                      child: imageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: SizeConfig.screenWidth * 0.005,
                              color: gradientColors[0],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.school,
                            size: SizeConfig.screenWidth * 0.1,
                            color: gradientColors[0],
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.school,
                          size: SizeConfig.screenWidth * 0.1,
                          color: gradientColors[0],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.04),

                  // Right Side - Text and Arrow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.043,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.01),
                        Row(
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.028,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: SizeConfig.screenWidth * 0.01),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: SizeConfig.screenWidth * 0.04,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ],
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

// Custom Header Delegate with Animation
class _ProgramHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final AnimationController animation;

  _ProgramHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.animation,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.7;

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
          // Animated Background Pattern (only when expanded)
          if (!isCollapsed)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WavePatternPainter(
                      animation: animation.value,
                      progress: progress,
                    ),
                  );
                },
              ),
            ),

          // Back Button - Always properly positioned
          Positioned(
            top: MediaQuery.of(context).padding.top + SizeConfig.screenHeight * 0.008,
            left: SizeConfig.screenWidth * 0.03,
            child: Container(
              width: SizeConfig.screenWidth * 0.1,
              height: SizeConfig.screenWidth * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: SizeConfig.screenWidth * 0.045,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),

          // Expanded Title Content (fades out when scrolling)
          if (!isCollapsed)
            Positioned(
              left: SizeConfig.screenWidth * 0.05,
              right: SizeConfig.screenWidth * 0.06,
              bottom: SizeConfig.screenHeight * 0.025,
              child: Opacity(
                opacity: (1 - progress * 1.5).clamp(0.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.screenWidth * 0.03,
                        vertical: SizeConfig.screenHeight * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                      ),
                      child: Text(
                        '📚 Learn & Grow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.015),
                    Text(
                      'Educational Programs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.006),
                    Text(
                      'Mentorship & Training',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: SizeConfig.screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Collapsed Title - Centered in AppBar
          if (isCollapsed)
            Positioned(
              top: MediaQuery.of(context).padding.top + SizeConfig.screenHeight * 0.02,
              left: SizeConfig.screenWidth * 0.15,
              right: SizeConfig.screenWidth * 0.05,
              child: Opacity(
                opacity: ((progress - 0.7) * 3.3).clamp(0.0, 1.0),
                child: Text(
                  'Educational & Training Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

// Custom Wave Pattern Painter
class _WavePatternPainter extends CustomPainter {
  final double animation;
  final double progress;

  _WavePatternPainter({required this.animation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.005;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * 0.3 + i * (size.height * 0.08);
      final amplitude = size.height * 0.04 * (1 - progress);
      final frequency = 0.02;

      path.moveTo(0, y);

      for (double x = 0; x <= size.width; x++) {
        final yOffset = math.sin((x * frequency) + (animation * 2 * math.pi) +
            (i * math.pi / 3)) *
            amplitude;
        path.lineTo(x, y + yOffset);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Detail Page Pattern Painter
class _DetailPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 8; i++) {
      final x = (i * size.width * 0.15) % size.width;
      final y = (i * size.height * 0.15) % size.height;
      canvas.drawCircle(Offset(x, y), size.width * 0.075, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Program Detail Page
class ProgramDetailPage extends StatefulWidget {
  final String programId;
  final Map<String, dynamic> programData;

  const ProgramDetailPage({
    Key? key,
    required this.programId,
    required this.programData,
  }) : super(key: key);

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getAllImages() {
    List<String> images = [];
    int imageIndex = 1;
    while (true) {
      final key = 'Image_$imageIndex';
      if (widget.programData.containsKey(key) &&
          widget.programData[key] != null &&
          widget.programData[key].toString().isNotEmpty) {
        images.add(widget.programData[key]);
        imageIndex++;
      } else {
        break;
      }
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final name = widget.programData['Name'] ?? 'Untitled Program';
    final description = widget.programData['Description'] ?? '';
    final images = _getAllImages();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern Curved App Bar
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.2,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: SizeConfig.screenWidth * 0.045),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final expandedHeight = SizeConfig.screenHeight * 0.2;
                final collapsedHeight =
                    kToolbarHeight + MediaQuery.of(context).padding.top;
                final currentHeight = constraints.maxHeight;
                final collapseRatio = ((expandedHeight - currentHeight) /
                    (expandedHeight - collapsedHeight))
                    .clamp(0.0, 1.0);

                final isCollapsed = collapseRatio > 0.7;

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
                      // Decorative Pattern (only when expanded)
                      if (!isCollapsed)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DetailPatternPainter(),
                          ),
                        ),

                      // Expanded Title (fades out when scrolling)
                      if (!isCollapsed)
                        Positioned(
                          left: SizeConfig.screenWidth * 0.05,
                          right: SizeConfig.screenWidth * 0.05,
                          bottom: SizeConfig.screenHeight * 0.02,
                          child: Opacity(
                            opacity: (1 - collapseRatio * 1.5).clamp(0.0, 1.0),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.screenWidth * 0.065,
                                fontWeight: FontWeight.bold,
                                fontFamily: "font1",
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      // Collapsed Title - Centered next to back button
                      if (isCollapsed)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + SizeConfig.screenHeight * 0.018,
                          left: SizeConfig.screenWidth * 0.15,
                          right: SizeConfig.screenWidth * 0.05,
                          child: Opacity(
                            opacity: ((collapseRatio - 0.7) * 3.3).clamp(0.0, 1.0),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                fontFamily: "font1",
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images Gallery with 3D Effect
                  if (images.isNotEmpty) ...[
                    SizedBox(height: SizeConfig.screenHeight * 0.02),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.4,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value =
                                    (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                              }
                              return Center(
                                child: SizedBox(
                                  height:
                                  Curves.easeInOut.transform(value) * SizeConfig.screenHeight * 0.4,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.015),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B5E20)
                                        .withOpacity(0.2),
                                    blurRadius: SizeConfig.screenWidth * 0.05,
                                    offset: Offset(0, SizeConfig.screenHeight * 0.015),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: images[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey[200]!,
                                              Colors.grey[300]!,
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.broken_image,
                                              size: SizeConfig.screenWidth * 0.12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                    // Gradient Overlay
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: SizeConfig.screenHeight * 0.08,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Image Counter
                                    Positioned(
                                      bottom: SizeConfig.screenHeight * 0.015,
                                      right: SizeConfig.screenWidth * 0.03,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: SizeConfig.screenWidth * 0.025,
                                          vertical: SizeConfig.screenHeight * 0.006,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(SizeConfig.screenWidth * 0.035),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.2),
                                              blurRadius: SizeConfig.screenWidth * 0.02,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '${index + 1} / ${images.length}',
                                          style: TextStyle(
                                            fontSize: SizeConfig.screenWidth * 0.022,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.018),

                    // Modern Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.008),
                          width: _currentPage == index ? SizeConfig.screenWidth * 0.06 : SizeConfig.screenWidth * 0.018,
                          height: SizeConfig.screenWidth * 0.018,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.009),
                            gradient: _currentPage == index
                                ? const LinearGradient(
                              colors: [
                                Color(0xFF1B5E20),
                                Color(0xFF43A047),
                              ],
                            )
                                : null,
                            color: _currentPage == index
                                ? null
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Description Section
                  if (description.isNotEmpty) ...[
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.045),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                width: SizeConfig.screenWidth * 0.012,
                                height: SizeConfig.screenHeight * 0.028,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1B5E20),
                                      Color(0xFF43A047),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.006),
                                ),
                              ),
                              SizedBox(width: SizeConfig.screenWidth * 0.025),
                              Text(
                                'Program Overview',
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.048,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.018),

                          // Description Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(SizeConfig.screenWidth * 0.045),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.045),
                              border: Border.all(
                                color:
                                const Color(0xFF1B5E20).withOpacity(0.1),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B5E20)
                                      .withOpacity(0.05),
                                  blurRadius: SizeConfig.screenWidth * 0.04,
                                  offset: Offset(0, SizeConfig.screenHeight * 0.008),
                                ),
                              ],
                            ),
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.036,
                                height: 1.7,
                                color: Colors.grey[800],
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.04),
                  ] else ...[
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.screenWidth * 0.04,
                          vertical: SizeConfig.screenHeight * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                        ),
                        child: Text(
                          'No description available',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.032,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.04),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}