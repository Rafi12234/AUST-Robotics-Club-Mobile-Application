import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Creative Floating Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProgramHeaderDelegate(
              minHeight: 100,
              maxHeight: 280,
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
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
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
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
                          padding: const EdgeInsets.all(30),
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
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Programs Available',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back soon for exciting programs!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final programs = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                          padding: const EdgeInsets.only(bottom: 24),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left Side - Image/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: gradientColors[0],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.school,
                            size: 40,
                            color: gradientColors[0],
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.school,
                          size: 40,
                          color: gradientColors[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right Side - Text and Arrow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
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
    final progress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.5;

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
          // Animated Background Pattern
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

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 8,
            child: Container(
              // decoration: BoxDecoration(
              //   color: Colors.white.withOpacity(0.2),
              //   borderRadius: BorderRadius.circular(12),
              // ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Title Content
          Positioned(
            left: 20,
            right: 24,
            bottom: 24,
            child: Opacity(
              opacity: 1 - progress,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '📚 Learn & Grow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Educational Programs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mentorship & Training',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsed Title
          if (isCollapsed)
            Positioned(
              left: 70,
              bottom: 16,
              child: Opacity(
                opacity: (progress - 0.5) * 2,
                child: const Text(
                  'Educational, Mentorship and Training Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * 0.3 + i * 40;
      final amplitude = 20.0 * (1 - progress);
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
      final x = (i * 60.0) % size.width;
      final y = (i * 45.0) % size.height;
      canvas.drawCircle(Offset(x, y), 30, paint);
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
            expandedHeight: 200,
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
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final expandedHeight = 200.0;
                final collapsedHeight =
                    kToolbarHeight + MediaQuery.of(context).padding.top;
                final currentHeight = constraints.maxHeight;
                final collapseRatio = ((expandedHeight - currentHeight) /
                    (expandedHeight - collapsedHeight))
                    .clamp(0.0, 1.0);

                // Calculate left padding based on collapse ratio
                final leftPadding =
                    24.0 + (48.0 * collapseRatio); // Starts at 24, goes to 72

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
                  child: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.only(
                      left: leftPadding,
                      bottom: 13,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23 - (4 * collapseRatio), // Shrinks from 20 to 16
                        fontWeight: FontWeight.bold,
                        fontFamily: "font1"
                      ),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
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
                        ),
                        // Decorative Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DetailPatternPainter(),
                          ),
                        ),
                      ],
                    ),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 400,
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
                                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                              }
                              return Center(
                                child: SizedBox(
                                  height: Curves.easeInOut.transform(value) * 400,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B5E20)
                                        .withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
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
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 60,
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
                                        height: 100,
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
                                      bottom: 16,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              Colors.black.withOpacity(0.2),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '${index + 1} / ${images.length}',
                                          style: const TextStyle(
                                            fontSize: 10,
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
                    const SizedBox(height: 20),

                    // Modern Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 30 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
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
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1B5E20),
                                      Color(0xFF43A047),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Program Overview',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Description Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF1B5E20).withOpacity(0.1),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B5E20)
                                      .withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                color: Colors.grey[800],
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ] else ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'No description available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
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