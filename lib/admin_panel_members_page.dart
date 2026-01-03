import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminPanelMembersPage extends StatefulWidget {
  final String semesterId;
  final String panelTitle;
  final String collectionName;

  const AdminPanelMembersPage({
    Key? key,
    required this.semesterId,
    required this.panelTitle,
    required this.collectionName,
  }) : super(key: key);

  @override
  State<AdminPanelMembersPage> createState() => _AdminPanelMembersPageState();
}

class _AdminPanelMembersPageState extends State<AdminPanelMembersPage>
    with SingleTickerProviderStateMixin {
  // Theme colors - matching other admin pages
  static const Color kGreenDark = Color(0xFF0F3D2E);
  static const Color kGreenMain = Color(0xFF2D6A4F);
  static const Color kGreenLight = Color(0xFF52B788);

  late AnimationController _headerController;

  // Special value for custom position option
  static const String _customPositionOption = '___CUSTOM_POSITION___';

  final List<String> positions = [
    'Advisor',
    'Treasurer',
    'President',
    'Vice President',
    'Joint Secretary',
    'General Secretary',
    'Organizing Secretary',
    'Executive Director',
    'Assistant Director - Admin',
    'Assistant Director - CW',
    'Assistant Director - Event Management',
    'Assistant Director - GFX',
    'Assistant Director - PR',
    'Assistant Director - R&D',
    'Assistant Director - Web',
    'Bootcamp Co-Ordinator',
  ];

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

  Future<void> _showAddMemberDialog() async {
    String? selectedPosition;
    final nameController = TextEditingController();
    final departmentController = TextEditingController();
    final designationController = TextEditingController();
    final emailController = TextEditingController();
    final facebookController = TextEditingController();
    final linkedinController = TextEditingController();
    final orderController = TextEditingController();
    final customPositionController = TextEditingController();
    bool isCustomPosition = false;
    String? imageUrl;
    bool isUploading = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Add Member',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: FadeTransition(
                opacity: animation,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: kGreenMain.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 24,
                  contentPadding: EdgeInsets.zero,
                  titlePadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kGreenDark, kGreenMain],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kGreenMain.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add Panel Member',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fill in the details below',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxHeight: 480),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Position Dropdown
                          const Text(
                            'Select Position*',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedPosition,
                            decoration: InputDecoration(
                              hintText: 'Choose position',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                            items: [
                              ...positions.map((position) {
                                return DropdownMenuItem(
                                  value: position,
                                  child: Text(position),
                                );
                              }),
                              const DropdownMenuItem(
                                value: _customPositionOption,
                                child: Row(
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 18, color: kGreenMain),
                                    SizedBox(width: 8),
                                    Text(
                                      'Other (Custom Position)',
                                      style: TextStyle(
                                        color: kGreenMain,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPosition = value;
                                isCustomPosition = value == _customPositionOption;
                                if (!isCustomPosition) {
                                  customPositionController.clear();
                                }
                              });
                            },
                          ),
                          
                          // Custom Position TextField (shown only when "Other" is selected)
                          if (isCustomPosition) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: customPositionController,
                              decoration: InputDecoration(
                                labelText: 'Custom Position Name*',
                                hintText: 'Enter your custom position',
                                prefixIcon: const Icon(Icons.badge_outlined, color: kGreenMain),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: kGreenMain, width: 2),
                                ),
                                filled: true,
                                fillColor: kGreenMain.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Name
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name*',
                              hintText: 'Enter member name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Department
                          TextField(
                            controller: departmentController,
                            decoration: InputDecoration(
                              labelText: 'Department*',
                              hintText: 'e.g., CSE',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Designation
                          TextField(
                            controller: designationController,
                            decoration: InputDecoration(
                              labelText: 'Designation*',
                              hintText: 'e.g., Student',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'member@example.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Facebook
                          TextField(
                            controller: facebookController,
                            decoration: InputDecoration(
                              labelText: 'Facebook URL',
                              hintText: 'https://facebook.com/...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // LinkedIn
                          TextField(
                            controller: linkedinController,
                            decoration: InputDecoration(
                              labelText: 'LinkedIn URL',
                              hintText: 'https://linkedin.com/in/...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Order
                          TextField(
                            controller: orderController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Order*',
                              hintText: 'Display order (e.g., 1, 2, 3...)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Image Upload
                          const Text(
                            'Profile Image*',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: isUploading
                                ? null
                                : () async {
                              setDialogState(() => isUploading = true);
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );

                              if (pickedFile != null) {
                                try {
                                  final url = await _uploadImageToCloudinary(
                                    pickedFile.path,
                                  );
                                  setDialogState(() {
                                    imageUrl = url;
                                    isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Image uploaded successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  setDialogState(() => isUploading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Upload failed: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                setDialogState(() => isUploading = false);
                              }
                            },
                            icon: isUploading
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.upload_file),
                            label: Text(isUploading
                                ? 'Uploading...'
                                : (imageUrl != null ? 'Image Uploaded ✓' : 'Upload Image')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: imageUrl != null ? Colors.green : kGreenMain,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (imageUrl != null) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                        // Determine final position value
                        final String? finalPosition = isCustomPosition
                            ? customPositionController.text.trim()
                            : selectedPosition;

                        if (selectedPosition == null ||
                            (isCustomPosition && customPositionController.text.trim().isEmpty) ||
                            nameController.text.trim().isEmpty ||
                            departmentController.text.trim().isEmpty ||
                            designationController.text.trim().isEmpty ||
                            orderController.text.trim().isEmpty ||
                            imageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isCustomPosition && customPositionController.text.trim().isEmpty
                                  ? 'Please enter a custom position name!'
                                  : 'Please fill all required fields!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          // Check if position already exists and get count
                          final docName = await _getDocumentName(finalPosition!);

                          await FirebaseFirestore.instance
                              .collection('All_Data')
                              .doc('Governing_Panel')
                              .collection('Semesters')
                              .doc(widget.semesterId)
                              .collection(widget.collectionName)
                              .doc(docName)
                              .set({
                            'Name': nameController.text.trim(),
                            'Department': departmentController.text.trim(),
                            'Designation': designationController.text.trim(),
                            'Email': emailController.text.trim(),
                            'Facebook': facebookController.text.trim(),
                            'LinkedIn': linkedinController.text.trim(),
                            'Image': imageUrl,
                            'Order': int.parse(orderController.text.trim()),
                            'Position': finalPosition,
                            'created_at': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$finalPosition added successfully!'),
                              backgroundColor: kGreenMain,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenMain,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Member'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _getDocumentName(String position) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Governing_Panel')
        .collection('Semesters')
        .doc(widget.semesterId)
        .collection(widget.collectionName)
        .get();

    // Count how many documents with this position exist
    int count = 0;
    for (var doc in snapshot.docs) {
      if (doc.id.startsWith(position)) {
        count++;
      }
    }

    if (count == 0) {
      return position;
    } else {
      return '$position ${count + 1}';
    }
  }

  Future<String> _uploadImageToCloudinary(String imagePath) async {
    final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(imagePath, folder: 'governing_panel'),
    );
    return response.secureUrl;
  }

  Future<void> _showEditMemberDialog(String docId, Map<String, dynamic> currentData) async {
    // Check if current position is in the predefined list
    String currentPosition = currentData['Position'] ?? docId;
    bool isCustomPosition = !positions.contains(currentPosition);
    
    String? selectedPosition = isCustomPosition ? _customPositionOption : currentPosition;
    final customPositionController = TextEditingController(
      text: isCustomPosition ? currentPosition : '',
    );
    
    final nameController = TextEditingController(text: currentData['Name'] ?? '');
    final departmentController = TextEditingController(text: currentData['Department'] ?? '');
    final designationController = TextEditingController(text: currentData['Designation'] ?? '');
    final emailController = TextEditingController(text: currentData['Email'] ?? '');
    final facebookController = TextEditingController(text: currentData['Facebook'] ?? '');
    final linkedinController = TextEditingController(text: currentData['LinkedIn'] ?? '');

    // Handle Order field
    int currentOrder = 0;
    if (currentData['Order'] != null) {
      if (currentData['Order'] is int) {
        currentOrder = currentData['Order'];
      } else if (currentData['Order'] is String) {
        currentOrder = int.tryParse(currentData['Order']) ?? 0;
      }
    }
    final orderController = TextEditingController(text: currentOrder.toString());

    String? imageUrl = currentData['Image'] ?? '';
    bool isUploading = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Edit Member',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: FadeTransition(
                opacity: animation,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: kGreenMain.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 24,
                  contentPadding: EdgeInsets.zero,
                  titlePadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kGreenDark, kGreenMain],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kGreenMain.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Edit Panel Member',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Update the details below',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxHeight: 480),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Position Dropdown
                          const Text(
                            'Select Position*',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedPosition,
                            decoration: InputDecoration(
                              hintText: 'Choose position',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                            items: [
                              ...positions.map((position) {
                                return DropdownMenuItem(
                                  value: position,
                                  child: Text(position),
                                );
                              }),
                              const DropdownMenuItem(
                                value: _customPositionOption,
                                child: Row(
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 18, color: kGreenMain),
                                    SizedBox(width: 8),
                                    Text(
                                      'Other (Custom Position)',
                                      style: TextStyle(
                                        color: kGreenMain,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPosition = value;
                                isCustomPosition = value == _customPositionOption;
                                if (!isCustomPosition) {
                                  customPositionController.clear();
                                }
                              });
                            },
                          ),
                          
                          // Custom Position TextField (shown only when "Other" is selected)
                          if (isCustomPosition) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: customPositionController,
                              decoration: InputDecoration(
                                labelText: 'Custom Position Name*',
                                hintText: 'Enter your custom position',
                                prefixIcon: const Icon(Icons.badge_outlined, color: kGreenMain),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: kGreenMain, width: 2),
                                ),
                                filled: true,
                                fillColor: kGreenMain.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Name
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name*',
                              hintText: 'Enter member name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Department
                          TextField(
                            controller: departmentController,
                            decoration: InputDecoration(
                              labelText: 'Department*',
                              hintText: 'e.g., CSE',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Designation
                          TextField(
                            controller: designationController,
                            decoration: InputDecoration(
                              labelText: 'Designation*',
                              hintText: 'e.g., Student',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'member@example.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Facebook
                          TextField(
                            controller: facebookController,
                            decoration: InputDecoration(
                              labelText: 'Facebook URL',
                              hintText: 'https://facebook.com/...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // LinkedIn
                          TextField(
                            controller: linkedinController,
                            decoration: InputDecoration(
                              labelText: 'LinkedIn URL',
                              hintText: 'https://linkedin.com/in/...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Order
                          TextField(
                            controller: orderController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Order*',
                              hintText: 'Display order (e.g., 1, 2, 3...)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kGreenMain, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Image Upload
                          const Text(
                            'Profile Image*',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: isUploading
                                ? null
                                : () async {
                              setDialogState(() => isUploading = true);
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );

                              if (pickedFile != null) {
                                try {
                                  final url = await _uploadImageToCloudinary(
                                    pickedFile.path,
                                  );
                                  setDialogState(() {
                                    imageUrl = url;
                                    isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Image uploaded successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  setDialogState(() => isUploading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Upload failed: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                setDialogState(() => isUploading = false);
                              }
                            },
                            icon: isUploading
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.upload_file),
                            label: Text(isUploading
                                ? 'Uploading...'
                                : 'Change Image'),
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
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                        // Determine final position value
                        final String? finalPosition = isCustomPosition
                            ? customPositionController.text.trim()
                            : selectedPosition;

                        if (selectedPosition == null ||
                            (isCustomPosition && customPositionController.text.trim().isEmpty) ||
                            nameController.text.trim().isEmpty ||
                            departmentController.text.trim().isEmpty ||
                            designationController.text.trim().isEmpty ||
                            orderController.text.trim().isEmpty ||
                            imageUrl == null ||
                            imageUrl!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isCustomPosition && customPositionController.text.trim().isEmpty
                                  ? 'Please enter a custom position name!'
                                  : 'Please fill all required fields!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection('All_Data')
                              .doc('Governing_Panel')
                              .collection('Semesters')
                              .doc(widget.semesterId)
                              .collection(widget.collectionName)
                              .doc(docId)
                              .update({
                            'Name': nameController.text.trim(),
                            'Department': departmentController.text.trim(),
                            'Designation': designationController.text.trim(),
                            'Email': emailController.text.trim(),
                            'Facebook': facebookController.text.trim(),
                            'LinkedIn': linkedinController.text.trim(),
                            'Image': imageUrl,
                            'Order': int.parse(orderController.text.trim()),
                            'Position': finalPosition,
                            'updated_at': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Member updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenMain,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update Member'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMember(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Member?'),
        content: const Text('Are you sure you want to delete this member?'),
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
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Governing_Panel')
            .collection('Semesters')
            .doc(widget.semesterId)
            .collection(widget.collectionName)
            .doc(docId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

          // Content - Members List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Governing_Panel')
                .collection('Semesters')
                .doc(widget.semesterId)
                .collection(widget.collectionName)
                .orderBy('Order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kGreenMain),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Filter out placeholder documents
              final members = docs.where((doc) => doc.id != '_placeholder').toList();

              if (members.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No members yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.collectionName == 'Executive_Panel'
                              ? 'Tap the + button to add members'
                              : 'No members added yet',
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

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final member = members[index];
                      final data = member.data() as Map<String, dynamic>;

                      // Handle Order field - can be String or int
                      int order = 0;
                      if (data['Order'] != null) {
                        if (data['Order'] is int) {
                          order = data['Order'];
                        } else if (data['Order'] is String) {
                          order = int.tryParse(data['Order']) ?? 0;
                        }
                      }

                      return _MemberCard(
                        docId: member.id,
                        name: data['Name'] ?? '',
                        position: data['Position'] ?? member.id,
                        department: data['Department'] ?? '',
                        designation: data['Designation'] ?? '',
                        email: data['Email'] ?? '',
                        imageUrl: data['Image'] ?? '',
                        order: order,
                        memberData: data,
                        onEdit: () => _showEditMemberDialog(member.id, data),
                        onDelete: () => _deleteMember(member.id),
                      );
                    },
                    childCount: members.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: widget.collectionName == 'Executive_Panel'
          ? FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        backgroundColor: kGreenMain,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Member',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
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
          title: FadeTransition(
            opacity: _headerController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.panelTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  widget.semesterId,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

class _MemberCard extends StatelessWidget {
  final String docId;
  final String name;
  final String position;
  final String department;
  final String designation;
  final String email;
  final String imageUrl;
  final int order;
  final Map<String, dynamic> memberData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.docId,
    required this.name,
    required this.position,
    required this.department,
    required this.designation,
    required this.email,
    required this.imageUrl,
    required this.order,
    required this.memberData,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40),
                ),
              )
                  : Container(
                width: 70,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(width: 16),

            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$designation, $department',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Order: $order',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}