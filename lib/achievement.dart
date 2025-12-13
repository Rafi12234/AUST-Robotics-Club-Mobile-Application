import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'size_config.dart';

// Main Achievement Page
class AchievementPage extends StatefulWidget {
  const AchievementPage({Key? key}) : super(key: key);

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Modern Sliver App Bar
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.2,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding:  EdgeInsets.only(left: SizeConfig.screenWidth * 0.03),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Colors.white, size:SizeConfig.screenWidth * 0.045),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate collapse ratio
                final expandedHeight = SizeConfig.screenHeight * 0.2;
                final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                final currentHeight = constraints.maxHeight;
                final collapseRatio = ((expandedHeight - currentHeight) /
                    (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

                // Calculate left padding based on collapse ratio
                final leftPadding = SizeConfig.screenWidth*0.04+ (40.0 * collapseRatio); // Starts at 20, goes to 60 when collapsed

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(
                    left: leftPadding,
                    bottom: SizeConfig.screenWidth * 0.03,
                  ),
                  title: Text(
                    'Achievements of AUSTRC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.screenWidth*0.055 - (5 * collapseRatio), // Shrinks from 28 to 16
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontFamily: "font1",
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
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
                      // Animated Pattern
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: AchievementPatternPainter(
                                animation: _controller.value,
                              ),
                            );
                          },
                        ),
                      ),
                      // Subtitle
                      // Positioned(
                      //   left: 20,
                      //   bottom: 50,
                      //   child: Text(
                      //     'Our Hall of Fame',
                      //     style: TextStyle(
                      //       color: Colors.white.withOpacity(0.9),
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Achievement List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Achievement')
                .collection('achievement')
                .orderBy('Order', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2E7D32).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
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
                        Icon(
                          Icons.error_outline_rounded,
                          size: SizeConfig.screenWidth * 0.25,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
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
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No achievements yet',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Great things are coming soon!',
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

              final achievements = snapshot.data!.docs;

              return SliverPadding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final achievement = achievements[index];
                      final data = achievement.data() as Map<String, dynamic>;
                      final name = data['Name'] ?? 'Untitled Achievement';
                      final description = data['Description'] ?? '';

                      // Get first image for preview
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
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding:  EdgeInsets.only(bottom: SizeConfig.screenWidth * 0.04),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                      AchievementDetailPage(
                                        achievementId: achievement.id,
                                        achievementData: data,
                                      ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var tween = Tween(
                                      begin: const Offset(0.0, 1.0),
                                      end: Offset.zero,
                                    ).chain(CurveTween(
                                        curve: Curves.easeOutCubic));

                                    var fadeIn = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeIn,
                                    ));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: FadeTransition(
                                        opacity: fadeIn,
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration:
                                  const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2E7D32)
                                        .withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Section
                                  if (previewImage != null)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: CachedNetworkImage(
                                              imageUrl: previewImage,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Color(0xFF2E7D32),
                                                      ),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child:  Icon(
                                                      Icons.emoji_events,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        // Trophy Badge
                                        Positioned(
                                          top: SizeConfig.screenWidth * 0.03,
                                          right: SizeConfig.screenWidth * 0.03,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFFFD700),
                                                  Color(0xFFFFA500),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child:  Icon(
                                              Icons.emoji_events,
                                              color: Colors.white,
                                              size: SizeConfig.screenWidth * 0.04,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      height: SizeConfig.screenWidth * 0.4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2E7D32)
                                                .withOpacity(0.2),
                                            const Color(0xFF43A047)
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.emoji_events,
                                          size: SizeConfig.screenWidth * 0.1,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),

                                  // Content Section
                                  Padding(
                                    padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: SizeConfig.screenWidth * 0.045,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1B5E20),
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: SizeConfig.screenWidth * 0.02),
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E7D32)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              child:  Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Color(0xFF2E7D32),
                                                size: SizeConfig.screenWidth * 0.04,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (description.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: SizeConfig.screenWidth * 0.033,
                                              color: Colors.grey[700],
                                              height: 1.5,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: achievements.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Achievement Detail Page
class AchievementDetailPage extends StatefulWidget {
  final String achievementId;
  final Map<String, dynamic> achievementData;

  const AchievementDetailPage({
    Key? key,
    required this.achievementId,
    required this.achievementData,
  }) : super(key: key);

  @override
  State<AchievementDetailPage> createState() => _AchievementDetailPageState();
}

class _AchievementDetailPageState extends State<AchievementDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getAllImages() {
    List<String> images = [];
    int imageIndex = 1;
    while (true) {
      final key = 'Image_$imageIndex';
      if (widget.achievementData.containsKey(key) &&
          widget.achievementData[key] != null &&
          widget.achievementData[key].toString().isNotEmpty) {
        images.add(widget.achievementData[key]);
        imageIndex++;
      } else {
        break;
      }
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.achievementData['Name'] ?? 'Untitled Achievement';
    final description = widget.achievementData['Description'] ?? 'No description available.';
    final images = _getAllImages();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern Header with Achievement Name
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.2,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.03),
              child: Container(
                // margin: const EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   shape: BoxShape.circle,
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.1),
                //       blurRadius: 8,
                //     ),
                //   ],
                // ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: Color(0xFFFFFFFF), size: SizeConfig.screenWidth * 0.045),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final isCollapsed = constraints.biggest.height <= kToolbarHeight + 50;

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
                        child: CustomPaint(
                          painter: AchievementDetailPatternPainter(),
                        ),
                      ),
                      // Content
                      FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsets.only(
                          left: isCollapsed ? 60 : 24,
                          right: 24,
                          bottom: isCollapsed ? 16 : 24,
                        ),
                        title: isCollapsed
                            ? Text(
                          name,
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : null,
                        background: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(SizeConfig.screenWidth*0.07, SizeConfig.screenWidth*0.02, SizeConfig.screenWidth*0.1,SizeConfig.screenWidth*0.04),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Achievement Badge
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 600),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: SizeConfig.screenWidth * 0.03,
                                          vertical: SizeConfig.screenWidth * 0.015,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFD700),
                                              Color(0xFFFFA500),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(25),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFD700)
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.emoji_events,
                                              color: Colors.white,
                                              size: SizeConfig.screenWidth * 0.03,
                                            ),
                                            SizedBox(width: SizeConfig.screenWidth * 0.015),
                                            Text(
                                              'Achievement Unlocked',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: SizeConfig.screenWidth * 0.026,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: SizeConfig.screenWidth * 0.02),
                                // Achievement Name
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    name,
                                    style:  TextStyle(
                                      color: Colors.white,
                                      fontSize: SizeConfig.screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.screenWidth * 0.001),

                  // Image Gallery
                  if (images.isNotEmpty) ...[
                    SizedBox(height: SizeConfig.screenWidth * 0.04),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.3,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween(begin: 0.8, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.025),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.01),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2E7D32)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: images[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
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
                                            child: Icon(
                                              Icons.broken_image,
                                              size: SizeConfig.screenWidth * 0.1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                    // Image Counter Badge
                                    Positioned(
                                      bottom: SizeConfig.screenWidth * 0.03,
                                      right: SizeConfig.screenWidth * 0.03,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: SizeConfig.screenWidth * 0.03,
                                          vertical: SizeConfig.screenWidth * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${index + 1}/${images.length}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: SizeConfig.screenWidth * 0.02,
                                            fontWeight: FontWeight.bold,
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
                    SizedBox(height: SizeConfig.screenWidth * 0.01),
                    // Page Indicators
                    if (images.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentImageIndex == index ? 32 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: _currentImageIndex == index
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFF1B5E20),
                                  Color(0xFF2E7D32),
                                ],
                              )
                                  : null,
                              color: _currentImageIndex == index
                                  ? null
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                  ],

                  // Description Section
                  SizedBox(height: SizeConfig.screenWidth * 0.06),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 28,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1B5E20),
                                    Color(0xFF2E7D32),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius:
                                BorderRadius.all(Radius.circular(3)),
                              ),
                            ),
                           SizedBox(width: SizeConfig.screenWidth * 0.02),
                            Text(
                              'About This Achievement',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.screenWidth * 0.03),
                        Container(
                          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: SizeConfig.screenWidth * 0.033,
                              color: Colors.grey[800],
                              height: 1.7,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: SizeConfig.screenWidth * 0.1),
                      ],
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

// Custom Painter for Achievement List Page Pattern
class AchievementPatternPainter extends CustomPainter {
  final double animation;

  AchievementPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final offset = animation * 50;
      canvas.drawCircle(
        Offset(size.width * 0.2 + offset, size.height * 0.3 + i * 40),
        20 + i * 10,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8 - offset, size.height * 0.6 + i * 30),
        15 + i * 8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for Achievement Detail Page Pattern
class AchievementDetailPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw star patterns
    for (int i = 0; i < 15; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 35.0) % size.height;
      _drawStar(canvas, Offset(x, y), 8, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 - 90) * math.pi / 180;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}