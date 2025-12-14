import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:math' as math;

// Brand colors
const Color kBrandStart = Color(0xFF0B6B3A);
const Color kBrandEnd = Color(0xFF16A34A);
const Color kDarkGreen = Color(0xFF004D40);
const Color kLightGreen = Color(0xFF81C784);
const Color kAccentGold = Color(0xFFFFB703);

class AdminHighlightsPage extends StatefulWidget {
  const AdminHighlightsPage({Key? key}) : super(key: key);

  @override
  State<AdminHighlightsPage> createState() => _AdminHighlightsPageState();
}

class _AdminHighlightsPageState extends State<AdminHighlightsPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _waveController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  // Selected image for preview
  String? _previewImageUrl;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _headerSlide = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  void _startAnimationSequence() {
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : kBrandStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Get document reference
  DocumentReference get _highlightsDoc => FirebaseFirestore.instance
      .collection('All_Data')
      .doc('Top_News_of_AUSTRC');

  // Upload new image
  Future<void> _uploadNewImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);
      HapticFeedback.mediumImpact();

      // Upload to Cloudinary
      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'highlights'),
      );

      final imageUrl = response.secureUrl;

      // Get current data to find next News number
      final doc = await _highlightsDoc.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};

      // Find next available News_X number
      int nextNumber = 1;
      while (data.containsKey('News_$nextNumber')) {
        nextNumber++;
      }

      // Add new image
      await _highlightsDoc.set(
        {'News_$nextNumber': imageUrl},
        SetOptions(merge: true),
      );

      _showSnackBar('Highlight added successfully!');
    } catch (e) {
      _showSnackBar('Error uploading image: $e', isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Delete image
  Future<void> _deleteImage(String fieldName) async {
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            const Text('Delete Highlight'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this highlight? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        HapticFeedback.mediumImpact();

        // Delete the field
        await _highlightsDoc.update({fieldName: FieldValue.delete()});

        // Reorganize remaining fields
        await _reorganizeFields();

        _showSnackBar('Highlight deleted successfully!');
      } catch (e) {
        _showSnackBar('Error deleting highlight: $e', isError: true);
      }
    }
  }

  // Reorganize fields after deletion to maintain sequential numbering
  Future<void> _reorganizeFields() async {
    try {
      final doc = await _highlightsDoc.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};

      // Extract all News_X entries
      final List<MapEntry<int, String>> newsEntries = [];
      data.forEach((key, value) {
        if (key.startsWith('News_') && value is String) {
          final number = int.tryParse(key.replaceFirst('News_', ''));
          if (number != null) {
            newsEntries.add(MapEntry(number, value));
          }
        }
      });

      // Sort by number
      newsEntries.sort((a, b) => a.key.compareTo(b.key));

      // Create new organized data
      final Map<String, dynamic> newData = {};
      for (int i = 0; i < newsEntries.length; i++) {
        newData['News_${i + 1}'] = newsEntries[i].value;
      }

      // Clear and set new data
      await _highlightsDoc.set(newData);
    } catch (e) {
      debugPrint('Error reorganizing fields: $e');
    }
  }

  // Replace existing image
  Future<void> _replaceImage(String fieldName) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);
      HapticFeedback.mediumImpact();

      // Upload to Cloudinary
      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'highlights'),
      );

      // Update the field
      await _highlightsDoc.update({fieldName: response.secureUrl});

      _showSnackBar('Highlight updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating image: $e', isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Show image preview
  void _showImagePreview(String imageUrl) {
    HapticFeedback.lightImpact();
    setState(() {
      _previewImageUrl = imageUrl;
      _showPreview = true;
    });
  }

  // Close image preview
  void _closeImagePreview() {
    HapticFeedback.lightImpact();
    setState(() {
      _showPreview = false;
      _previewImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(topInset),
              Expanded(
                child: Stack(
                  children: [
                    _AnimatedBackground(
                      waveController: _waveController,
                      particleController: _particleController,
                    ),
                    _buildContent(),
                  ],
                ),
              ),
            ],
          ),

          // Upload Loading Overlay
          if (_isUploading) _buildUploadingOverlay(),

          // Image Preview Overlay
          if (_showPreview && _previewImageUrl != null)
            _buildImagePreviewOverlay(),
        ],
      ),
      floatingActionButton: _AddHighlightButton(
        onTap: _uploadNewImage,
        isLoading: _isUploading,
      ),
    );
  }

  Widget _buildHeader(double topInset) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(
            opacity: _headerFade.value.clamp(0.0, 1.0),
            child: Container(
              height: 140 + topInset,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(30 * (1 - value), 0),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: child,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Manage Highlights',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  );
                                },
                                child: Text(
                                  'Top News Carousel - Admin Panel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StaticHeaderBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _highlightsDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        // Extract and sort News entries
        final List<MapEntry<String, String>> highlights = [];
        data.forEach((key, value) {
          if (key.startsWith('News_') && value is String && value.isNotEmpty) {
            highlights.add(MapEntry(key, value));
          }
        });

        // Sort by number
        highlights.sort((a, b) {
          final numA = int.tryParse(a.key.replaceFirst('News_', '')) ?? 0;
          final numB = int.tryParse(b.key.replaceFirst('News_', '')) ?? 0;
          return numA.compareTo(numB);
        });

        if (highlights.isEmpty) {
          return _buildEmptyState();
        }

        return _buildHighlightsList(highlights);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBrandStart.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kBrandStart),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading highlights...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value.clamp(0.0, 1.2),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: kBrandStart.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  size: 80,
                  color: kBrandStart.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Highlights Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + button to add your\nfirst highlight image',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsList(List<MapEntry<String, String>> highlights) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Card
        _buildStatsCard(highlights.length),
        const SizedBox(height: 24),

        // Info Card
        _buildInfoCard(),
        const SizedBox(height: 24),

        // Section Header
        _buildSectionHeader(),
        const SizedBox(height: 16),

        // Highlight Cards
        ...highlights.asMap().entries.map((entry) {
          final index = entry.key;
          final highlight = entry.value;
          return _HighlightCard(
            fieldName: highlight.key,
            imageUrl: highlight.value,
            index: index,
            onPreview: () => _showImagePreview(highlight.value),
            onReplace: () => _replaceImage(highlight.key),
            onDelete: () => _deleteImage(highlight.key),
          );
        }).toList(),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatsCard(int totalHighlights) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kBrandStart.withOpacity(0.1),
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
                gradient: const LinearGradient(
                  colors: [kBrandStart, kBrandEnd],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalHighlights',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kBrandStart,
                    ),
                  ),
                  Text(
                    'Active Highlights',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.view_carousel_rounded,
                color: kAccentGold,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.blue,
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
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'These images appear in the carousel on the home screen. Add, replace, or delete images to update the highlights.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
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

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBrandStart.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.photo_library_rounded,
            color: kBrandStart,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'All Highlights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B4332),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kAccentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.touch_app_rounded, color: kAccentGold, size: 16),
              SizedBox(width: 4),
              Text(
                'Tap image to preview',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kAccentGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kBrandStart.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(kBrandStart),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Uploading Image...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B4332),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we upload your image',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewOverlay() {
    return GestureDetector(
      onTap: _closeImagePreview,
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            // Image
            Center(
              child: Hero(
                tag: 'preview_$_previewImageUrl',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CachedNetworkImage(
                      imageUrl: _previewImageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: GestureDetector(
                onTap: _closeImagePreview,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Hint
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Pinch to zoom • Tap to close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// HIGHLIGHT CARD
// ============================================
class _HighlightCard extends StatefulWidget {
  final String fieldName;
  final String imageUrl;
  final int index;
  final VoidCallback onPreview;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const _HighlightCard({
    required this.fieldName,
    required this.imageUrl,
    required this.index,
    required this.onPreview,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final highlightNumber = widget.fieldName.replaceFirst('News_', '');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onPreview();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: kBrandStart.withOpacity(_isPressed ? 0.2 : 0.1),
                  blurRadius: _isPressed ? 25 : 20,
                  offset: Offset(0, _isPressed ? 12 : 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(kBrandStart),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Number Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kBrandStart, kBrandEnd],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kBrandStart.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Highlight #$highlightNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Preview Hint
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: kBrandStart,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Tap to preview',
                              style: TextStyle(
                                color: kBrandStart,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Replace',
                          color: kBrandStart,
                          onTap: widget.onReplace,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete_rounded,
                          label: 'Delete',
                          color: Colors.redAccent,
                          isOutlined: true,
                          onTap: widget.onDelete,
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
    );
  }
}

// ============================================
// ACTION BUTTON
// ============================================
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.isOutlined
              ? Colors.transparent
              : widget.color.withOpacity(_isPressed ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.6 : 0.3),
            width: 2,
          ),
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ADD HIGHLIGHT BUTTON
// ============================================
class _AddHighlightButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _AddHighlightButton({
    required this.onTap,
    required this.isLoading,
  });

  @override
  State<_AddHighlightButton> createState() => _AddHighlightButtonState();
}

class _AddHighlightButtonState extends State<_AddHighlightButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      ),
      child: GestureDetector(
        onTapDown: widget.isLoading
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isLoading
            ? null
            : (_) {
          setState(() => _isPressed = false);
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? LinearGradient(
              colors: [Colors.grey[400]!, Colors.grey[500]!],
            )
                : const LinearGradient(
              colors: [kBrandStart, kBrandEnd],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: widget.isLoading
                    ? Colors.grey.withOpacity(0.3)
                    : kBrandStart.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.isLoading ? 'Uploading...' : 'Add Highlight',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
// STATIC HEADER BADGE
// ============================================
class _StaticHeaderBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

// ============================================
// ANIMATED BACK BUTTON
// ============================================
class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.onTap});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ============================================
// ANIMATED BACKGROUND
// ============================================
class _AnimatedBackground extends StatelessWidget {
  final AnimationController waveController;
  final AnimationController particleController;

  const _AnimatedBackground({
    required this.waveController,
    required this.particleController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE8F5E9),
                Color(0xFFF1F8E9),
                Color(0xFFFAFAFA),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: _WaveBackgroundPainter(animation: waveController.value),
              size: Size.infinite,
            );
          },
        ),
        AnimatedBuilder(
          animation: particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(animation: particleController.value),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

// ============================================
// WAVE BACKGROUND PAINTER
// ============================================
class _WaveBackgroundPainter extends CustomPainter {
  final double animation;

  _WaveBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          kBrandStart.withOpacity(0.03),
          kBrandEnd.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (var i = 0; i <= size.width; i++) {
      final y = size.height * 0.7 +
          math.sin((i / size.width * 4 * math.pi) + (animation * 2 * math.pi)) *
              30 +
          math.sin((i / size.width * 2 * math.pi) + (animation * math.pi)) * 20;
      path.lineTo(i.toDouble(), y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

// ============================================
// PARTICLE PAINTER
// ============================================
class _ParticlePainter extends CustomPainter {
  final double animation;

  _ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      _Particle(0.1, 0.2, 4, kBrandStart.withOpacity(0.2)),
      _Particle(0.3, 0.4, 6, kBrandEnd.withOpacity(0.15)),
      _Particle(0.5, 0.15, 3, kLightGreen.withOpacity(0.2)),
      _Particle(0.7, 0.35, 5, kBrandStart.withOpacity(0.1)),
      _Particle(0.85, 0.25, 4, kBrandEnd.withOpacity(0.18)),
      _Particle(0.2, 0.6, 3, kLightGreen.withOpacity(0.15)),
      _Particle(0.6, 0.55, 5, kBrandStart.withOpacity(0.12)),
      _Particle(0.9, 0.5, 4, kBrandEnd.withOpacity(0.1)),
    ];

    for (final p in particles) {
      final offsetY = math.sin((animation + p.x) * 2 * math.pi) * 20;
      final x = size.width * p.x;
      final y = size.height * p.y + offsetY;
      paint.color = p.color;
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final Color color;

  _Particle(this.x, this.y, this.radius, this.color);
}