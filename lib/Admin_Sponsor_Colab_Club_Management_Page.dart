import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:math' as math;

// Theme colors (same as your existing theme)
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);

// ============================================
// MAIN PAGE - Sponsors & Collaborators Manager
// ============================================
class AdminSponsorsCollaboratorsPage extends StatefulWidget {
  const AdminSponsorsCollaboratorsPage({Key? key}) : super(key: key);

  @override
  State<AdminSponsorsCollaboratorsPage> createState() =>
      _AdminSponsorsCollaboratorsPageState();
}

class _AdminSponsorsCollaboratorsPageState
    extends State<AdminSponsorsCollaboratorsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    _card1Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _card2Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _headerController.forward();
    _cardsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  FadeTransition(
                    opacity: _headerAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: _buildHeaderSection(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sponsors Card
                  AnimatedBuilder(
                    animation: _card1Animation,
                    builder: (context, child) {
                      // ✅ FIX: Clamp values to valid range
                      final scale = (0.5 + (0.5 * _card1Animation.value)).clamp(0.0, 1.0);
                      final opacity = _card1Animation.value.clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      );
                    },
                    child: _CategoryCard(
                      title: 'Sponsors',
                      subtitle: 'Manage sponsor logos & images',
                      icon: Icons.handshake_rounded,
                      gradientColors: [kGreenMain, kGreenLight],
                      documentName: 'Sponsor_Images',
                      onTap: () => _navigateToImageManager(
                        context,
                        'Sponsors',
                        'Sponsor_Images',
                        Icons.handshake_rounded,
                        [kGreenMain, kGreenLight],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Collaborated Clubs Card
                  AnimatedBuilder(
                    animation: _card2Animation,
                    builder: (context, child) {
                      // ✅ FIX: Clamp values to valid range
                      final scale = (0.5 + (0.5 * _card2Animation.value)).clamp(0.0, 1.0);
                      final opacity = _card2Animation.value.clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      );
                    },
                    child: _CategoryCard(
                      title: 'Collaborated Clubs',
                      subtitle: 'Manage partner club logos',
                      icon: Icons.groups_rounded,
                      gradientColors: [kAccentGold, const Color(0xFFFF8C00)],
                      documentName: 'Collaborated_Clubs',
                      onTap: () => _navigateToImageManager(
                        context,
                        'Collaborated Clubs',
                        'Collaborated_Clubs',
                        Icons.groups_rounded,
                        [kAccentGold, const Color(0xFFFF8C00)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Quick Stats Section
                  _buildQuickStats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
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
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
          title: const Text(
            'Partners & Sponsors',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          background: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.handshake_rounded,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kGreenMain.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kGreenMain.withOpacity(0.1), kGreenLight.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.image_rounded,
              size: 32,
              color: kGreenMain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Image Manager',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload and manage carousel images',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kGreenDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                documentName: 'Sponsor_Images',
                label: 'Sponsors',
                icon: Icons.handshake_rounded,
                color: kGreenMain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                documentName: 'Collaborated_Clubs',
                label: 'Collaborators',
                icon: Icons.groups_rounded,
                color: kAccentGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToImageManager(
      BuildContext context,
      String title,
      String documentName,
      IconData icon,
      List<Color> gradientColors,
      ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageManagerPage(
              title: title,
              documentName: documentName,
              icon: icon,
              gradientColors: gradientColors,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
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
}

// ============================================
// CATEGORY CARD WIDGET
// ============================================
class _CategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String documentName;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.documentName,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[0].withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Image count badge
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('All_Data')
                          .doc(widget.documentName)
                          .snapshots(),
                      builder: (context, snapshot) {
                        int imageCount = 0;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            imageCount = data.keys
                                .where((key) => key.startsWith('Image_'))
                                .length;
                          }
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$imageCount images',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
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
// STAT CARD WIDGET
// ============================================
class _StatCard extends StatelessWidget {
  final String documentName;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.documentName,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('All_Data')
          .doc(documentName)
          .snapshots(),
      builder: (context, snapshot) {
        int imageCount = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            imageCount =
                data.keys.where((key) => key.startsWith('Image_')).length;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                imageCount.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================
// IMAGE MANAGER PAGE
// ============================================
class ImageManagerPage extends StatefulWidget {
  final String title;
  final String documentName;
  final IconData icon;
  final List<Color> gradientColors;

  const ImageManagerPage({
    Key? key,
    required this.title,
    required this.documentName,
    required this.icon,
    required this.gradientColors,
  }) : super(key: key);

  @override
  State<ImageManagerPage> createState() => _ImageManagerPageState();
}

class _ImageManagerPageState extends State<ImageManagerPage>
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildImagesHeader(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildImagesGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: widget.gradientColors[0],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradientColors,
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          background: Stack(
            children: [
              // Decorative pattern
              Positioned(
                right: -50,
                top: 20,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    widget.icon,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              // Floating circles
              Positioned(
                left: 30,
                bottom: 60,
                child: _FloatingCircle(
                  size: 60,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                right: 100,
                top: 80,
                child: _FloatingCircle(
                  size: 40,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.gradientColors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kGreenDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Images will appear in the homepage carousel. Tap + to add, long-press to delete.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
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

  Widget _buildImagesHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.gradientColors[0].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.photo_library_rounded,
            color: widget.gradientColors[0],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Uploaded Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kGreenDark,
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('All_Data')
              .doc(widget.documentName)
              .snapshots(),
          builder: (context, snapshot) {
            int count = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                count =
                    data.keys.where((key) => key.startsWith('Image_')).length;
              }
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.gradientColors[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.gradientColors[0],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImagesGrid() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('All_Data')
          .doc(widget.documentName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        Map<String, String> images = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              if (key.startsWith('Image_') && value is String) {
                images[key] = value;
              }
            });
          }
        }

        if (images.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        // Sort images by number
        final sortedKeys = images.keys.toList()
          ..sort((a, b) {
            final numA = int.tryParse(a.replaceAll('Image_', '')) ?? 0;
            final numB = int.tryParse(b.replaceAll('Image_', '')) ?? 0;
            return numA.compareTo(numB);
          });

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final key = sortedKeys[index];
                final url = images[key]!;
                return _ImageCard(
                  fieldName: key,
                  imageUrl: url,
                  documentName: widget.documentName,
                  gradientColors: widget.gradientColors,
                  index: index,
                );
              },
              childCount: sortedKeys.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value.clamp(0.0, 1.5), // Allow overshoot for elastic
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.gradientColors[0].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 80,
                color: widget.gradientColors[0],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Images Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kGreenDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to upload your first image',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeOut,
      ),
      child: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadNewImage,
        backgroundColor: widget.gradientColors[0],
        icon: _isUploading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.add_photo_alternate_rounded),
        label: Text(
          _isUploading ? 'Uploading...' : 'Add Image',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _uploadNewImage() async {
    try {
      setState(() => _isUploading = true);

      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Upload to Cloudinary
      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: widget.documentName.toLowerCase(),
        ),
      );

      // Get current document to find next image number
      final doc = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc(widget.documentName)
          .get();

      int nextNumber = 1;
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final existingKeys = data.keys
              .where((key) => key.startsWith('Image_'))
              .map((key) => int.tryParse(key.replaceAll('Image_', '')) ?? 0)
              .toList();
          if (existingKeys.isNotEmpty) {
            nextNumber = existingKeys.reduce(math.max) + 1;
          }
        }
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc(widget.documentName)
          .set(
        {'Image_$nextNumber': response.secureUrl},
        SetOptions(merge: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Image uploaded successfully!'),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}

// ============================================
// IMAGE CARD WIDGET
// ============================================
class _ImageCard extends StatefulWidget {
  final String fieldName;
  final String imageUrl;
  final String documentName;
  final List<Color> gradientColors;
  final int index;

  const _ImageCard({
    required this.fieldName,
    required this.imageUrl,
    required this.documentName,
    required this.gradientColors,
    required this.index,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // ✅ FIX: Clamp values to valid range
        final animValue = _controller.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.5 + (0.5 * animValue),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: _showDeleteDialog,
        onTap: () => _showImagePreview(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[0].withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.broken_image_rounded,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
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
              ),

              // Image number badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.gradientColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${widget.fieldName.replaceAll('Image_', '')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Delete button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _showDeleteDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Bottom info
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to preview',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete Image'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete this image? This action cannot be undone.',
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteImage();
    }
  }

  Future<void> _deleteImage() async {
    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc(widget.documentName)
          .update({widget.fieldName: FieldValue.delete()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Image deleted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}

// ============================================
// FLOATING CIRCLE DECORATION
// ============================================
class _FloatingCircle extends StatefulWidget {
  final double size;
  final Color color;

  const _FloatingCircle({
    required this.size,
    required this.color,
  });

  @override
  State<_FloatingCircle> createState() => _FloatingCircleState();
}

class _FloatingCircleState extends State<_FloatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.sin(_controller.value * math.pi * 2) * 5,
            math.cos(_controller.value * math.pi * 2) * 5,
          ),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}