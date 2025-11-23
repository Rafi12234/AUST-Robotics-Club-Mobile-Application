import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:cloudinary_public/cloudinary_public.dart';


// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);

// ============================================
// EVENT LIST PAGE - Shows all events
// ============================================
class AdminEventPage extends StatefulWidget {
  const AdminEventPage({Key? key}) : super(key: key);

  @override
  State<AdminEventPage> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends State<AdminEventPage>
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

          // Event List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Event_Page')
                .collection('All_Events_of_RC')
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

              final events = snapshot.data?.docs ?? [];

              if (events.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final eventDoc = events[index];
                      final eventName = eventDoc.id;
                      final data = eventDoc.data() as Map<String, dynamic>?;
                      final coverPicture = data?['Cover_Picture'] ?? '';

                      return _EventCard(
                        eventName: eventName,
                        coverPicture: coverPicture,
                        index: index,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  EventEditPage(eventName: eventName),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
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
                        },
                        onDelete: () => _deleteEvent(context, eventName),
                      );
                    },
                    childCount: events.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating Add Button
      floatingActionButton: _AddEventButton(),
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
              'Manage Events',
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

  Future<void> _deleteEvent(BuildContext context, String eventName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "$eventName"?'),
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
          .doc('Event_Page')
          .collection('All_Events_of_RC')
          .doc(eventName)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$eventName deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

class _EventCard extends StatefulWidget {
  final String eventName;
  final String coverPicture;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EventCard({
    required this.eventName,
    required this.coverPicture,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard>
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
        return Transform.scale(
          scale: 0.8 + (0.2 * _controller.value),
          child: Opacity(
            opacity: _controller.value,
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
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: widget.coverPicture.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: widget.coverPicture,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                        : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 40),
                    ),
                  ),
                  // Event Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.eventName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: kGreenDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kGreenLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Tap to Edit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kGreenMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: kGreenMain),
                        onPressed: widget.onTap,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
                Icons.event_note_rounded,
                size: 80,
                color: kGreenMain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Events Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kGreenDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first event',
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

class _AddEventButton extends StatefulWidget {
  @override
  State<_AddEventButton> createState() => _AddEventButtonState();
}

class _AddEventButtonState extends State<_AddEventButton>
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
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: kGreenMain,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Event'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Event Name',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Event_Page')
          .collection('All_Events_of_RC')
          .doc(result)
          .set({
        'Event_Name': result,
        'Cover_Picture': '',
        'Introduction': '',
        'Order': 999, // Default order (lowest priority)
        'Headline_1': '',
        'Headline_1_description': '',
      });

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventEditPage(eventName: result),
          ),
        );
      }
    }
  }
}

// ============================================
// EVENT EDIT PAGE - Edit event details
// ============================================
class EventEditPage extends StatefulWidget {
  final String eventName;

