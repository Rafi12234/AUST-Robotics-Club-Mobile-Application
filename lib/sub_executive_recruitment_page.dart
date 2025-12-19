import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';

class SubExecutiveRecruitmentPage extends StatefulWidget {
  const SubExecutiveRecruitmentPage({Key? key}) : super(key: key);

  @override
  State<SubExecutiveRecruitmentPage> createState() =>
      _SubExecutiveRecruitmentPageState();
}

class _SubExecutiveRecruitmentPageState
    extends State<SubExecutiveRecruitmentPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _eduMailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _austRcIdController = TextEditingController();
  final _whyJoinController = TextEditingController();
  final _previousClubController = TextEditingController();
  final _eventExperienceController = TextEditingController();
  final _roboticsProjectController = TextEditingController();
  final _imageLinkController = TextEditingController();

  // Form Values
  String? _selectedSemester;
  String? _selectedRecruitmentSemester;
  bool _isAustRcMember = false;

  // Available Departments for Sub Executive
  final List<String> _departmentOptions = [
    'Administration',
    'Graphics Design',
    'Event Management',
    'Content Writing & Social Media',
    'Research and Development',
    'Public Relation',
    'Website Development',
  ];

  List<String> _selectedDepartments = [];
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

  // Theme Colors for Sub Executive
  final Color _primaryColor = const Color(0xFF6A1B9A);
  final Color _secondaryColor = const Color(0xFF8E24AA);
  final Color _lightColor = const Color(0xFFE1BEE7);

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
    _phoneController.dispose();
    _eduMailController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _austRcIdController.dispose();
    _whyJoinController.dispose();
    _previousClubController.dispose();
    _eventExperienceController.dispose();
    _roboticsProjectController.dispose();
    _imageLinkController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load access status from centralized settings doc
      // New location: Collection: New_Member_Recruitment -> Document: 'Form ON_OFF and Payment Number'
      // Field for sub-exec access: 'Sub_Executive_Form_Access'
      // Message field: 'Message for Sub Executive'
      final settingsDoc = await FirebaseFirestore.instance
          .collection('New_Member_Recruitment')
          .doc('Form ON_OFF and Payment Number')
          .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data();

        // Allow a couple of fallback names for compatibility
        final accessValue = data?['Sub_Executive_Form_Access'] ?? data?['Sub Executive Form Access'] ?? data?['Access'];

        bool isAccessible = false;
        if (accessValue is bool) {
          isAccessible = accessValue;
        } else if (accessValue is String) {
          isAccessible = accessValue.toLowerCase() == 'true';
        }

        setState(() {
          _isFormAccessible = isAccessible;
          _accessMessage = data?['Message for Sub Executive'] ?? data?['Message'] ?? 'Form is currently closed';
        });

        if (!_isFormAccessible) {
          setState(() => _isLoading = false);
          _showAccessDeniedDialog();
          return;
        }
      } else {
        // If settings document doesn't exist, assume form is accessible
        setState(() {
          _isFormAccessible = true;
        });
      }

      // Load available semesters from Sub-Executive_Recruitment collection
      final semesterSnapshot = await FirebaseFirestore.instance
          .collection('Sub-Executive_Recruitment')
          .get();

      List<String> semesters = [];
      for (var doc in semesterSnapshot.docs) {
        // Exclude the Settings document
        if (doc.id != 'Settings') {
          semesters.add(doc.id);
        }
      }

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
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
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
              'Applications Closed',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
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
                backgroundColor: _primaryColor,
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
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('Sub-Executive_Recruitment')
          .doc(semester)
          .collection('Members')
          .get();

      return membersSnapshot.docs.length + 1;
    } catch (e) {
      print('Error getting member number: $e');
      return 1;
    }
  }

  void _showDepartmentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(_selectedDepartments);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(SizeConfig.screenWidth * 0.04),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                      ),
                      borderRadius:
                      BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: SizeConfig.screenWidth * 0.05,
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      'Select Departments',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose one or more departments you\'re interested in',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.032,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.02),
                    ..._departmentOptions.map((dept) {
                      final isSelected = tempSelected.contains(dept);
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: SizeConfig.screenHeight * 0.01),
                        child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                tempSelected.remove(dept);
                              } else {
                                tempSelected.add(dept);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(
                              SizeConfig.screenWidth * 0.025),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.screenWidth * 0.03,
                              vertical: SizeConfig.screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _lightColor.withOpacity(0.5)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.screenWidth * 0.025),
                              border: Border.all(
                                color:
                                isSelected ? _primaryColor : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  color:
                                  isSelected ? _primaryColor : Colors.grey,
                                  size: SizeConfig.screenWidth * 0.055,
                                ),
                                SizedBox(width: SizeConfig.screenWidth * 0.03),
                                Expanded(
                                  child: Text(
                                    dept,
                                    style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.035,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? _primaryColor
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: SizeConfig.screenWidth * 0.035,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDepartments = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartments.isEmpty) {
      _showErrorSnackBar('Please select at least one department');
      return;
    }

    if (_selectedSemester == null) {
      _showErrorSnackBar('Please select your semester');
      return;
    }

    if (_selectedRecruitmentSemester == null) {
      _showErrorSnackBar('Please select recruitment semester');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final memberNumber =
      await _getNextMemberNumber(_selectedRecruitmentSemester!);
      final memberDocName = 'Member_$memberNumber';

      final docRef = FirebaseFirestore.instance
          .collection('Sub-Executive_Recruitment')
          .doc(_selectedRecruitmentSemester!)
          .collection('Members')
          .doc(memberDocName);

      final memberData = {
        'Name': _nameController.text.trim(),
        'Phone_Number': _phoneController.text.trim(),
        'Edu_Mail': _eduMailController.text.trim(),
        'Student_ID': _studentIdController.text.trim(),
        'Interested_Departments': _selectedDepartments,
        'Semester': _selectedSemester,
        'Department': _departmentController.text.trim(),
        'Is_AUST_RC_Member': _isAustRcMember,
        'AUST_RC_ID': _isAustRcMember ? _austRcIdController.text.trim() : 'N/A',
        'Why_Join_Panel': _whyJoinController.text.trim(),
        'Previous_Club_Experience': _previousClubController.text.trim(),
        'Event_Management_Experience': _eventExperienceController.text.trim(),
        'Robotics_Projects': _roboticsProjectController.text.trim(),
        'Image_Drive_Link': _imageLinkController.text.trim(),
        'Recruitment_Semester': _selectedRecruitmentSemester,
        'Member_Number': memberNumber,
        'Submitted_At': FieldValue.serverTimestamp(),
        'Status': 'Pending',
      };

      await docRef.set(memberData);

      setState(() => _isSubmitting = false);
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
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
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
              'Application Submitted!',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.016),
            Text(
              'Your Sub Executive application for $_selectedRecruitmentSemester has been submitted successfully. We will review your application and get back to you soon!',
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
                backgroundColor: _primaryColor,
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
          // Curved App Bar with Purple Theme
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.18,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: _primaryColor,
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
                'Sub Executive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryColor,
                      _secondaryColor,
                      const Color(0xFFAB47BC),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -SizeConfig.screenWidth * 0.08,
                      top: SizeConfig.screenHeight * 0.025,
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: SizeConfig.screenWidth * 0.38,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: SizeConfig.screenWidth * 0.089,
                      bottom: SizeConfig.screenHeight * 0.05,
                      child: Text(
                        'Leadership Application',
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
                child: CircularProgressIndicator(
                  color: _primaryColor,
                ),
              ),
            )
                : !_isFormAccessible
                ? const SizedBox.shrink()
                : FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.034),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionTitle(
                          'Personal Information', Icons.person_outline),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        delay: 100,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Name is required'
                            : null,
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        delay: 150,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Phone number is required'
                            : null,
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _eduMailController,
                        label: 'Educational Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        delay: 200,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Email is required';
                          if (!value!.contains('@'))
                            return 'Invalid email format';
                          return null;
                        },
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _studentIdController,
                        label: 'Student ID',
                        icon: Icons.badge,
                        delay: 250,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Student ID is required'
                            : null,
                      ),

                      // Academic Information Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle(
                          'Academic Information', Icons.school),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextField(
                        controller: _departmentController,
                        label: 'Department (Academic)',
                        icon: Icons.account_balance,
                        delay: 300,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Department is required'
                            : null,
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      // Semester Selection
                      _buildAnimatedCard(
                        delay: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: _primaryColor,
                                  size: SizeConfig.screenWidth * 0.05,
                                ),
                                SizedBox(
                                    width:
                                    SizeConfig.screenWidth * 0.02),
                                Text(
                                  'Your Current Semester',
                                  style: TextStyle(
                                    fontSize:
                                    SizeConfig.screenWidth * 0.038,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
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
                                labelText: 'Select Semester',
                                prefixIcon: Icon(
                                  Icons.format_list_numbered_rounded,
                                  color: _primaryColor,
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
                                  borderSide: BorderSide(
                                      color: _primaryColor, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.screenWidth * 0.03),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _primaryColor,
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

                      // Department Interest Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle('Department Interest',
                          Icons.category_rounded),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedCard(
                        delay: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Which departments are you interested in?',
                              style: TextStyle(
                                fontSize:
                                SizeConfig.screenWidth * 0.038,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            SizedBox(
                                height:
                                SizeConfig.screenHeight * 0.01),
                            Text(
                              'You can select multiple departments',
                              style: TextStyle(
                                fontSize:
                                SizeConfig.screenWidth * 0.03,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(
                                height:
                                SizeConfig.screenHeight * 0.015),
                            InkWell(
                              onTap: _showDepartmentSelectionDialog,
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.screenWidth * 0.025),
                              child: Container(
                                padding: EdgeInsets.all(
                                    SizeConfig.screenWidth * 0.035),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.screenWidth * 0.025),
                                  border: Border.all(
                                    color: _selectedDepartments.isEmpty
                                        ? Colors.grey[300]!
                                        : _primaryColor,
                                    width: _selectedDepartments.isEmpty
                                        ? 1
                                        : 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.touch_app_rounded,
                                      color: _primaryColor,
                                      size:
                                      SizeConfig.screenWidth * 0.05,
                                    ),
                                    SizedBox(
                                        width: SizeConfig.screenWidth *
                                            0.03),
                                    Expanded(
                                      child: Text(
                                        _selectedDepartments.isEmpty
                                            ? 'Tap to select departments'
                                            : '${_selectedDepartments.length} department(s) selected',
                                        style: TextStyle(
                                          fontSize:
                                          SizeConfig.screenWidth *
                                              0.035,
                                          color: _selectedDepartments
                                              .isEmpty
                                              ? Colors.grey[600]
                                              : _primaryColor,
                                          fontWeight:
                                          _selectedDepartments
                                              .isEmpty
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: _primaryColor,
                                      size:
                                      SizeConfig.screenWidth * 0.04,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_selectedDepartments.isNotEmpty) ...[
                              SizedBox(
                                  height:
                                  SizeConfig.screenHeight * 0.015),
                              Wrap(
                                spacing: SizeConfig.screenWidth * 0.02,
                                runSpacing:
                                SizeConfig.screenHeight * 0.008,
                                children:
                                _selectedDepartments.map((dept) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                      SizeConfig.screenWidth *
                                          0.025,
                                      vertical:
                                      SizeConfig.screenHeight *
                                          0.006,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _primaryColor,
                                          _secondaryColor
                                        ],
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(
                                          SizeConfig.screenWidth *
                                              0.04),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          dept,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            SizeConfig.screenWidth *
                                                0.028,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                            SizeConfig.screenWidth *
                                                0.01),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedDepartments
                                                  .remove(dept);
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size:
                                            SizeConfig.screenWidth *
                                                0.035,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Club Membership Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle(
                          'Club Membership', Icons.card_membership),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedCard(
                        delay: 450,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Are you currently a member of AUST Robotics Club?',
                              style: TextStyle(
                                fontSize:
                                SizeConfig.screenWidth * 0.036,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            SizedBox(
                                height:
                                SizeConfig.screenHeight * 0.012),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMembershipOption(
                                      'Yes', true),
                                ),
                                SizedBox(
                                    width:
                                    SizeConfig.screenWidth * 0.03),
                                Expanded(
                                  child: _buildMembershipOption(
                                      'No', false),
                                ),
                              ],
                            ),
                            if (_isAustRcMember) ...[
                              SizedBox(
                                  height:
                                  SizeConfig.screenHeight * 0.016),
                              TextFormField(
                                controller: _austRcIdController,
                                decoration: InputDecoration(
                                  labelText: 'AUST RC ID',
                                  hintText: 'Enter your AUST RC ID',
                                  prefixIcon: Icon(
                                    Icons.badge_outlined,
                                    color: _primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.screenWidth * 0.025),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (_isAustRcMember &&
                                      (value?.isEmpty ?? true)) {
                                    return 'Please provide your AUST RC ID';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Recruitment Semester Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle(
                          'Recruitment Semester', Icons.event_available),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedCard(
                        delay: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _primaryColor,
                                  size: SizeConfig.screenWidth * 0.05,
                                ),
                                SizedBox(
                                    width:
                                    SizeConfig.screenWidth * 0.02),
                                Text(
                                  'Select Recruitment Semester',
                                  style: TextStyle(
                                    fontSize:
                                    SizeConfig.screenWidth * 0.038,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
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
                                      size:
                                      SizeConfig.screenWidth * 0.06,
                                    ),
                                    SizedBox(
                                        width: SizeConfig.screenWidth *
                                            0.025),
                                    Expanded(
                                      child: Text(
                                        'No recruitment semesters available. Please contact admin.',
                                        style: TextStyle(
                                          color: Colors.orange[900],
                                          fontSize:
                                          SizeConfig.screenWidth *
                                              0.032,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              DropdownButtonFormField<String>(
                                value: _selectedRecruitmentSemester,
                                decoration: InputDecoration(
                                  labelText:
                                  'Select Recruitment Semester',
                                  prefixIcon: Icon(
                                    Icons.event_available_rounded,
                                    color: _primaryColor,
                                    size:
                                    SizeConfig.screenWidth * 0.05,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.screenWidth * 0.025),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.screenWidth * 0.025),
                                items:
                                _availableSemesters.map((semester) {
                                  return DropdownMenuItem(
                                    value: semester,
                                    child: Text(
                                      semester,
                                      style: TextStyle(
                                        fontSize:
                                        SizeConfig.screenWidth *
                                            0.038,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() =>
                                  _selectedRecruitmentSemester =
                                      value);
                                },
                                validator: (value) => value == null
                                    ? 'Please select recruitment semester'
                                    : null,
                              ),
                          ],
                        ),
                      ),

                      // Experience Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle(
                          'Experience & Motivation', Icons.psychology),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextArea(
                        controller: _whyJoinController,
                        label:
                        'Why do you want to join panel as a Sub Executive?',
                        icon: Icons.question_answer,
                        delay: 550,
                        maxLines: 4,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'This field is required'
                            : null,
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextArea(
                        controller: _previousClubController,
                        label:
                        'Have you previously been involved with any club or organization? If yes, please mention the name and your role:',
                        icon: Icons.groups,
                        delay: 600,
                        maxLines: 3,
                        hintText: 'e.g., Drama Club - Secretary',
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextArea(
                        controller: _eventExperienceController,
                        label:
                        'Do you have any prior experience in organizing or managing events? If yes, please describe your responsibilities briefly:',
                        icon: Icons.event,
                        delay: 650,
                        maxLines: 3,
                        hintText:
                        'Describe your event management experience',
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextArea(
                        controller: _roboticsProjectController,
                        label:
                        'Do you have any Robotics-related projects? If yes, please provide a short description:',
                        icon: Icons.smart_toy,
                        delay: 700,
                        maxLines: 3,
                        hintText: 'Describe your robotics projects',
                      ),

                      // Image Link Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle(
                          'Profile Image', Icons.image),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextField(
                        controller: _imageLinkController,
                        label: 'Image Drive Link',
                        icon: Icons.link,
                        delay: 750,
                        hintText:
                        'Paste your Google Drive image link here',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Image link is required'
                            : null,
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.012),
                      _buildAnimatedCard(
                        delay: 800,
                        child: Container(
                          padding:
                          EdgeInsets.all(SizeConfig.screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(
                                SizeConfig.screenWidth * 0.02),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: SizeConfig.screenWidth * 0.05,
                              ),
                              SizedBox(
                                  width:
                                  SizeConfig.screenWidth * 0.025),
                              Expanded(
                                child: Text(
                                  'Upload a formal photo to Google Drive and paste the shareable link here. Make sure the link is set to "Anyone with the link can view".',
                                  style: TextStyle(
                                    fontSize:
                                    SizeConfig.screenWidth * 0.028,
                                    color: Colors.blue[800],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Submit Button
                      SizedBox(height: SizeConfig.screenHeight * 0.04),
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
                          height: SizeConfig.screenHeight * 0.065,
                          child: ElevatedButton(
                            onPressed:
                            _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.screenWidth * 0.035),
                              ),
                              elevation: 4,
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                              height:
                              SizeConfig.screenWidth * 0.06,
                              width:
                              SizeConfig.screenWidth * 0.06,
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
                                Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: SizeConfig.screenWidth *
                                      0.055,
                                ),
                                SizedBox(
                                    width:
                                    SizeConfig.screenWidth *
                                        0.02),
                                Text(
                                  'Submit Application',
                                  style: TextStyle(
                                    fontSize:
                                    SizeConfig.screenWidth *
                                        0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.03),
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
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
            ),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
          ),
          child:
          Icon(icon, color: Colors.white, size: SizeConfig.screenWidth * 0.045),
        ),
        SizedBox(width: SizeConfig.screenWidth * 0.03),
        Text(
          title,
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
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
    String? hintText,
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
              color: _primaryColor.withOpacity(0.08),
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
            hintText: hintText,
            labelStyle: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
            prefixIcon:
            Icon(icon, color: _primaryColor, size: SizeConfig.screenWidth * 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.035),
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

  Widget _buildAnimatedTextArea({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    int maxLines = 3,
    String? hintText,
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
              color: _primaryColor.withOpacity(0.08),
              blurRadius: SizeConfig.screenWidth * 0.025,
              offset: Offset(0, SizeConfig.screenHeight * 0.005),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Label - Full visibility
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.screenHeight * 0.015,
                left: SizeConfig.screenWidth * 0.04,
                right: SizeConfig.screenWidth * 0.04,
                bottom: SizeConfig.screenHeight * 0.008,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: _primaryColor,
                    size: SizeConfig.screenWidth * 0.05,
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.025),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.034,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Field
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              validator: validator,
              style: TextStyle(fontSize: SizeConfig.screenWidth * 0.036),
              decoration: InputDecoration(
                hintText: hintText ?? 'Enter your answer here...',
                hintStyle: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.032,
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                  vertical: SizeConfig.screenHeight * 0.015,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
          ],
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
              color: _primaryColor.withOpacity(0.08),
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

  Widget _buildMembershipOption(String label, bool value) {
    final isSelected = _isAustRcMember == value;
    return InkWell(
      onTap: () => setState(() => _isAustRcMember = value),
      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected ? _lightColor.withOpacity(0.5) : Colors.grey[100],
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _primaryColor : Colors.grey,
              size: SizeConfig.screenWidth * 0.05,
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? _primaryColor : Colors.grey[700],
                fontSize: SizeConfig.screenWidth * 0.038,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
