import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);

// ============================================
// ACHIEVEMENT LIST PAGE - Shows all achievements
// ============================================
class AdminAchievementPage extends StatefulWidget {
  const AdminAchievementPage({Key? key}) : super(key: key);

  @override
  State<AdminAchievementPage> createState() => _AdminAchievementPageState();
}

class _AdminAchievementPageState extends State<AdminAchievementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
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

          // Achievement List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Achievement')
                .collection('achievement')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final achievements = snapshot.data?.docs ?? [];

              if (achievements.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(),
                );
              }

              // Sort by Order field
              achievements.sort((a, b) {
                final orderA = _getOrderValue((a.data() as Map<String, dynamic>)['Order']);
                final orderB = _getOrderValue((b.data() as Map<String, dynamic>)['Order']);
                return orderA.compareTo(orderB);
              });

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievementDoc = achievements[index];
                      final achievementName = achievementDoc.id;
                      final data = achievementDoc.data() as Map<String, dynamic>?;
                      final name = data?['Name'] ?? achievementName;
                      final description = data?['Description'] ?? '';
                      final order = _getOrderValue(data?['Order']);

                      // Get first image
                      String coverImage = '';
                      if (data != null && data.containsKey('Image_1')) {
                        coverImage = data['Image_1'] ?? '';
                      }

                      return _AchievementCard(
                        achievementName: achievementName,
                        name: name,
                        description: description,
                        coverImage: coverImage,
                        order: order,
                        index: index,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  AchievementEditPage(achievementName: achievementName),
                              transitionDuration: const Duration(milliseconds: 500),
                              reverseTransitionDuration: const Duration(milliseconds: 400),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                );

                                return FadeTransition(
                                  opacity: curvedAnimation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(curvedAnimation),
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.95, end: 1.0)
                                          .animate(curvedAnimation),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        onDelete: () => _deleteAchievement(context, achievementName),
                      );
                    },
                    childCount: achievements.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating Add Button
      floatingActionButton: _AddAchievementButton(),
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
            colors: [kGreenDark, kGreenMain, kGreenLight],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
          title: FadeTransition(
            opacity: _headerController,
            child: const Text(
              'Manage Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getOrderValue(dynamic orderValue) {
    if (orderValue == null) return 999;
    if (orderValue is int) return orderValue;
    if (orderValue is String) {
      return int.tryParse(orderValue) ?? 999;
    }
    return 999;
  }

  Future<void> _deleteAchievement(BuildContext context, String achievementName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Achievement'),
        content: Text('Are you sure you want to delete "$achievementName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Achievement')
          .collection('achievement')
          .doc(achievementName)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Achievement deleted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// Achievement Card Widget
class _AchievementCard extends StatefulWidget {
  final String achievementName;
  final String name;
  final String description;
  final String coverImage;
  final int order;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AchievementCard({
    required this.achievementName,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.order,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
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
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(_isHovered ? 1.02 : 1.0),
              child: Material(
                elevation: _isHovered ? 12 : 4,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          kGreenLight.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kGreenLight.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Achievement Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kGreenMain, kGreenLight],
                            ),
                          ),
                          child: widget.coverImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.coverImage,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.emoji_events_rounded,
                                            size: 50, color: Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.emoji_events_rounded,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                        // Achievement Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kAccentGold.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Order: ${widget.order}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: kAccentGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: kGreenDark,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Actions
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: kGreenMain.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      color: kGreenMain),
                                  onPressed: widget.onTap,
                                  tooltip: 'Edit',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_rounded,
                                      color: Colors.red),
                                  onPressed: widget.onDelete,
                                  tooltip: 'Delete',
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
        ),
      ),
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: kGreenLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: kGreenMain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Achievements Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kGreenDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first achievement',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Add Achievement Button
class _AddAchievementButton extends StatefulWidget {
  @override
  State<_AddAchievementButton> createState() => _AddAchievementButtonState();
}