  const EventEditPage({Key? key, required this.eventName}) : super(key: key);

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
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
            .doc('Event_Page')
            .collection('All_Events_of_RC')
            .doc(widget.eventName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading event'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(),

              // Cover Picture Section
              SliverToBoxAdapter(
                child: _CoverPictureSection(
                  eventName: widget.eventName,
                  coverPicture: data['Cover_Picture'] ?? '',
                  onImagePick: _pickAndUploadImage,
                ),
              ),

              // Event Name Section
              SliverToBoxAdapter(
                child: _EditableTextField(
                  label: 'Event Name',
                  value: data['Event_Name'] ?? '',
                  fieldName: 'Event_Name',
                  eventName: widget.eventName,
                  icon: Icons.event_rounded,
                ),
              ),

              // Order Section (Priority)
              SliverToBoxAdapter(
                child: _OrderField(
                  eventName: widget.eventName,
                  currentOrder: data['Order'] ?? 999,
                ),
              ),

              // Introduction Section
              SliverToBoxAdapter(
                child: _EditableTextField(
                  label: 'Introduction',
                  value: data['Introduction'] ?? '',
                  fieldName: 'Introduction',
                  eventName: widget.eventName,
                  icon: Icons.description_rounded,
                  maxLines: 5,
                ),
              ),

              // Dynamic Headlines
              ..._buildHeadlineSections(data),

              // Add More Headline Button
              SliverToBoxAdapter(
                child: _AddHeadlineButton(
                  eventName: widget.eventName,
                  existingHeadlines: _getExistingHeadlineCount(data),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
            widget.eventName,
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

  List<Widget> _buildHeadlineSections(Map<String, dynamic> data) {
    final List<Widget> sections = [];
    int headlineIndex = 1;

    while (data.containsKey('Headline_$headlineIndex')) {
      sections.add(
        SliverToBoxAdapter(
          child: _HeadlineSection(
            headlineNumber: headlineIndex,
            headlineText: data['Headline_$headlineIndex'] ?? '',
            description: data['Headline_${headlineIndex}_description'] ?? '',
            images: _getHeadlineImages(data, headlineIndex),
            eventName: widget.eventName,
            onImagePick: _pickAndUploadImage,
          ),
        ),
      );
      headlineIndex++;
    }

    return sections;
  }

  Map<String, String> _getHeadlineImages(Map<String, dynamic> data, int headlineIndex) {
    final Map<String, String> images = {};
    int imageIndex = 1;

    while (data.containsKey('Headline_${headlineIndex}_Image_$imageIndex')) {
      images['Headline_${headlineIndex}_Image_$imageIndex'] =
          data['Headline_${headlineIndex}_Image_$imageIndex'] ?? '';
      imageIndex++;
    }

    return images;
  }

  int _getExistingHeadlineCount(Map<String, dynamic> data) {
    int count = 0;
    while (data.containsKey('Headline_${count + 1}')) {
      count++;
    }
    return count;
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      // TODO: Upload to Cloudinary and get URL
      // For now, returning placeholder
      // In production, integrate cloudinary_public package:
      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'events'),
      );

// ✅ Success message BEFORE returning
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

// ✅ Return the Cloudinary URL
      return response.secureUrl;



      return 'https://placeholder-url.com/${image.name}';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
  }
}

// Cover Picture Section Widget
class _CoverPictureSection extends StatefulWidget {
  final String eventName;
  final String coverPicture;
  final Future<String?> Function() onImagePick;

  const _CoverPictureSection({
    required this.eventName,
    required this.coverPicture,
    required this.onImagePick,
  });

  @override
  State<_CoverPictureSection> createState() => _CoverPictureSectionState();
}

class _CoverPictureSectionState extends State<_CoverPictureSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isUploading = false;

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
    return FadeTransition(
      opacity: _controller,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image_rounded, color: kGreenMain, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Cover Picture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isUploading ? null : _handleImageChange,
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 60,
                          ),
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
                        gradient: LinearGradient(
                          colors: [kGreenMain, kGreenLight],
                        ),
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
                          : const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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

