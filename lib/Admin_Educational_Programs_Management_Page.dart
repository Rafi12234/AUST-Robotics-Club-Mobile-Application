import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// Theme colors (same as Event page)
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);

// ============================================
// EDUCATIONAL PROGRAMS LIST PAGE
// ============================================
class AdminEducationalProgramsPage extends StatefulWidget {
  const AdminEducationalProgramsPage({Key? key}) : super(key: key);

  @override
  State<AdminEducationalProgramsPage> createState() =>
      _AdminEducationalProgramsPageState();
}

class _AdminEducationalProgramsPageState
    extends State<AdminEducationalProgramsPage>
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

  // Firebase collection reference
  CollectionReference get _programsCollection => FirebaseFirestore.instance
      .collection('All_Data')
      .doc('Educational, Mentorship & Training Programs')
      .collection('educational, mentorship & training programs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(),

          // Programs List
          StreamBuilder<QuerySnapshot>(
            stream: _programsCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: kGreenMain),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: _ErrorState(error: snapshot.error.toString()),
                );
              }

              final programs = snapshot.data?.docs ?? [];

              if (programs.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final programDoc = programs[index];
                      final programId = programDoc.id;
                      final data = programDoc.data() as Map<String, dynamic>?;
                      final programName = data?['Name'] ?? programId;
                      final description = data?['Description'] ?? '';
                      final firstImage = _getFirstImage(data);

                      return _ProgramCard(
                        programId: programId,
                        programName: programName,
                        description: description,
                        imageUrl: firstImage,
                        index: index,
                        onTap: () => _navigateToEditPage(programId),
                        onDelete: () => _deleteProgram(context, programId, programName),
                      );
                    },
                    childCount: programs.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating Add Button
      floatingActionButton: _AddProgramButton(
        onProgramCreated: (programName) => _navigateToEditPage(programName),
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
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16, right: 16),
          title: FadeTransition(
            opacity: _headerController,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Educational Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Mentorship & Training',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.school_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  String _getFirstImage(Map<String, dynamic>? data) {
    if (data == null) return '';

    for (int i = 1; i <= 20; i++) {
      final imageKey = 'Image_$i';
      if (data.containsKey(imageKey) && data[imageKey] != null && data[imageKey].toString().isNotEmpty) {
        return data[imageKey].toString();
      }
    }
    return '';
  }

  void _navigateToEditPage(String programId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EducationalProgramEditPage(programId: programId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteProgram(
      BuildContext context, String programId, String programName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Delete Program')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "$programName"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All program data and images will be permanently deleted.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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
      try {
        await _programsCollection.doc(programId).delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('"$programName" deleted successfully')),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting program: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// ============================================
// PROGRAM CARD WIDGET
// ============================================
class _ProgramCard extends StatefulWidget {
  final String programId;
  final String programName;
  final String description;
  final String imageUrl;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProgramCard({
    required this.programId,
    required this.programName,
    required this.description,
    required this.imageUrl,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<_ProgramCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _controller.value)),
          child: Opacity(
            opacity: _controller.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kGreenMain.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: widget.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 160,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: kGreenMain,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 160,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                            : Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kGreenLight.withOpacity(0.3),
                                kGreenMain.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 60,
                            color: kGreenMain,
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
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Action buttons
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            _ActionIconButton(
                              icon: Icons.edit_rounded,
                              color: kGreenMain,
                              onTap: widget.onTap,
                            ),
                            const SizedBox(width: 8),
                            _ActionIconButton(
                              icon: Icons.delete_rounded,
                              color: Colors.red,
                              onTap: widget.onDelete,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Content Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.programName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kGreenDark,
                            height: 1.3,
                          ),
                        ),
                        if (widget.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: kGreenLight.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    size: 14,
                                    color: kGreenMain,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tap to Edit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kGreenMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey[400],
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
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ============================================
// EMPTY STATE WIDGET
// ============================================
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                  Icons.school_outlined,
                  size: 80,
                  color: kGreenMain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Programs Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first educational program\nby tapping the + button below',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kAccentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAccentGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: kAccentGold, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Tip: Add programs to showcase your courses',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kGreenDark,
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

// ============================================
// ERROR STATE WIDGET
// ============================================
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
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
}

// ============================================
// ADD PROGRAM BUTTON
// ============================================
class _AddProgramButton extends StatefulWidget {
  final Function(String) onProgramCreated;

  const _AddProgramButton({required this.onProgramCreated});

  @override
  State<_AddProgramButton> createState() => _AddProgramButtonState();
}

class _AddProgramButtonState extends State<_AddProgramButton>
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

  CollectionReference get _programsCollection => FirebaseFirestore.instance
      .collection('All_Data')
      .doc('Educational, Mentorship & Training Programs')
      .collection('educational, mentorship & training programs');

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddProgramDialog(context),
        backgroundColor: kGreenMain,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Program',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _showAddProgramDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kGreenLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school_rounded, color: kGreenMain),
            ),
            const SizedBox(width: 12),
            const Text(
              'Create New Program',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Program Name',
                  hintText: 'Enter program name',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kGreenMain, width: 2),
                  ),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter program description',
                  prefixIcon: const Icon(Icons.description_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kGreenMain, width: 2),
                  ),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, {
                  'name': name,
                  'description': description,
                });
              }
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );

    if (result != null && result['name']!.isNotEmpty && context.mounted) {
      try {
        final docId = result['name']!;

        await _programsCollection.doc(docId).set({
          'Name': result['name'],
          'Description': result['description'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('"${result['name']}" created successfully!')),
                ],
              ),
              backgroundColor: kGreenMain,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          widget.onProgramCreated(docId);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating program: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// ============================================
// EDUCATIONAL PROGRAM EDIT PAGE
// ============================================
class EducationalProgramEditPage extends StatefulWidget {
  final String programId;

  const EducationalProgramEditPage({Key? key, required this.programId})
      : super(key: key);

  @override
  State<EducationalProgramEditPage> createState() =>
      _EducationalProgramEditPageState();
}

class _EducationalProgramEditPageState extends State<EducationalProgramEditPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _headerController;

  // Track current program ID (can change when name changes)
  late String _currentProgramId;

  // Cloudinary configuration
  final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');

  CollectionReference get _programsCollection => FirebaseFirestore.instance
      .collection('All_Data')
      .doc('Educational, Mentorship & Training Programs')
      .collection('educational, mentorship & training programs');

  DocumentReference get _programDoc => _programsCollection.doc(_currentProgramId);

  @override
  void initState() {
    super.initState();
    _currentProgramId = widget.programId;
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _programDoc.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kGreenMain),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: _ErrorState(error: snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Program not found'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final images = _extractImages(data);

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(data['Name'] ?? _currentProgramId),

              // Program Name Section - WITH DOCUMENT RENAME SUPPORT
              SliverToBoxAdapter(
                child: _ProgramNameField(
                  label: 'Program Name',
                  value: data['Name'] ?? '',
                  currentProgramId: _currentProgramId,
                  programsCollection: _programsCollection,
                  icon: Icons.school_rounded,
                  hint: 'Enter program name',
                  onProgramRenamed: (newProgramId) {
                    // Update the current program ID and rebuild
                    setState(() {
                      _currentProgramId = newProgramId;
                    });
                  },
                ),
              ),

              // Description Section
              SliverToBoxAdapter(
                child: _EditableField(
                  label: 'Description',
                  value: data['Description'] ?? '',
                  fieldName: 'Description',
                  programDoc: _programDoc,
                  icon: Icons.description_rounded,
                  maxLines: 8,
                  hint: 'Enter program description',
                ),
              ),

              // Images Section Header
              SliverToBoxAdapter(
                child: _ImagesSectionHeader(
                  imageCount: images.length,
                  onAddImage: () => _addNewImage(images.length + 1),
                ),
              ),

              // Images Grid
              if (images.isNotEmpty)
                SliverToBoxAdapter(
                  child: _ImagesGrid(
                    images: images,
                    programDoc: _programDoc,
                    onImagePick: _pickAndUploadImage,
                    onDeleteImage: _deleteImage,
                  ),
                ),

              // Empty Images State
              if (images.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyImagesState(
                    onAddImage: () => _addNewImage(1),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),

      // Add Image FAB
      floatingActionButton: _AddImageFAB(
        onPressed: () async {
          final snapshot = await _programDoc.get();
          final data = snapshot.data() as Map<String, dynamic>? ?? {};
          final images = _extractImages(data);
          _addNewImage(images.length + 1);
        },
      ),
    );
  }

  Widget _buildAppBar(String title) {
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => setState(() {}),
          tooltip: 'Refresh',
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGreenDark, kGreenMain, kGreenLight],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16, right: 60),
          title: FadeTransition(
            opacity: _headerController,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _extractImages(Map<String, dynamic> data) {
    final Map<String, String> images = {};

    for (int i = 1; i <= 50; i++) {
      final key = 'Image_$i';
      if (data.containsKey(key) &&
          data[key] != null &&
          data[key].toString().isNotEmpty) {
        images[key] = data[key].toString();
      }
    }

    return images;
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 16),
                Text('Uploading image...'),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: 'educational_programs',
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

      return response.secureUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _addNewImage(int imageNumber) async {
    final imageUrl = await _pickAndUploadImage();

    if (imageUrl != null) {
      try {
        await _programDoc.update({
          'Image_$imageNumber': imageUrl,
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving image: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteImage(String fieldName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            const Text('Delete Image'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this image? This action cannot be undone.',
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
      try {
        await _programDoc.update({
          fieldName: FieldValue.delete(),
        });

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
              content: Text('Error deleting image: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// ============================================
// PROGRAM NAME FIELD - WITH DOCUMENT RENAME
// ============================================
class _ProgramNameField extends StatefulWidget {
  final String label;
  final String value;
  final String currentProgramId;
  final CollectionReference programsCollection;
  final IconData icon;
  final String hint;
  final Function(String newProgramId) onProgramRenamed;

  const _ProgramNameField({
    required this.label,
    required this.value,
    required this.currentProgramId,
    required this.programsCollection,
    required this.icon,
    required this.hint,
    required this.onProgramRenamed,
  });

  @override
  State<_ProgramNameField> createState() => _ProgramNameFieldState();
}

class _ProgramNameFieldState extends State<_ProgramNameField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _textController = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ProgramNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
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
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kGreenLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: kGreenMain, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kGreenDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Changing name will update document ID',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSaving)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kGreenMain,
                        ),
                      )
                    else
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          key: ValueKey(_isEditing),
                          icon: Icon(
                            _isEditing
                                ? Icons.check_circle_rounded
                                : Icons.edit_rounded,
                            color: _isEditing ? Colors.green : kGreenMain,
                          ),
                          onPressed: _isEditing ? _saveAndRename : _enableEditing,
                        ),
                      ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.red),
                        onPressed: _cancelEditing,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.grey[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: _isEditing
                        ? Border.all(color: kGreenMain, width: 2)
                        : null,
                  ),
                  child: TextField(
                    controller: _textController,
                    enabled: _isEditing,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      color: _isEditing ? kGreenDark : Colors.grey[700],
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(_isEditing ? 16 : 0),
                    ),
                  ),
                ),

                // Warning message when editing
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Changing the name will create a new document and delete the old one. All data will be preserved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

  void _enableEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _textController.text = widget.value;
    setState(() => _isEditing = false);
  }

  Future<void> _saveAndRename() async {
    final newName = _textController.text.trim();

    // Validation
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program name cannot be empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If name hasn't changed, just update the field
    if (newName == widget.currentProgramId) {
      setState(() => _isEditing = false);
      return;
    }

    // Check if new name already exists
    final existingDoc = await widget.programsCollection.doc(newName).get();
    if (existingDoc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A program with name "$newName" already exists'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.drive_file_rename_outline, color: kGreenMain, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Rename Program')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                children: [
                  const TextSpan(text: 'Rename from '),
                  TextSpan(
                    text: '"${widget.currentProgramId}"',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: '"$newName"',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: kGreenMain),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGreenLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGreenLight.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: kGreenMain, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All images and data will be preserved.',
                      style: TextStyle(
                        fontSize: 13,
                        color: kGreenDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Rename'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      // Step 1: Get all data from old document
      final oldDocSnapshot = await widget.programsCollection.doc(widget.currentProgramId).get();
      final oldData = oldDocSnapshot.data() as Map<String, dynamic>? ?? {};

      // Step 2: Create new document with new name
      final newData = Map<String, dynamic>.from(oldData);
      newData['Name'] = newName; // Update the Name field
      newData['renamedAt'] = FieldValue.serverTimestamp();
      newData['previousName'] = widget.currentProgramId;

      await widget.programsCollection.doc(newName).set(newData);

      // Step 3: Delete old document
      await widget.programsCollection.doc(widget.currentProgramId).delete();

      // Step 4: Notify parent to update the program ID
      widget.onProgramRenamed(newName);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Program renamed to "$newName" successfully!'),
                ),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error renaming program: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================
// EDITABLE FIELD WIDGET (For Description)
// ============================================
class _EditableField extends StatefulWidget {
  final String label;
  final String value;
  final String fieldName;
  final DocumentReference programDoc;
  final IconData icon;
  final int maxLines;
  final String hint;

  const _EditableField({
    required this.label,
    required this.value,
    required this.fieldName,
    required this.programDoc,
    required this.icon,
    this.maxLines = 1,
    this.hint = '',
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _textController = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
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
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kGreenLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: kGreenMain, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kGreenDark,
                        ),
                      ),
                    ),
                    if (_isSaving)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kGreenMain,
                        ),
                      )
                    else
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          key: ValueKey(_isEditing),
                          icon: Icon(
                            _isEditing
                                ? Icons.check_circle_rounded
                                : Icons.edit_rounded,
                            color: _isEditing ? Colors.green : kGreenMain,
                          ),
                          onPressed: _isEditing ? _saveChanges : _enableEditing,
                        ),
                      ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.red),
                        onPressed: _cancelEditing,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.grey[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: _isEditing
                        ? Border.all(color: kGreenMain, width: 2)
                        : null,
                  ),
                  child: TextField(
                    controller: _textController,
                    enabled: _isEditing,
                    maxLines: widget.maxLines,
                    style: TextStyle(
                      fontSize: 15,
                      color: _isEditing ? kGreenDark : Colors.grey[700],
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(_isEditing ? 16 : 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enableEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _textController.text = widget.value;
    setState(() => _isEditing = false);
  }

  Future<void> _saveChanges() async {
    final newValue = _textController.text.trim();

    setState(() => _isSaving = true);

    try {
      await widget.programDoc.update({widget.fieldName: newValue});

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${widget.label} updated successfully!'),
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
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================
// IMAGES SECTION HEADER
// ============================================
class _ImagesSectionHeader extends StatelessWidget {
  final int imageCount;
  final VoidCallback onAddImage;

  const _ImagesSectionHeader({
    required this.imageCount,
    required this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: kAccentGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Program Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                  ),
                ),
                Text(
                  '$imageCount image${imageCount != 1 ? 's' : ''} uploaded',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAddImage,
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// IMAGES GRID WIDGET
// ============================================
class _ImagesGrid extends StatelessWidget {
  final Map<String, String> images;
  final DocumentReference programDoc;
  final Future<String?> Function() onImagePick;
  final Future<void> Function(String) onDeleteImage;

  const _ImagesGrid({
    required this.images,
    required this.programDoc,
    required this.onImagePick,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    final imageList = images.entries.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (int i = 0; i < imageList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ImageCard(
                index: i + 1,
                fieldName: imageList[i].key,
                imageUrl: imageList[i].value,
                programDoc: programDoc,
                onImagePick: onImagePick,
                onDeleteImage: () => onDeleteImage(imageList[i].key),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// IMAGE CARD WIDGET
// ============================================
class _ImageCard extends StatefulWidget {
  final int index;
  final String fieldName;
  final String imageUrl;
  final DocumentReference programDoc;
  final Future<String?> Function() onImagePick;
  final VoidCallback onDeleteImage;

  const _ImageCard({
    required this.index,
    required this.fieldName,
    required this.imageUrl,
    required this.programDoc,
    required this.onImagePick,
    required this.onDeleteImage,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kGreenMain, kGreenLight],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Image ${widget.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_isUpdating)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kGreenMain,
                        ),
                      )
                    else ...[
                      _IconActionButton(
                        icon: Icons.edit_rounded,
                        color: kGreenMain,
                        tooltip: 'Change Image',
                        onTap: _handleChangeImage,
                      ),
                      const SizedBox(width: 8),
                      _IconActionButton(
                        icon: Icons.delete_rounded,
                        color: Colors.red,
                        tooltip: 'Delete Image',
                        onTap: widget.onDeleteImage,
                      ),
                    ],
                  ],
                ),
              ),
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(color: kGreenMain),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
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
      ),
    );
  }

  Future<void> _handleChangeImage() async {
    setState(() => _isUpdating = true);

    final newImageUrl = await widget.onImagePick();

    if (newImageUrl != null) {
      try {
        await widget.programDoc.update({
          widget.fieldName: newImageUrl,
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating image: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    setState(() => _isUpdating = false);
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ============================================
// EMPTY IMAGES STATE
// ============================================
class _EmptyImagesState extends StatelessWidget {
  final VoidCallback onAddImage;

  const _EmptyImagesState({required this.onAddImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kGreenLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 60,
                  color: kGreenMain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Images Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add images to showcase this program',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddImage,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('Upload First Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenMain,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
// ADD IMAGE FAB
// ============================================
class _AddImageFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddImageFAB({required this.onPressed});

  @override
  State<_AddImageFAB> createState() => _AddImageFABState();
}

class _AddImageFABState extends State<_AddImageFAB>
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
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: kAccentGold,
        child: const Icon(
          Icons.add_photo_alternate_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}