class _AddAchievementButtonState extends State<_AddAchievementButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
      child: FloatingActionButton.extended(
        onPressed: () => _showAddAchievementDialog(context),
        backgroundColor: kGreenMain,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Achievement',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _showAddAchievementDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add New Achievement',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Achievement Name',
                hintText: 'Enter achievement name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Create new achievement document
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Achievement')
          .collection('achievement')
          .doc(result)
          .set({
        'Name': result,
        'Description': 'Add description here',
        'Order': 999,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achievement "$result" created!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================
// ACHIEVEMENT EDIT PAGE - Edit achievement details
// ============================================
class AchievementEditPage extends StatefulWidget {
  final String achievementName;

  const AchievementEditPage({Key? key, required this.achievementName})
      : super(key: key);

  @override
  State<AchievementEditPage> createState() => _AchievementEditPageState();
}

class _AchievementEditPageState extends State<AchievementEditPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _imagePicker = ImagePicker();

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Achievement')
            .collection('achievement')
            .doc(widget.achievementName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Achievement not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('No data available'));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),

              // Name Field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _EditableNameField(
                    achievementName: widget.achievementName,
                    currentName: data['Name'] ?? widget.achievementName,
                  ),
                ),
              ),

              // Description Field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EditableTextField(
                    label: 'Description',
                    value: data['Description'] ?? '',
                    fieldName: 'Description',
                    achievementName: widget.achievementName,
                    icon: Icons.description_rounded,
                    maxLines: 5,
                  ),
                ),
              ),

              // Order Field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _EditableTextField(
                    label: 'Display Order',
                    value: data['Order']?.toString() ?? '999',
                    fieldName: 'Order',
                    achievementName: widget.achievementName,
                    icon: Icons.sort_rounded,
                    maxLines: 1,
                    isNumeric: true,
                  ),
                ),
              ),

              // Images Section
              SliverToBoxAdapter(
                child: _ImagesSection(
                  achievementName: widget.achievementName,
                  data: data,
                  onImagePick: _pickAndUploadImage,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
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
            colors: [kGreenDark, kGreenMain, kGreenLight],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
          title: FadeTransition(
            opacity: _controller,
            child: const Text(
              'Edit Achievement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Upload to Cloudinary
      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'achievements'),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
  }
}

// Editable Name Field (special because it updates document name too)
class _EditableNameField extends StatefulWidget {
  final String achievementName;
  final String currentName;

  const _EditableNameField({
    required this.achievementName,
    required this.currentName,
  });

  @override
  State<_EditableNameField> createState() => _EditableNameFieldState();
}

class _EditableNameFieldState extends State<_EditableNameField> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kGreenLight.withOpacity(0.1),
            kGreenMain.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kGreenLight.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kGreenMain, kGreenLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.title_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Achievement Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: kGreenMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_rounded, color: kGreenMain),
                  onPressed: _isUpdating ? null : _handleNameChange,
                  tooltip: 'Change Name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.currentName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kGreenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNameChange() async {
    final controller = TextEditingController(text: widget.currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                kGreenLight.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kGreenMain, kGreenLight],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kGreenMain.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Change Achievement Name',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kGreenDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This will update both the document name and the Name field',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'New Name',
                  hintText: 'Enter new achievement name',
                  prefixIcon: const Icon(Icons.emoji_events_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kGreenMain, width: 2),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty && name != widget.currentName) {
                            Navigator.pop(context, name);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreenMain,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() => _isUpdating = true);

      try {
        // Get the old document data
        final oldDoc = await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Achievement')
            .collection('achievement')
            .doc(widget.achievementName)
            .get();

        if (oldDoc.exists) {
          final data = oldDoc.data()!;
          data['Name'] = newName;

          // Create new document with new name first
          await FirebaseFirestore.instance
              .collection('All_Data')
              .doc('Achievement')
              .collection('achievement')
              .doc(newName)
              .set(data);

          if (mounted) {
            // Navigate to the new document immediately (before deleting the old one)
            // This prevents the "Achievement not found" error
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AchievementEditPage(achievementName: newName),
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0)
                            .animate(curvedAnimation),
                        child: child,
                      ),
                    ),
                  );
                },
              ),
            );

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Achievement name updated successfully!'),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Delete old document AFTER navigation (in background)
            // This ensures we don't see the "not found" error
            FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Achievement')
                .collection('achievement')
                .doc(widget.achievementName)
                .delete()
                .catchError((error) {
              print('Error deleting old document: $error');
            });
          }
        }
      } catch (e) {
        setState(() => _isUpdating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating name: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// Editable Text Field Widget
class _EditableTextField extends StatefulWidget {
  final String label;
  final String value;
  final String fieldName;
  final String achievementName;
  final IconData icon;
  final int maxLines;
  final bool isNumeric;

  const _EditableTextField({
    required this.label,
    required this.value,
    required this.fieldName,
    required this.achievementName,
    required this.icon,
    this.maxLines = 1,
    this.isNumeric = false,
  });

  @override
  State<_EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<_EditableTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _textController = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_EditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _textController.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kGreenLight.withOpacity(0.1),
            kGreenMain.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEditing ? kGreenMain : kGreenLight.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kGreenMain, kGreenLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                  ),
                ),
              ),
              if (!_isEditing)
                Container(
                  decoration: BoxDecoration(
                    color: kGreenMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: kGreenMain),
                    onPressed: () {
                      setState(() => _isEditing = true);
                      _controller.forward();
                    },
                    tooltip: 'Edit',
                  ),
                ),
              if (_isEditing) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _textController.text = widget.value;
                      });
                      _controller.reverse();
                    },
                    tooltip: 'Cancel',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kGreenMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check_rounded, color: kGreenMain),
                    onPressed: _saveChanges,
                    tooltip: 'Save',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isEditing ? Colors.white : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isEditing
                  ? [
                      BoxShadow(
                        color: kGreenMain.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: _isEditing
                ? TextField(
                    controller: _textController,
                    maxLines: widget.maxLines,
                    keyboardType: widget.isNumeric
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: kGreenDark,
                      fontWeight: FontWeight.w600,
                    ),
                    autofocus: true,
                  )
                : Text(
                    widget.value.isEmpty ? 'Not set' : widget.value,
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.value.isEmpty ? Colors.grey : kGreenDark,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final newValue = _textController.text.trim();

    if (newValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Field cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate numeric if needed
    if (widget.isNumeric) {
      final numValue = int.tryParse(newValue);
      if (numValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid number'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Update with int value for Order field
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Achievement')
          .collection('achievement')
          .doc(widget.achievementName)
          .update({widget.fieldName: numValue});
    } else {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Achievement')
          .collection('achievement')
          .doc(widget.achievementName)
          .update({widget.fieldName: newValue});
    }

    setState(() => _isEditing = false);
    _controller.reverse();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.label} updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Images Section
class _ImagesSection extends StatefulWidget {
  final String achievementName;
  final Map<String, dynamic> data;
  final Future<String?> Function() onImagePick;

  const _ImagesSection({
    required this.achievementName,
    required this.data,
    required this.onImagePick,
  });

  @override
  State<_ImagesSection> createState() => _ImagesSectionState();
}

class _ImagesSectionState extends State<_ImagesSection> {
  bool _isAddingImage = false;

  @override
  Widget build(BuildContext context) {
    final images = _getImages();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kGreenLight.withOpacity(0.1),
              kGreenMain.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: kGreenLight.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kGreenMain, kGreenLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Achievement Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kGreenDark,
                    ),
                  ),
                ),
                if (_isAddingImage)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kGreenMain),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (images.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No images added yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...images.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ImageCard(
                    imageUrl: entry.value,
                    fieldName: entry.key,
                    achievementName: widget.achievementName,
                    onImagePick: widget.onImagePick,
                    isAnyImageUploading: _isAddingImage,
                  ),
                );
              }).toList(),

            const SizedBox(height: 16),

            // Add Image Button with loading state
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isAddingImage ? null : () => _addNewImage(context),
                icon: _isAddingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(kGreenMain),
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate_rounded),
                label: Text(_isAddingImage ? 'Uploading...' : 'Add Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreenMain,
                  side: BorderSide(
                    color: _isAddingImage ? Colors.grey : kGreenMain,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getImages() {
    final Map<String, String> images = {};
    int imageIndex = 1;

    while (widget.data.containsKey('Image_$imageIndex')) {
      final imageUrl = widget.data['Image_$imageIndex'];
      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        images['Image_$imageIndex'] = imageUrl.toString();
      }
      imageIndex++;
    }

    return images;
  }

  Future<void> _addNewImage(BuildContext context) async {
    setState(() => _isAddingImage = true);

    try {
      final imageUrl = await widget.onImagePick();

      if (imageUrl != null) {
        // Find next available image index
        int nextIndex = 1;
        while (widget.data.containsKey('Image_$nextIndex')) {
          nextIndex++;
        }

        await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Achievement')
            .collection('achievement')
            .doc(widget.achievementName)
            .update({'Image_$nextIndex': imageUrl});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image added successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingImage = false);
      }
    }
  }
}

