import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

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

class _AdminPanelMembersPageState extends State<AdminPanelMembersPage> {
  // Brand colors
  static const Color brandStart = Color(0xFF0B6B3A);
  static const Color brandEnd = Color(0xFF16A34A);
  static const Color bgGradientStart = Color(0xFFE8F5E9);
  static const Color bgGradientEnd = Color(0xFFF1F8E9);

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

  Future<void> _showAddMemberDialog() async {
    String? selectedPosition;
    final nameController = TextEditingController();
    final departmentController = TextEditingController();
    final designationController = TextEditingController();
    final emailController = TextEditingController();
    final facebookController = TextEditingController();
    final linkedinController = TextEditingController();
    final orderController = TextEditingController();
    String? imageUrl;
    bool isUploading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: brandStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add, color: brandStart),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Panel Member',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
                      ),
                    ),
                    items: positions.map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPosition = value;
                      });
                    },
                  ),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                        borderSide: const BorderSide(color: brandStart, width: 2),
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
                      backgroundColor: imageUrl != null ? Colors.green : brandStart,
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
                      child: Image.network(
                        imageUrl!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
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
                        if (selectedPosition == null ||
                            nameController.text.trim().isEmpty ||
                            departmentController.text.trim().isEmpty ||
                            designationController.text.trim().isEmpty ||
                            orderController.text.trim().isEmpty ||
                            imageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          // Check if position already exists and get count
                          final docName = await _getDocumentName(selectedPosition!);

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
                            'Position': selectedPosition,
                            'created_at': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$selectedPosition added successfully!'),
                              backgroundColor: brandStart,
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
                  backgroundColor: brandStart,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Member'),
              ),
            ],
          );
        },
      ),
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
    String? selectedPosition = currentData['Position'] ?? docId;
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Edit Panel Member',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    items: positions.map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPosition = value;
                      });
                    },
                  ),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                      child: Image.network(
                        imageUrl!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
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
                        if (selectedPosition == null ||
                            nameController.text.trim().isEmpty ||
                            departmentController.text.trim().isEmpty ||
                            designationController.text.trim().isEmpty ||
                            orderController.text.trim().isEmpty ||
                            imageUrl == null ||
                            imageUrl!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields!'),
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
                            'Position': selectedPosition,
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
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
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
    final double topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart, bgGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [brandStart, brandEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandStart.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.panelTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                widget.semesterId,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Manage panel members',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Content - Members List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(brandStart),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    // Filter out placeholder documents
                    final members = docs.where((doc) => doc.id != '_placeholder').toList();

                    if (members.isEmpty) {
                      return Center(
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
                              'Tap the + button to add members',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.collectionName == 'Executive_Panel'
          ? FloatingActionButton.extended(
              onPressed: _showAddMemberDialog,
              backgroundColor: brandStart,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Member',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
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
                  ? Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 40),
                        );
                      },
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

