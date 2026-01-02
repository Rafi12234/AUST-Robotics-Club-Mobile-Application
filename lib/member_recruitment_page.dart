import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';

class MemberRecruitmentPage extends StatefulWidget {
  const MemberRecruitmentPage({Key? key}) : super(key: key);

  @override
  State<MemberRecruitmentPage> createState() => _MemberRecruitmentPageState();
}

class _MemberRecruitmentPageState extends State<MemberRecruitmentPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _eduMailController = TextEditingController();
  final _imageLinkController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _referralCodeController = TextEditingController();

  // Form Values
  String? _selectedSemester;
  String? _selectedCurrentSemester;
  String _selectedPaymentMethod = 'Bkash';

  // Payment Numbers
  String? _bkashNumber;
  String? _nagadNumber;
  List<String> _availableSemesters = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isFormAccessible = false;
  String _accessMessage = '';

  final List<String> _semesterOptions = [
    '1.1',
    '1.2',
    '2.1',
    '2.2',
    '3.1',
    '3.2',
    '4.1',
    '4.2'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _personalEmailController.dispose();
    _eduMailController.dispose();
    _imageLinkController.dispose();
    _transactionIdController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load payment numbers and access status from Form ON_OFF and Payment Number document
      final paymentDoc = await FirebaseFirestore.instance
          .collection('New_Member_Recruitment')
          .doc('Form ON_OFF and Payment Number')
          .get();

      if (paymentDoc.exists) {
        final data = paymentDoc.data();
        final accessValue = data?['Access'];

        // Check if Access field is true (could be boolean or string "True")
        bool isAccessible = false;
        if (accessValue is bool) {
          isAccessible = accessValue;
        } else if (accessValue is String) {
          isAccessible = accessValue.toLowerCase() == 'true';
        }

        setState(() {
          _isFormAccessible = isAccessible;
          _accessMessage = data?['Message'] ?? 'Form is currently closed';
          _bkashNumber = data?['Bkash'];
          _nagadNumber = data?['Nagad'];
        });

        // If form is not accessible, show alert and return
        if (!_isFormAccessible) {
          setState(() => _isLoading = false);
          _showAccessDeniedDialog();
          return;
        }
      }

      // Load available semesters from New_Members_Informations collection
      final semesterSnapshot = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .get();

      List<String> semesters = [];
      for (var doc in semesterSnapshot.docs) {
        semesters.add(doc.id);
      }

      // If no semesters exist, create default ones or show empty
      if (semesters.isEmpty) {
        // You can optionally create default semester documents here
        // For now, we'll just show empty
        print('No semesters found in New_Members_Informations');
      }

      // Sort semesters if needed (optional)
      semesters.sort();

      setState(() {
        _availableSemesters = semesters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.screenWidth * 0.025)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                size: SizeConfig.screenWidth * 0.1,
                color: Colors.white,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.025),
            Text(
              'Form Currently Closed',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF6B6B),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.012),
            Text(
              _accessMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.025,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.screenHeight * 0.016),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                ),
              ),
              child: Text(
                'Go Back',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.034,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _getNextMemberNumber(String semester) async {
    try {
      // Get all members in the selected semester's Members collection
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(semester)
          .collection('Members')
          .get();

      // Count existing members and add 1 for the new member
      return membersSnapshot.docs.length + 1;
    } catch (e) {
      print('Error getting member number: $e');
      return 1; // Default to 1 if error occurs
    }
  }

  // Check if Transaction ID already exists in the selected semester
  Future<bool> _isTransactionIdDuplicate(
      String semester, String transactionId) async {
    try {
      // Query all members in the selected semester's Members collection
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(semester)
          .collection('Members')
          .get();

      // Check each member's Transaction_ID
      for (var doc in membersSnapshot.docs) {
        final data = doc.data();
        final existingTransactionId =
            data['Transaction_ID']?.toString().trim().toLowerCase();
        if (existingTransactionId == transactionId.trim().toLowerCase()) {
          return true; // Duplicate found
        }
      }
      return false; // No duplicate found
    } catch (e) {
      print('Error checking Transaction ID: $e');
      return false; // In case of error, allow submission (can be changed based on requirements)
    }
  }

  void _showDuplicateTransactionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.screenWidth * 0.025)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: SizeConfig.screenWidth * 0.1,
                color: Colors.white,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.025),
            Text(
              'Duplicate Transaction ID!',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF6B6B),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.012),
            Text(
              'This Transaction ID has already been used. Please provide your actual and valid Transaction ID.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.025,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.screenHeight * 0.016),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.034,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSemester == null) {
      _showErrorSnackBar('Please select your semester');
      return;
    }

    if (_selectedCurrentSemester == null) {
      _showErrorSnackBar('Please select current semester');
      return;
    }

    setState(() => _isSubmitting = true);

    // Check for duplicate Transaction ID
    final transactionId = _transactionIdController.text.trim();
    final isDuplicate = await _isTransactionIdDuplicate(
        _selectedCurrentSemester!, transactionId);

    if (isDuplicate) {
      setState(() => _isSubmitting = false);
      _showDuplicateTransactionDialog();
      return;
    }

    try {
      // Get the next member number
      final memberNumber =
          await _getNextMemberNumber(_selectedCurrentSemester!);
      final memberDocName = 'Member_$memberNumber';

      print(
          'Creating member: $memberDocName in semester: $_selectedCurrentSemester');

      // Create document reference in new structure
      // New_Members_Informations/{semester}/Members/{Member_X}
      final docRef = FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(_selectedCurrentSemester!)
          .collection('Members')
          .doc(memberDocName);

      // Prepare data to save
      final memberData = {
        'Name': _nameController.text.trim(),
        'Department': _departmentController.text.trim(),
        'Semester': _selectedSemester,
        'Current_Semester': _selectedCurrentSemester,
        'Phone_Number': _phoneController.text.trim(),
        'Personal_Email': _personalEmailController.text.trim(),
        'Edu_Mail': _eduMailController.text.trim(),
        'Image_Drive_Link': _imageLinkController.text.trim(),
        'Payment_By': _selectedPaymentMethod,
        'Transaction_ID': _transactionIdController.text.trim(),
        'Referral_Code': _referralCodeController.text.trim(),
        'Member_Number': memberNumber,
        'Submitted_At': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await docRef.set(memberData);

      print('Member successfully added: $memberDocName');

      setState(() => _isSubmitting = false);

      // Show success dialog with member number
      _showSuccessDialog(memberNumber);
    } catch (e) {
      print('Error submitting form: $e');
      setState(() => _isSubmitting = false);
      _showErrorSnackBar('Submission failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(int memberNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.screenWidth * 0.025)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: SizeConfig.screenWidth * 0.1,
                color: Colors.white,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.025),
            Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.016),
            Text(
              'Welcome to the club! Your application has been submitted successfully for $_selectedCurrentSemester.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.025,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.screenHeight * 0.016),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.034,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Curved App Bar
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.18,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.016),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: SizeConfig.screenWidth * 0.045),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                  left: SizeConfig.screenWidth * 0.08,
                  bottom: SizeConfig.screenHeight * 0.013),
              title: Text(
                'Join Our Club',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
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
                    Positioned(
                      right: -SizeConfig.screenWidth * 0.08,
                      top: SizeConfig.screenHeight * 0.025,
                      child: Icon(
                        Icons.group_add_rounded,
                        size: SizeConfig.screenWidth * 0.38,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: SizeConfig.screenWidth * 0.089,
                      bottom: SizeConfig.screenHeight * 0.05,
                      child: Text(
                        'New Member Registration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: SizeConfig.screenWidth * 0.038,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: _isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.08),
                      child: const CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  )
                : !_isFormAccessible
                    ? const SizedBox.shrink()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding:
                              EdgeInsets.all(SizeConfig.screenWidth * 0.034),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Personal Information Section
                                _buildSectionTitle('Personal Information',
                                    Icons.person_outline),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person,
                                  delay: 100,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Name is required'
                                      : null,
                                ),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedTextField(
                                  controller: _departmentController,
                                  label: 'Department',
                                  icon: Icons.school,
                                  delay: 150,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Department is required'
                                      : null,
                                ),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  delay: 200,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Phone number is required'
                                      : null,
                                ),

                                // Academic Information Section
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.034),
                                _buildSectionTitle(
                                    'Academic Information', Icons.menu_book),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),

                                // Semester Selection
                                _buildAnimatedCard(
                                  delay: 250,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.school_rounded,
                                            color: const Color(0xFF2E7D32),
                                            size: SizeConfig.screenWidth * 0.05,
                                          ),
                                          SizedBox(
                                              width: SizeConfig.screenWidth *
                                                  0.02),
                                          Text(
                                            'Select Your Semester',
                                            style: TextStyle(
                                              fontSize: SizeConfig.screenWidth *
                                                  0.038,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1B5E20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              SizeConfig.screenHeight * 0.015),
                                      DropdownButtonFormField<String>(
                                        value: _selectedSemester,
                                        decoration: InputDecoration(
                                          labelText: 'Choose Semester',
                                          prefixIcon: Icon(
                                            Icons.format_list_numbered_rounded,
                                            color: const Color(0xFF2E7D32),
                                            size: SizeConfig.screenWidth * 0.05,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                SizeConfig.screenWidth * 0.03),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                SizeConfig.screenWidth * 0.03),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                SizeConfig.screenWidth * 0.03),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF2E7D32),
                                                width: 2),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                SizeConfig.screenWidth * 0.04,
                                            vertical:
                                                SizeConfig.screenHeight * 0.018,
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.screenWidth * 0.03),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: const Color(0xFF2E7D32),
                                          size: SizeConfig.screenWidth * 0.06,
                                        ),
                                        items: _semesterOptions.map((semester) {
                                          return DropdownMenuItem(
                                            value: semester,
                                            child: Text(
                                              'Semester $semester',
                                              style: TextStyle(
                                                fontSize:
                                                    SizeConfig.screenWidth *
                                                        0.038,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedSemester = value);
                                        },
                                        validator: (value) => value == null
                                            ? 'Please select your semester'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),

                                // Current Semester Dropdown (Registration Semester)
                                _buildAnimatedCard(
                                  delay: 300,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: const Color(0xFF2E7D32),
                                            size:
                                                SizeConfig.screenWidth * 0.025,
                                          ),
                                          SizedBox(
                                              width: SizeConfig.screenWidth *
                                                  0.016),
                                          Text(
                                            'Registration Semester',
                                            style: TextStyle(
                                              fontSize: SizeConfig.screenWidth *
                                                  0.038,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1B5E20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              SizeConfig.screenHeight * 0.012),
                                      if (_availableSemesters.isEmpty)
                                        Container(
                                          padding: EdgeInsets.all(
                                              SizeConfig.screenWidth * 0.034),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(
                                                SizeConfig.screenWidth * 0.025),
                                            border: Border.all(
                                              color: Colors.orange,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_rounded,
                                                color: Colors.orange,
                                                size: SizeConfig.screenWidth *
                                                    0.025,
                                              ),
                                              SizedBox(
                                                  width:
                                                      SizeConfig.screenWidth *
                                                          0.025),
                                              Expanded(
                                                child: Text(
                                                  'No semesters available. Please contact admin.',
                                                  style: TextStyle(
                                                    color: Colors.orange[900],
                                                    fontSize:
                                                        SizeConfig.screenWidth *
                                                            0.025,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        DropdownButtonFormField<String>(
                                          value: _selectedCurrentSemester,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Select Registration Semester',
                                            prefixIcon: Icon(
                                              Icons.event_available_rounded,
                                              color: const Color(0xFF2E7D32),
                                              size: SizeConfig.screenWidth *
                                                  0.032,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeConfig.screenWidth *
                                                          0.025),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal:
                                                  SizeConfig.screenWidth *
                                                      0.034,
                                              vertical:
                                                  SizeConfig.screenHeight *
                                                      0.016,
                                            ),
                                          ),
                                          items: _availableSemesters
                                              .map((semester) {
                                            return DropdownMenuItem(
                                              value: semester,
                                              child: Text(
                                                semester,
                                                style: TextStyle(
                                                  fontSize:
                                                      SizeConfig.screenWidth *
                                                          0.034,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() =>
                                                _selectedCurrentSemester =
                                                    value);
                                          },
                                          validator: (value) => value == null
                                              ? 'Please select registration semester'
                                              : null,
                                        ),
                                      SizedBox(
                                          height:
                                              SizeConfig.screenHeight * 0.01),
                                      Text(
                                        'Select the semester you are registering for',
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.screenWidth * 0.025,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Contact Information Section
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.034),
                                _buildSectionTitle('Contact Information',
                                    Icons.email_outlined),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedTextField(
                                  controller: _personalEmailController,
                                  label: 'Personal Email',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  delay: 350,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return 'Email is required';
                                    if (!value!.contains('@'))
                                      return 'Invalid email format';
                                    return null;
                                  },
                                ),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedTextField(
                                  controller: _eduMailController,
                                  label: 'Educational Email',
                                  icon: Icons.school,
                                  keyboardType: TextInputType.emailAddress,
                                  delay: 400,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return 'Educational email is required';
                                    if (!value!.contains('@'))
                                      return 'Invalid email format';
                                    return null;
                                  },
                                ),

                                // Referral Code Section
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.034),
                                _buildSectionTitle(
                                    'Referral Information', Icons.people_outline),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedCard(
                                  delay: 450,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _referralCodeController,
                                        style: TextStyle(fontSize: SizeConfig.screenWidth * 0.038),
                                        decoration: InputDecoration(
                                          labelText: 'Referral Code (Optional)',
                                          labelStyle: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
                                          hintText: 'Enter referrer\'s name',
                                          hintStyle: TextStyle(
                                            fontSize: SizeConfig.screenWidth * 0.032,
                                            color: Colors.grey[400],
                                          ),
                                          prefixIcon: Icon(
                                            Icons.person_add_alt_1_rounded,
                                            color: const Color(0xFF2E7D32),
                                            size: SizeConfig.screenWidth * 0.05,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                                            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: SizeConfig.screenWidth * 0.04,
                                            vertical: SizeConfig.screenHeight * 0.018,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: SizeConfig.screenHeight * 0.01),
                                      Text(
                                        'Enter the name of your AUSTRC Panel Member or Batch Representative, if applicable',
                                        style: TextStyle(
                                          fontSize: SizeConfig.screenWidth * 0.025,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Payment Section
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.034),
                                _buildSectionTitle(
                                    'Payment Information', Icons.payment),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),

                                // Must Send Money Notice
                                _buildAnimatedCard(
                                  delay: 500,
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        SizeConfig.screenWidth * 0.034),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFF6B6B)
                                              .withOpacity(0.1),
                                          const Color(0xFFEE5A6F)
                                              .withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.025),
                                      border: Border.all(
                                        color: const Color(0xFFFF6B6B),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                              SizeConfig.screenWidth * 0.016),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF6B6B),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.warning_rounded,
                                            color: Colors.white,
                                            size:
                                                SizeConfig.screenWidth * 0.025,
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                SizeConfig.screenWidth * 0.025),
                                        Expanded(
                                          child: Text(
                                            'MUST SEND MONEY\nBefore submitting the form',
                                            style: TextStyle(
                                              fontSize: SizeConfig.screenWidth *
                                                  0.025,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFF6B6B),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),

                                // Payment Numbers
                                if (_bkashNumber != null)
                                  _buildAnimatedCard(
                                    delay: 550,
                                    child: _buildPaymentNumberCard(
                                      'Bkash',
                                      _bkashNumber!,
                                      Colors.pink,
                                      Icons.account_balance_wallet,
                                    ),
                                  ),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.012),
                                if (_nagadNumber != null)
                                  _buildAnimatedCard(
                                    delay: 600,
                                    child: _buildPaymentNumberCard(
                                      'Nagad',
                                      _nagadNumber!,
                                      Colors.orange,
                                      Icons.account_balance_wallet_outlined,
                                    ),
                                  ),

                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),

                                // Payment Method Selection
                                _buildAnimatedCard(
                                  delay: 650,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Method Used',
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.screenWidth * 0.034,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              SizeConfig.screenHeight * 0.012),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildPaymentOption(
                                                'Bkash', Colors.pink),
                                          ),
                                          SizedBox(
                                              width: SizeConfig.screenWidth *
                                                  0.025),
                                          Expanded(
                                            child: _buildPaymentOption(
                                                'Nagad', Colors.orange),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.016),
                                _buildAnimatedTextField(
                                  controller: _transactionIdController,
                                  label: 'Transaction ID',
                                  icon: Icons.receipt_long,
                                  delay: 700,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Transaction ID is required'
                                      : null,
                                ),

                                // Submit Button
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.034),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: SizeConfig.screenHeight * 0.06,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isSubmitting ? null : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2E7D32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.screenWidth * 0.034),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: _isSubmitting
                                          ? SizedBox(
                                              height: SizeConfig.screenWidth *
                                                  0.025,
                                              width: SizeConfig.screenWidth *
                                                  0.025,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.send_rounded,
                                                    color: Colors.white,
                                                    size:
                                                        SizeConfig.screenWidth *
                                                            0.025),
                                                SizedBox(
                                                    width:
                                                        SizeConfig.screenWidth *
                                                            0.016),
                                                Text(
                                                  'Submit Application',
                                                  style: TextStyle(
                                                    fontSize:
                                                        SizeConfig.screenWidth *
                                                            0.032,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.025),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
          ),
          child: Icon(icon,
              color: Colors.white, size: SizeConfig.screenWidth * 0.045),
        ),
        SizedBox(width: SizeConfig.screenWidth * 0.03),
        Text(
          title,
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, SizeConfig.screenHeight * 0.025 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.034),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              blurRadius: SizeConfig.screenWidth * 0.025,
              offset: Offset(0, SizeConfig.screenHeight * 0.005),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: SizeConfig.screenWidth * 0.038),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
            prefixIcon: Icon(icon,
                color: const Color(0xFF2E7D32),
                size: SizeConfig.screenWidth * 0.05),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(SizeConfig.screenWidth * 0.035),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.04,
              vertical: SizeConfig.screenHeight * 0.018,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, SizeConfig.screenHeight * 0.025 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.034),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              blurRadius: SizeConfig.screenWidth * 0.025,
              offset: Offset(0, SizeConfig.screenHeight * 0.005),
            ),
          ],
        ),
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.034),
        child: child,
      ),
    );
  }

  Widget _buildPaymentNumberCard(
      String method, String number, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.034),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(SizeConfig.screenWidth * 0.025),
            ),
            child: Icon(icon,
                color: Colors.white, size: SizeConfig.screenWidth * 0.025),
          ),
          SizedBox(width: SizeConfig.screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method,
                  style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.025,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.005),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        number,
                        style: TextStyle(
                          fontSize: SizeConfig.screenWidth * 0.032,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy,
                          size: SizeConfig.screenWidth * 0.025),
                      color: color,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: number));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$method number copied!'),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, Color color) {
    final isSelected = _selectedPaymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.012),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey,
              size: SizeConfig.screenWidth * 0.032,
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.016),
            Text(
              method,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
                fontSize: SizeConfig.screenWidth * 0.034,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