  Future<void> _handleImageChange() async {
    setState(() => _isUploading = true);

    final imageUrl = await widget.onImagePick();

    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Event_Page')
          .collection('All_Events_of_RC')
          .doc(widget.eventName)
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

// Editable Text Field Widget
class _EditableTextField extends StatefulWidget {
  final String label;
  final String value;
  final String fieldName;
  final String eventName;
  final IconData icon;
  final int maxLines;

  const _EditableTextField({
    required this.label,
    required this.value,
    required this.fieldName,
    required this.eventName,
    required this.icon,
    this.maxLines = 1,
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _textController = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_EditableTextField oldWidget) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.icon, color: kGreenMain, size: 20),
                  const SizedBox(width: 12),
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
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check_circle : Icons.edit_rounded,
                      color: _isEditing ? Colors.green : kGreenMain,
                    ),
                    onPressed: _isEditing ? _saveChanges : _enableEditing,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                enabled: _isEditing,
                maxLines: widget.maxLines,
                style: TextStyle(
                  fontSize: 15,
                  color: _isEditing ? kGreenDark : Colors.grey[700],
                ),
                decoration: InputDecoration(
                  border: _isEditing
                      ? const OutlineInputBorder()
                      : InputBorder.none,
                  filled: _isEditing,
                  fillColor: _isEditing ? Colors.grey[50] : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _enableEditing() {
    setState(() => _isEditing = true);
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

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Event_Page')
        .collection('All_Events_of_RC')
        .doc(widget.eventName)
        .update({widget.fieldName: newValue});

    setState(() => _isEditing = false);

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

// Headline Section Widget
class _HeadlineSection extends StatefulWidget {
  final int headlineNumber;
  final String headlineText;
  final String description;
  final Map<String, String> images;
  final String eventName;
  final Future<String?> Function() onImagePick;

  const _HeadlineSection({
    required this.headlineNumber,
    required this.headlineText,
    required this.description,
    required this.images,
    required this.eventName,
    required this.onImagePick,
  });

  @override
  State<_HeadlineSection> createState() => _HeadlineSectionState();
}

class _HeadlineSectionState extends State<_HeadlineSection>
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
    return FadeTransition(
      opacity: _controller,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: kGreenLight.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline Number Badge with Delete Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kGreenMain, kGreenLight],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Headline ${widget.headlineNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.red),
                      onPressed: () => _handleDeleteHeadline(context),
                      tooltip: 'Delete Headline',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Headline Text
              _HeadlineEditableField(
                label: 'Headline Title',
                value: widget.headlineText,
                fieldName: 'Headline_${widget.headlineNumber}',
                eventName: widget.eventName,
              ),
              const SizedBox(height: 16),

              // Images Section
              if (widget.images.isNotEmpty) ...[
                const Text(
                  'Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.images.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HeadlineImageCard(
                      imageUrl: entry.value,
                      fieldName: entry.key,
                      eventName: widget.eventName,
                      onImagePick: widget.onImagePick,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],

              // Add Image Button
              OutlinedButton.icon(
                onPressed: () => _addNewImage(),
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('Add Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreenMain,
                  side: const BorderSide(color: kGreenMain, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              _HeadlineEditableField(
                label: 'Description',
                value: widget.description,
                fieldName: 'Headline_${widget.headlineNumber}_description',
                eventName: widget.eventName,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteHeadline(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            const Text('Delete Headline'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete Headline ${widget.headlineNumber}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
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
                      'This will delete the headline, all images, and description permanently.',
                      style: TextStyle(
                        fontSize: 13,
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
      await _deleteHeadlineFromFirestore();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Headline ${widget.headlineNumber} deleted successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteHeadlineFromFirestore() async {
    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Event_Page')
        .collection('All_Events_of_RC')
        .doc(widget.eventName);

    // Get current document data
    final doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Create update map to delete all headline-related fields
    final Map<String, dynamic> updateMap = {};

    // Delete headline title
    updateMap['Headline_${widget.headlineNumber}'] = FieldValue.delete();

    // Delete headline description
    updateMap['Headline_${widget.headlineNumber}_description'] = FieldValue.delete();

    // Delete all images for this headline
    int imageIndex = 1;
    while (data.containsKey('Headline_${widget.headlineNumber}_Image_$imageIndex')) {
      updateMap['Headline_${widget.headlineNumber}_Image_$imageIndex'] = FieldValue.delete();
      imageIndex++;
    }

    // Apply all deletions
    await docRef.update(updateMap);
  }

  Future<void> _addNewImage() async {
    final imageUrl = await widget.onImagePick();
    if (imageUrl == null) return;

    final nextImageNumber = widget.images.length + 1;
    final fieldName = 'Headline_${widget.headlineNumber}_Image_$nextImageNumber';

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Event_Page')
        .collection('All_Events_of_RC')
        .doc(widget.eventName)
        .update({fieldName: imageUrl});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _HeadlineEditableField extends StatefulWidget {
  final String label;
  final String value;
  final String fieldName;
  final String eventName;
  final int maxLines;

  const _HeadlineEditableField({
    required this.label,
    required this.value,
    required this.fieldName,
    required this.eventName,
    this.maxLines = 1,
  });

  @override
  State<_HeadlineEditableField> createState() => _HeadlineEditableFieldState();
}

class _HeadlineEditableFieldState extends State<_HeadlineEditableField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_HeadlineEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
      _controller.text = widget.value;
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing ? kGreenMain : Colors.grey[300]!,
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kGreenDark,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_circle : Icons.edit_rounded,
                  color: _isEditing ? Colors.green : kGreenMain,
                  size: 20,
                ),
                onPressed: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            enabled: _isEditing,
            maxLines: widget.maxLines,
            style: TextStyle(
              fontSize: 14,
              color: _isEditing ? kGreenDark : Colors.grey[700],
            ),
            decoration: InputDecoration(
              border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
              filled: _isEditing,
              fillColor: _isEditing ? Colors.grey[50] : Colors.transparent,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final newValue = _controller.text.trim();

    if (newValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Field cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Event_Page')
        .collection('All_Events_of_RC')
        .doc(widget.eventName)
        .update({widget.fieldName: newValue});

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _HeadlineImageCard extends StatefulWidget {
  final String imageUrl;
  final String fieldName;
  final String eventName;
  final Future<String?> Function() onImagePick;

  const _HeadlineImageCard({
    required this.imageUrl,
    required this.fieldName,
    required this.eventName,
    required this.onImagePick,
  });

  @override
  State<_HeadlineImageCard> createState() => _HeadlineImageCardState();
}

class _HeadlineImageCardState extends State<_HeadlineImageCard> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            )
                : Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.add_photo_alternate, size: 40),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.edit_rounded, color: kGreenMain),
                    onPressed: _isUploading ? null : _handleImageChange,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    onPressed: _handleImageDelete,
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
    setState(() => _isUploading = true);

    final imageUrl = await widget.onImagePick();

    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Event_Page')
          .collection('All_Events_of_RC')
          .doc(widget.eventName)
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

    setState(() => _isUploading = false);
  }

  Future<void> _handleImageDelete() async {
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
          .doc('Event_Page')
          .collection('All_Events_of_RC')
          .doc(widget.eventName)
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

// Add Headline Button
class _AddHeadlineButton extends StatelessWidget {
  final String eventName;
  final int existingHeadlines;

  const _AddHeadlineButton({
    required this.eventName,
    required this.existingHeadlines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: () => _addNewHeadline(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add New Headline'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  Future<void> _addNewHeadline(BuildContext context) async {
    final nextHeadlineNumber = existingHeadlines + 1;

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Event_Page')
        .collection('All_Events_of_RC')
        .doc(eventName)
        .update({
      'Headline_$nextHeadlineNumber': 'New Headline $nextHeadlineNumber',
      'Headline_${nextHeadlineNumber}_description': 'Add description here...',
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Headline $nextHeadlineNumber added!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============================================
// ORDER FIELD - Edit event display order/priority
// ============================================
class _OrderField extends StatefulWidget {
  final String eventName;
  final int currentOrder;

  const _OrderField({
    required this.eventName,
    required this.currentOrder,
  });

  @override
  State<_OrderField> createState() => _OrderFieldState();
}

class _OrderFieldState extends State<_OrderField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentOrder.toString());
  }

  @override
  void didUpdateWidget(_OrderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentOrder != widget.currentOrder && !_isEditing) {
      _controller.text = widget.currentOrder.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    final orderValue = int.tryParse(_controller.text.trim());

    if (orderValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (orderValue < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order must be 1 or greater'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Event_Page')
          .collection('All_Events_of_RC')
          .doc(widget.eventName)
          .update({'Order': orderValue});

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Order updated to $orderValue'),
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
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kGreenMain.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    color: kAccentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.low_priority_rounded,
                    color: kAccentGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Display Order (Priority)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kGreenDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lower number = Higher priority (1 shows first)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_rounded),
                    color: kGreenMain,
                    tooltip: 'Edit Order',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Order Number',
                        hintText: 'e.g., 1, 2, 3...',
                        prefixIcon: const Icon(Icons.format_list_numbered),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreenMain, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saveOrder,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _controller.text = widget.currentOrder.toString();
                      setState(() => _isEditing = false);
                    },
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.red,
                    tooltip: 'Cancel',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Events with order 1 appear first, then 2, 3, etc.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGreenLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kGreenLight.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kGreenMain,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.currentOrder.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.currentOrder == 1
                            ? 'Highest Priority (Shows First)'
                            : widget.currentOrder <= 5
                                ? 'High Priority'
                                : widget.currentOrder <= 10
                                    ? 'Medium Priority'
                                    : 'Low Priority',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
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
    );
  }
}


