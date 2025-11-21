import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// Theme colors - Consistent with app theme
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentOrange = Color(0xFFF59E0B);

// ============================================
// RESEARCH PROJECTS LIST PAGE
// ============================================
class AdminResearchProjectsPage extends StatefulWidget {
  const AdminResearchProjectsPage({Key? key}) : super(key: key);

  @override
  State<AdminResearchProjectsPage> createState() => _AdminResearchProjectsPageState();
}

class _AdminResearchProjectsPageState extends State<AdminResearchProjectsPage>
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
          _buildSliverAppBar(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Research_Projects')
                .collection('research_projects')
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

              final projects = snapshot.data?.docs ?? [];

              if (projects.isEmpty) {
                return SliverFillRemaining(child: _EmptyState());
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final projectDoc = projects[index];
                      final projectName = projectDoc.id;
                      final data = projectDoc.data() as Map<String, dynamic>?;
                      final coverPicture = data?['Cover_Picture'] ?? '';

                      return _ProjectCard(
                        projectName: projectName,
                        coverPicture: coverPicture,
                        index: index,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  ResearchProjectEditPage(projectName: projectName),
                              transitionDuration: const Duration(milliseconds: 500),
                              reverseTransitionDuration: const Duration(milliseconds: 400),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                // Create smooth curved animation
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                  reverseCurve: Curves.easeInCubic,
                                );

                                // Slide from right with smooth easing
                                final slideTween = Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(curvedAnimation);

                                // Fade in effect
                                final fadeTween = Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                                ));

                                // Scale effect for depth
                                final scaleTween = Tween<double>(
                                  begin: 0.92,
                                  end: 1.0,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
                                ));

                                // Previous page slide out (parallax effect)
                                final previousPageTween = Tween<Offset>(
                                  begin: Offset.zero,
                                  end: const Offset(-0.3, 0.0),
                                ).animate(curvedAnimation);

                                return Stack(
                                  children: [
                                    // Previous page with parallax effect
                                    SlideTransition(
                                      position: previousPageTween,
                                      child: FadeTransition(
                                        opacity: Tween<double>(begin: 1.0, end: 0.5).animate(curvedAnimation),
                                        child: Container(), // Empty container, previous page handled by navigator
                                      ),
                                    ),
                                    // New page with combined effects
                                    SlideTransition(
                                      position: slideTween,
                                      child: FadeTransition(
                                        opacity: fadeTween,
                                        child: ScaleTransition(
                                          scale: scaleTween,
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        onDelete: () => _deleteProject(context, projectName),
                      );
                    },
                    childCount: projects.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _AddProjectButton(onPressed: () => _createNewProject(context)),
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
              'Manage Research & Projects',
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

  Future<void> _createNewProject(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenMain,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(result)
          .set({
        'Cover_Picture': '',
        'Introduction': '',
      });

      if (context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ResearchProjectEditPage(projectName: result),
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );

              // Fade in with scale effect for new project
              final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
                ),
              );

              final scaleTween = Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              );

              // Slide up effect
              final slideTween = Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(curvedAnimation);

              return SlideTransition(
                position: slideTween,
                child: FadeTransition(
                  opacity: fadeTween,
                  child: ScaleTransition(
                    scale: scaleTween,
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(BuildContext context, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "$projectName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(projectName)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$projectName deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kGreenMain.withOpacity(0.1), kGreenLight.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.science_rounded, size: 80, color: kGreenMain),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Projects Yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kGreenDark),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the + button to create your first project',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Project Card Widget
class _ProjectCard extends StatefulWidget {
  final String projectName;
  final String coverPicture;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.projectName,
    required this.coverPicture,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> with SingleTickerProviderStateMixin {
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
        return Transform.scale(
          scale: 0.8 + (0.2 * _controller.value),
          child: Opacity(opacity: _controller.value, child: child),
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
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kGreenMain.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cover Image
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [kGreenMain, kGreenLight],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: widget.coverPicture.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.coverPicture,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.science_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.science_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.projectName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kGreenDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kGreenMain.withOpacity(0.1), kGreenLight.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Tap to edit',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: kGreenMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Delete Button
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_rounded, color: Colors.red),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                      ),
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

// Add Project Button
class _AddProjectButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddProjectButton({required this.onPressed});

  @override
  State<_AddProjectButton> createState() => _AddProjectButtonState();
}

class _AddProjectButtonState extends State<_AddProjectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.4 * _controller.value),
                blurRadius: 20,
                spreadRadius: 5 * _controller.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: kGreenMain,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

// ============================================
// RESEARCH PROJECT EDIT PAGE
// ============================================
class ResearchProjectEditPage extends StatefulWidget {
  final String projectName;

  const ResearchProjectEditPage({Key? key, required this.projectName}) : super(key: key);

  @override
  State<ResearchProjectEditPage> createState() => _ResearchProjectEditPageState();
}

class _ResearchProjectEditPageState extends State<ResearchProjectEditPage> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Research_Projects')
            .collection('research_projects')
            .doc(widget.projectName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading project'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Cover Picture
                    _CoverPictureSection(
                      projectName: widget.projectName,
                      coverPicture: data['Cover_Picture'] ?? '',
                      onImagePick: _pickAndUploadImage,
                    ),
                    const SizedBox(height: 24),

                    // Title Section
                    _TitleSection(
                      projectName: widget.projectName,
                      title: data['Title'] ?? widget.projectName,
                      onTitleChanged: _handleTitleChange,
                    ),
                    const SizedBox(height: 24),

                    // Subtitle Section
                    _SubtitleSection(
                      projectName: widget.projectName,
                      subtitle: data['Subtitle'] ?? '',
                    ),
                    const SizedBox(height: 24),

                    // Introduction
                    _IntroductionSection(
                      projectName: widget.projectName,
                      introduction: data['Introduction'] ?? '',
                    ),
                    const SizedBox(height: 24),

                    // Owners Section
                    _OwnersSection(
                      projectName: widget.projectName,
                      data: data,
                    ),
                    const SizedBox(height: 24),

                    // Sections
                    ..._buildSections(data),

                    // Add Section Button
                    _AddSectionButton(
                      onPressed: () => _addNewSection(data),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
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
          title: Text(
            widget.projectName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(Map<String, dynamic> data) {
    final List<Widget> sections = [];
    int sectionIndex = 1;

    while (data.containsKey('Section_${sectionIndex}_Name')) {
      // Capture the current value of sectionIndex in a local variable
      final currentIndex = sectionIndex;

      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _SectionWidget(
            sectionIndex: currentIndex,
            sectionName: data['Section_${currentIndex}_Name'] ?? '',
            description: data['Section_${currentIndex}_Description'] ?? '',
            images: _getSectionImages(data, currentIndex),
            projectName: widget.projectName,
            onImagePick: _pickAndUploadImage,
            onDelete: () => _deleteSection(currentIndex, data),
          ),
        ),
      );
      sectionIndex++;
    }

    return sections;
  }

  Map<String, String> _getSectionImages(Map<String, dynamic> data, int sectionIndex) {
    final Map<String, String> images = {};
    int imageIndex = 1;

    while (data.containsKey('Section_${sectionIndex}_Image_$imageIndex')) {
      images['Section_${sectionIndex}_Image_$imageIndex'] =
          data['Section_${sectionIndex}_Image_$imageIndex'] ?? '';
      imageIndex++;
    }

    return images;
  }

  Future<void> _addNewSection(Map<String, dynamic> data) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(widget.projectName);

      // Fetch fresh data to find the next available section index
      final doc = await docRef.get();
      final currentData = doc.data() ?? {};

      int newSectionIndex = 1;
      while (currentData.containsKey('Section_${newSectionIndex}_Name')) {
        newSectionIndex++;
      }

      print('➕ Adding new section $newSectionIndex');

      await docRef.update({
        'Section_${newSectionIndex}_Name': 'New Section',
        'Section_${newSectionIndex}_Description': 'Section description here...',
      });

      print('✅ Section $newSectionIndex added successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Section $newSectionIndex added!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding section: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding section: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSection(int sectionIndex, Map<String, dynamic> data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Section'),
        content: Text('Are you sure you want to delete "Section $sectionIndex"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(widget.projectName);

      // Get current document data
      final doc = await docRef.get();

      if (!doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Project document not found!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final currentData = doc.data() ?? {};

      // Debug: Print ALL document fields
      print('\n📄 FULL DOCUMENT DATA:');
      print('   Project: ${widget.projectName}');
      print('   All fields in document:');
      currentData.forEach((key, value) {
        if (key.startsWith('Section_')) {
          print('   ✓ $key = ${value.toString().substring(0, value.toString().length > 50 ? 50 : value.toString().length)}...');
        }
      });
      print('\n');

      // Check if the section we're trying to delete actually exists
      bool sectionExists = currentData.containsKey('Section_${sectionIndex}_Name');
      print('🔍 Checking Section $sectionIndex:');
      print('   - Section_${sectionIndex}_Name exists? $sectionExists');
      print('   - Section_${sectionIndex}_Description exists? ${currentData.containsKey('Section_${sectionIndex}_Description')}');

      if (!sectionExists) {
        print('⚠️ WARNING: Section $sectionIndex does not exist in the document!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Section $sectionIndex not found in database!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create update map to delete all section-related fields
      final Map<String, dynamic> updateMap = {};

      // Delete section name
      updateMap['Section_${sectionIndex}_Name'] = FieldValue.delete();

      // Delete section description
      updateMap['Section_${sectionIndex}_Description'] = FieldValue.delete();

      // Delete all images for this section
      int imageIndex = 1;
      int deletedImageCount = 0;
      while (currentData.containsKey('Section_${sectionIndex}_Image_$imageIndex')) {
        updateMap['Section_${sectionIndex}_Image_$imageIndex'] = FieldValue.delete();
        deletedImageCount++;
        imageIndex++;
      }

      // Debug: Print what we're deleting
      print('🗑️ Deleting Section $sectionIndex:');
      print('   - Fields to delete: ${updateMap.keys.toList()}');
      print('   - Total images: $deletedImageCount');

      // Apply all deletions
      await docRef.update(updateMap);

      print('✅ Section $sectionIndex deleted successfully from Firestore');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Section $sectionIndex deleted successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error deleting section $sectionIndex: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting section: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleTitleChange(String oldTitle, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (oldTitle == newTitle) {
      return; // No change
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get reference to old document
      final oldDocRef = FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(oldTitle);

      // Get all data from old document
      final oldDoc = await oldDocRef.get();
      if (!oldDoc.exists) {
        Navigator.pop(context); // Close loading dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Project not found!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final data = oldDoc.data() ?? {};

      // Create new document with new name and updated Title field
      data['Title'] = newTitle;

      final newDocRef = FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(newTitle);

      // Copy data to new document
      await newDocRef.set(data);

      // Delete old document
      await oldDocRef.delete();

      Navigator.pop(context); // Close loading dialog

      // Navigate back and then to the new project with smooth transition
      if (mounted) {
        Navigator.pop(context); // Go back to list

        // Smooth transition to renamed project
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ResearchProjectEditPage(projectName: newTitle),
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );

              // Fade and scale effect for renamed project
              final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                ),
              );

              final scaleTween = Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              );

              return FadeTransition(
                opacity: fadeTween,
                child: ScaleTransition(
                  scale: scaleTween,
                  child: child,
                ),
              );
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Title updated to "$newTitle"'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating title: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'research_projects'),
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

// ============================================
// COVER PICTURE SECTION
// ============================================
class _CoverPictureSection extends StatefulWidget {
  final String projectName;
  final String coverPicture;
  final Future<String?> Function() onImagePick;

  const _CoverPictureSection({
    required this.projectName,
    required this.coverPicture,
    required this.onImagePick,
  });

  @override
  State<_CoverPictureSection> createState() => _CoverPictureSectionState();
}

class _CoverPictureSectionState extends State<_CoverPictureSection> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cover Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _isUploading ? null : _handleImageChange,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [kGreenMain.withOpacity(0.1), kGreenLight.withOpacity(0.1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kGreenMain.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.coverPicture.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.coverPicture,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, size: 60),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kGreenMain.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
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

  Future<void> _handleImageChange() async {
    setState(() => _isUploading = true);

    final imageUrl = await widget.onImagePick();

    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(widget.projectName)
          .update({'Cover_Picture': imageUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover picture updated!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _isUploading = false);
  }
}

// ============================================
// INTRODUCTION SECTION
// ============================================
// ============================================
// TITLE SECTION
// ============================================
class _TitleSection extends StatefulWidget {
  final String projectName;
  final String title;
  final Function(String oldTitle, String newTitle) onTitleChanged;

  const _TitleSection({
    required this.projectName,
    required this.title,
    required this.onTitleChanged,
  });

  @override
  State<_TitleSection> createState() => _TitleSectionState();
}

class _TitleSectionState extends State<_TitleSection> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
  }

  @override
  void didUpdateWidget(_TitleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.title != _controller.text) {
      _controller.text = widget.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.title_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Project Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: _saveTitle,
                icon: const Icon(Icons.save_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: kGreenMain.withOpacity(0.1),
                  foregroundColor: kGreenMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAccentOrange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: kAccentOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Changing the title will rename the project document',
                    style: TextStyle(
                      fontSize: 12,
                      color: kAccentOrange.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _isEditing = true),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kGreenDark,
            ),
            decoration: InputDecoration(
              hintText: 'Enter project title...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: kGreenMain, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTitle() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newTitle == widget.title) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Confirm the change with enhanced animated dialog
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rename Project',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: _EnhancedRenameDialog(
              oldTitle: widget.title,
              newTitle: newTitle,
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      widget.onTitleChanged(widget.title, newTitle);
      setState(() => _isEditing = false);
    }
  }
}

// ============================================
// SUBTITLE SECTION
// ============================================
class _SubtitleSection extends StatefulWidget {
  final String projectName;
  final String subtitle;

  const _SubtitleSection({
    required this.projectName,
    required this.subtitle,
  });

  @override
  State<_SubtitleSection> createState() => _SubtitleSectionState();
}

class _SubtitleSectionState extends State<_SubtitleSection> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.subtitle);
  }

  @override
  void didUpdateWidget(_SubtitleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.subtitle != _controller.text) {
      _controller.text = widget.subtitle;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.subtitles_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Project Subtitle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: _saveSubtitle,
                icon: const Icon(Icons.save_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: kGreenMain.withOpacity(0.1),
                  foregroundColor: kGreenMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 2,
            onChanged: (value) => setState(() => _isEditing = true),
            decoration: InputDecoration(
              hintText: 'Enter project subtitle...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: kGreenMain, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSubtitle() async {
    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(widget.projectName)
        .update({'Subtitle': _controller.text});

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subtitle saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================
// INTRODUCTION SECTION
// ============================================
class _IntroductionSection extends StatefulWidget {
  final String projectName;
  final String introduction;

  const _IntroductionSection({
    required this.projectName,
    required this.introduction,
  });

  @override
  State<_IntroductionSection> createState() => _IntroductionSectionState();
}

class _IntroductionSectionState extends State<_IntroductionSection> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.introduction);
  }

  @override
  void didUpdateWidget(_IntroductionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.introduction != _controller.text) {
      _controller.text = widget.introduction;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Introduction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: _saveIntroduction,
                icon: const Icon(Icons.save_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: kGreenMain.withOpacity(0.1),
                  foregroundColor: kGreenMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 8,
            onChanged: (value) => setState(() => _isEditing = true),
            decoration: InputDecoration(
              hintText: 'Enter project introduction...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kGreenMain, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveIntroduction() async {
    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(widget.projectName)
        .update({'Introduction': _controller.text});

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Introduction saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================
// OWNERS SECTION
// ============================================
class _OwnersSection extends StatelessWidget {
  final String projectName;
  final Map<String, dynamic> data;

  const _OwnersSection({
    required this.projectName,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final owners = _getOwners();

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Project Owners',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _addOwner(context),
                icon: const Icon(Icons.add_circle_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: kGreenMain.withOpacity(0.1),
                  foregroundColor: kGreenMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...owners.map((owner) => _OwnerCard(
                projectName: projectName,
                ownerIndex: owner['index'],
                ownerName: owner['name'],
                ownerDesignation: owner['designation'],
              )),
          if (owners.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'No owners added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getOwners() {
    final List<Map<String, dynamic>> owners = [];
    int ownerIndex = 1;

    while (data.containsKey('Owner_${ownerIndex}_Name')) {
      owners.add({
        'index': ownerIndex,
        'name': data['Owner_${ownerIndex}_Name'] ?? '',
        'designation': data['Owner_${ownerIndex}_Designation_Department'] ?? '',
      });
      ownerIndex++;
    }

    return owners;
  }

  Future<void> _addOwner(BuildContext context) async {
    int newOwnerIndex = 1;
    while (data.containsKey('Owner_${newOwnerIndex}_Name')) {
      newOwnerIndex++;
    }

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(projectName)
        .update({
      'Owner_${newOwnerIndex}_Name': 'Owner Name',
      'Owner_${newOwnerIndex}_Designation_Department': 'Designation & Department',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New owner added!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Owner Card Widget
class _OwnerCard extends StatefulWidget {
  final String projectName;
  final int ownerIndex;
  final String ownerName;
  final String ownerDesignation;

  const _OwnerCard({
    required this.projectName,
    required this.ownerIndex,
    required this.ownerName,
    required this.ownerDesignation,
  });

  @override
  State<_OwnerCard> createState() => _OwnerCardState();
}

class _OwnerCardState extends State<_OwnerCard> {
  late TextEditingController _nameController;
  late TextEditingController _designationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ownerName);
    _designationController = TextEditingController(text: widget.ownerDesignation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.ownerIndex}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Owner Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: _saveOwner,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                iconSize: 20,
              ),
              IconButton(
                onPressed: _deleteOwner,
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Owner Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _designationController,
            decoration: InputDecoration(
              labelText: 'Designation & Department',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOwner() async {
    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(widget.projectName)
        .update({
      'Owner_${widget.ownerIndex}_Name': _nameController.text,
      'Owner_${widget.ownerIndex}_Designation_Department': _designationController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Owner details saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteOwner() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Owner'),
        content: const Text('Are you sure you want to delete this owner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(widget.projectName)
          .update({
        'Owner_${widget.ownerIndex}_Name': FieldValue.delete(),
        'Owner_${widget.ownerIndex}_Designation_Department': FieldValue.delete(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner deleted!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================
// SECTION WIDGET
// ============================================
class _SectionWidget extends StatefulWidget {
  final int sectionIndex;
  final String sectionName;
  final String description;
  final Map<String, String> images;
  final String projectName;
  final Future<String?> Function() onImagePick;
  final VoidCallback onDelete;

  const _SectionWidget({
    required this.sectionIndex,
    required this.sectionName,
    required this.description,
    required this.images,
    required this.projectName,
    required this.onImagePick,
    required this.onDelete,
  });

  @override
  State<_SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<_SectionWidget> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sectionName);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.sectionIndex}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Section',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: _saveSection,
                icon: const Icon(Icons.check_circle_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  foregroundColor: Colors.green,
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Section Name',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kGreenMain, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Section Description
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Section Description',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kGreenMain, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Images
          const Text(
            'Section Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kGreenDark,
            ),
          ),
          const SizedBox(height: 12),

          // Image Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...widget.images.entries.map((entry) => _ImageThumbnail(
                    imageUrl: entry.value,
                    onDelete: () => _deleteImage(entry.key),
                  )),
              // Add Image Button
              GestureDetector(
                onTap: _addImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: Colors.grey[400], size: 32),
                      const SizedBox(height: 4),
                      Text(
                        'Add Image',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveSection() async {
    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(widget.projectName)
        .update({
      'Section_${widget.sectionIndex}_Name': _nameController.text,
      'Section_${widget.sectionIndex}_Description': _descriptionController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Section saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addImage() async {
    final imageUrl = await widget.onImagePick();
    if (imageUrl == null) return;

    // Find next image index
    int nextImageIndex = widget.images.length + 1;

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(widget.projectName)
        .update({
      'Section_${widget.sectionIndex}_Image_$nextImageIndex': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image added!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteImage(String imageKey) async {
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Research_Projects')
          .collection('research_projects')
          .doc(widget.projectName)
          .update({imageKey: FieldValue.delete()});

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

// Image Thumbnail Widget
class _ImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDelete;

  const _ImageThumbnail({
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Add Section Button
class _AddSectionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddSectionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGreenMain.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: kGreenMain.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [kGreenMain, kGreenLight]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add New Section',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kGreenMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ENHANCED RENAME DIALOG
// ============================================
class _EnhancedRenameDialog extends StatefulWidget {
  final String oldTitle;
  final String newTitle;

  const _EnhancedRenameDialog({
    required this.oldTitle,
    required this.newTitle,
  });

  @override
  State<_EnhancedRenameDialog> createState() => _EnhancedRenameDialogState();
}

class _EnhancedRenameDialogState extends State<_EnhancedRenameDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Animated gradient background
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-1.0 + (_shimmerController.value * 3), -1.0),
                            end: Alignment(1.0 + (_shimmerController.value * 3), 1.0),
                            colors: [
                              Colors.white,
                              kGreenMain.withOpacity(0.02),
                              kGreenLight.withOpacity(0.03),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.4, 0.6, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Transform.rotate(
                              angle: (1 - value) * 0.5,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kGreenMain, kGreenLight],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kGreenMain.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.drive_file_rename_outline_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
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
                        child: const Text(
                          'Rename Project',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: kGreenDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
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
                          'This action will update the project document',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Old Title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(-30 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    size: 16,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Current',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.oldTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kGreenDark,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Arrow Icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
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
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: kGreenMain,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // New Title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(30 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kGreenMain.withOpacity(0.05),
                                kGreenLight.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: kGreenMain.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                    color: kGreenMain,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'New',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: kGreenMain,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.newTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: kGreenMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Buttons
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _isHovering = false),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Confirm Button
                            Expanded(
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _isHovering = true),
                                onExit: (_) => setState(() => _isHovering = false),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context, true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isHovering
                                            ? [kGreenLight, kGreenMain]
                                            : [kGreenMain, kGreenLight],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kGreenMain.withOpacity(_isHovering ? 0.5 : 0.3),
                                          blurRadius: _isHovering ? 20 : 12,
                                          spreadRadius: _isHovering ? 2 : 0,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Rename',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
    );
  }
}