// Image Card Widget
class _ImageCard extends StatefulWidget {
  final String imageUrl;
  final String fieldName;
  final String achievementName;
  final Future<String?> Function() onImagePick;
  final bool isAnyImageUploading;

  const _ImageCard({
    required this.imageUrl,
    required this.fieldName,
    required this.achievementName,
    required this.onImagePick,
    this.isAnyImageUploading = false,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = _isUploading || widget.isAnyImageUploading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Display
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline, size: 50),
                    ),
                  ),
                ),
              ),
              // Loading overlay
              if (_isUploading)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Uploading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Action buttons overlay
              if (!_isUploading)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      // Change Image Button
                      GestureDetector(
                        onTap: isDisabled ? null : _handleImageChange,
                        child: AnimatedOpacity(
                          opacity: isDisabled ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kGreenMain, kGreenLight],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Image Button
                      GestureDetector(
                        onTap: isDisabled ? null : _handleImageDelete,
                        child: AnimatedOpacity(
                          opacity: isDisabled ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Image Label
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.image_rounded, size: 16, color: kGreenMain),
                const SizedBox(width: 8),
                Text(
                  widget.fieldName.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImageChange() async {
    if (_isUploading || widget.isAnyImageUploading) return;

    setState(() => _isUploading = true);

    try {
      final imageUrl = await widget.onImagePick();

      if (imageUrl != null) {
        await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Achievement')
            .collection('achievement')
            .doc(widget.achievementName)
            .update({widget.fieldName: imageUrl});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image updated!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating image: $e'),
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

  Future<void> _handleImageDelete() async {
    if (_isUploading || widget.isAnyImageUploading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Achievement')
          .collection('achievement')
          .doc(widget.achievementName)
          .update({widget.fieldName: FieldValue.delete()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

