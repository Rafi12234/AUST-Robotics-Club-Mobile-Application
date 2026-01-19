import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';

// Model for department questions
class DepartmentQuestion {
  final String questionId;
  final String question;
  final TextEditingController controller;

  DepartmentQuestion({
    required this.questionId,
    required this.question,
  }) : controller = TextEditingController();

  void dispose() {
    controller.dispose();
  }
}

class SubExecutiveRecruitmentPage extends StatefulWidget {
  const SubExecutiveRecruitmentPage({Key? key}) : super(key: key);

  @override
  State<SubExecutiveRecruitmentPage> createState() =>
      _SubExecutiveRecruitmentPageState();
}

class _SubExecutiveRecruitmentPageState
    extends State<SubExecutiveRecruitmentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _questionAnimationController;
  late AnimationController _departmentCardController;
  late AnimationController _pulseController;

  // Controllers for fixed fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _eduMailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _austRcIdController = TextEditingController();
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
    'Software Development',
  ];

  // Department icons and colors
  final Map<String, IconData> _departmentIcons = {
    'Administration': Icons.admin_panel_settings_rounded,
    'Graphics Design': Icons.palette_rounded,
    'Event Management': Icons.event_rounded,
    'Content Writing & Social Media': Icons.edit_note_rounded,
    'Research and Development': Icons.science_rounded,
    'Public Relation': Icons.people_rounded,
    'Software Development': Icons.code_rounded,
  };

  final Map<String, List<Color>> _departmentGradients = {
    'Administration': [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
    'Graphics Design': [const Color(0xFFE91E63), const Color(0xFFFF5722)],
    'Event Management': [const Color(0xFF2196F3), const Color(0xFF00BCD4)],
    'Content Writing & Social Media': [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
    'Research and Development': [const Color(0xFF3F51B5), const Color(0xFF673AB7)],
    'Public Relation': [const Color(0xFFFF9800), const Color(0xFFFFC107)],
    'Software Development': [const Color(0xFF00BCD4), const Color(0xFF009688)],
  };

  List<String> _selectedDepartments = [];
  List<String> _availableSemesters = [];

  // Dynamic questions map: department -> list of questions
  Map<String, List<DepartmentQuestion>> _departmentQuestions = {};

  // Current department tab for questions
  int _currentDepartmentTabIndex = 0;
  late TabController _departmentTabController;

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isFormAccessible = false;
  bool _isLoadingQuestions = false;
  String _accessMessage = '';

  final List<String> _semesterOptions = [
    '1.1', '1.2', '2.1', '2.2', '3.1', '3.2', '4.1', '4.2'
  ];

  // Theme Colors
  final Color _primaryColor = const Color(0xFF6A1B9A);
  final Color _secondaryColor = const Color(0xFF8E24AA);
  final Color _lightColor = const Color(0xFFE1BEE7);

  // ScrollController
  final ScrollController _scrollController = ScrollController();

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

    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _departmentCardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _departmentTabController = TabController(length: 0, vsync: this);

    _animationController.forward();
    _loadData();
  }

  void _updateTabController() {
    _departmentTabController.dispose();
    _departmentTabController = TabController(
      length: _selectedDepartments.length,
      vsync: this,
      initialIndex: _currentDepartmentTabIndex.clamp(0, _selectedDepartments.length - 1),
    );
    _departmentTabController.addListener(() {
      if (!_departmentTabController.indexIsChanging) {
        setState(() {
          _currentDepartmentTabIndex = _departmentTabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _questionAnimationController.dispose();
    _departmentCardController.dispose();
    _pulseController.dispose();
    _departmentTabController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _eduMailController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _austRcIdController.dispose();
    _imageLinkController.dispose();

    // Dispose all question controllers
    for (var questions in _departmentQuestions.values) {
      for (var q in questions) {
        q.dispose();
      }
    }

    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final settingsDoc = await FirebaseFirestore.instance
          .collection('New_Member_Recruitment')
          .doc('Form ON_OFF and Payment Number')
          .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data();
        final accessValue = data?['Sub_Executive_Form_Access'] ??
            data?['Sub Executive Form Access'] ??
            data?['Access'];

        bool isAccessible = false;
        if (accessValue is bool) {
          isAccessible = accessValue;
        } else if (accessValue is String) {
          isAccessible = accessValue.toLowerCase() == 'true';
        }

        setState(() {
          _isFormAccessible = isAccessible;
          _accessMessage = data?['Message for Sub Executive'] ??
              data?['Message'] ??
              'Form is currently closed';
        });

        if (!_isFormAccessible) {
          setState(() => _isLoading = false);
          _showAccessDeniedDialog();
          return;
        }
      } else {
        setState(() => _isFormAccessible = true);
      }

      final semesterSnapshot = await FirebaseFirestore.instance
          .collection('Sub-Executive_Recruitment')
          .get();

      List<String> semesters = [];
      for (var doc in semesterSnapshot.docs) {
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

  Future<void> _loadQuestionsForDepartment(String department) async {
    if (_selectedRecruitmentSemester == null) return;

    try {
      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('Sub-Executive_Recruitment')
          .doc(_selectedRecruitmentSemester!)
          .collection(department)
          .orderBy(FieldPath.documentId)
          .get();

      List<DepartmentQuestion> questions = [];
      for (var doc in questionsSnapshot.docs) {
        final questionText = doc.data()['Question'] as String? ?? '';
        if (questionText.isNotEmpty) {
          questions.add(DepartmentQuestion(
            questionId: doc.id,
            question: questionText,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _departmentQuestions[department] = questions;
        });
      }
    } catch (e) {
      print('Error loading questions for $department: $e');
    }
  }

  Future<void> _loadQuestionsForAllSelectedDepartments() async {
    if (_selectedRecruitmentSemester == null || _selectedDepartments.isEmpty) return;

    setState(() => _isLoadingQuestions = true);

    // Dispose old question controllers
    for (var questions in _departmentQuestions.values) {
      for (var q in questions) {
        q.dispose();
      }
    }
    _departmentQuestions.clear();

    // Load questions for each selected department
    for (String dept in _selectedDepartments) {
      await _loadQuestionsForDepartment(dept);
    }

    _currentDepartmentTabIndex = 0;
    _updateTabController();

    setState(() => _isLoadingQuestions = false);
    _questionAnimationController.reset();
    _questionAnimationController.forward();
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                size: SizeConfig.screenWidth * 0.12,
                color: Colors.white,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.03),
            Text(
              'Applications Closed',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.015),
            Text(
              _accessMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.035,
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
                    vertical: SizeConfig.screenHeight * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                ),
              ),
              child: Text(
                'Go Back',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.04,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<String> tempSelected = List.from(_selectedDepartments);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: SizeConfig.screenHeight * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConfig.screenWidth * 0.06),
                  topRight: Radius.circular(SizeConfig.screenWidth * 0.06),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.screenHeight * 0.015),
                    width: SizeConfig.screenWidth * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor, _secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: Colors.white,
                            size: SizeConfig.screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(width: SizeConfig.screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Departments',
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                              Text(
                                '${tempSelected.length} selected',
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.032,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[600],
                            size: SizeConfig.screenWidth * 0.06,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  // Department list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                      itemCount: _departmentOptions.length,
                      itemBuilder: (context, index) {
                        final dept = _departmentOptions[index];
                        final isSelected = tempSelected.contains(dept);
                        final gradientColors = _departmentGradients[dept] ?? [_primaryColor, _secondaryColor];

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(SizeConfig.screenWidth * 0.1 * (1 - value), 0),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.012),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    if (isSelected) {
                                      tempSelected.remove(dept);
                                    } else {
                                      tempSelected.add(dept);
                                    }
                                  });
                                  HapticFeedback.lightImpact();
                                },
                                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(colors: gradientColors)
                                        : null,
                                    color: isSelected ? null : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: gradientColors[0].withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.2)
                                              : gradientColors[0].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                                        ),
                                        child: Icon(
                                          _departmentIcons[dept] ?? Icons.business,
                                          color: isSelected ? Colors.white : gradientColors[0],
                                          size: SizeConfig.screenWidth * 0.06,
                                        ),
                                      ),
                                      SizedBox(width: SizeConfig.screenWidth * 0.04),
                                      Expanded(
                                        child: Text(
                                          dept,
                                          style: TextStyle(
                                            fontSize: SizeConfig.screenWidth * 0.038,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? Colors.white : Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.015),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isSelected ? Icons.check_rounded : Icons.add_rounded,
                                          color: isSelected ? gradientColors[0] : Colors.grey[600],
                                          size: SizeConfig.screenWidth * 0.045,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Confirm button
                  Container(
                    padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: SizeConfig.screenHeight * 0.06,
                        child: ElevatedButton(
                          onPressed: tempSelected.isEmpty
                              ? null
                              : () {
                            setState(() {
                              _selectedDepartments = tempSelected;
                            });
                            Navigator.pop(context);
                            // Load questions for selected departments
                            if (_selectedRecruitmentSemester != null) {
                              _loadQuestionsForAllSelectedDepartments();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.035),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            tempSelected.isEmpty
                                ? 'Select at least one department'
                                : 'Confirm Selection (${tempSelected.length})',
                            style: TextStyle(
                              color: tempSelected.isEmpty ? Colors.grey[600] : Colors.white,
                              fontSize: SizeConfig.screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

    // Validate all department questions are answered
    for (String dept in _selectedDepartments) {
      final questions = _departmentQuestions[dept] ?? [];
      for (var question in questions) {
        if (question.controller.text.trim().isEmpty) {
          _showErrorSnackBar('Please answer all questions for $dept');
          // Navigate to that department's tab
          final index = _selectedDepartments.indexOf(dept);
          if (index >= 0) {
            _departmentTabController.animateTo(index);
          }
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final memberNumber = await _getNextMemberNumber(_selectedRecruitmentSemester!);
      final memberDocName = 'Member_$memberNumber';

      // Build department answers
      Map<String, dynamic> departmentAnswers = {};
      for (String dept in _selectedDepartments) {
        final questions = _departmentQuestions[dept] ?? [];
        Map<String, String> answers = {};
        for (var question in questions) {
          answers[question.questionId] = question.controller.text.trim();
        }
        departmentAnswers[dept] = answers;
      }

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
        'Department_Answers': departmentAnswers,
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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
        ),
        margin: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
      ),
    );
  }

  void _showSuccessDialog(int memberNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: SizeConfig.screenWidth * 0.12,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.03),
            Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.015),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: _lightColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
              ),
              child: Text(
                'Application #$memberNumber',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.015),
            Text(
              'Your Sub Executive application for $_selectedRecruitmentSemester has been submitted successfully.\n\nSelected Departments:\n${_selectedDepartments.join(', ')}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.032,
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
                    vertical: SizeConfig.screenHeight * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.04,
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
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Curved App Bar
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
                    color: Colors.white, size: SizeConfig.screenWidth * 0.05),
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
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1 + (_pulseController.value * 0.05),
                            child: Icon(
                              Icons.admin_panel_settings_rounded,
                              size: SizeConfig.screenWidth * 0.38,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          );
                        },
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
                child: Column(
                  children: [
                    CircularProgressIndicator(color: _primaryColor),
                    SizedBox(height: SizeConfig.screenHeight * 0.02),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: SizeConfig.screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : !_isFormAccessible
                ? const SizedBox.shrink()
                : FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionTitle('Personal Information', Icons.person_outline),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                        delay: 100,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        delay: 150,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Phone number is required' : null,
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _eduMailController,
                        label: 'Educational Email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        delay: 200,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Email is required';
                          if (!value!.contains('@')) return 'Invalid email format';
                          return null;
                        },
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),
                      _buildAnimatedTextField(
                        controller: _studentIdController,
                        label: 'Student ID',
                        icon: Icons.badge_rounded,
                        delay: 250,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Student ID is required' : null,
                      ),

                      // Academic Information Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle('Academic Information', Icons.school),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextField(
                        controller: _departmentController,
                        label: 'Department (Academic)',
                        icon: Icons.account_balance_rounded,
                        delay: 300,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Department is required' : null,
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      // Semester Selection
                      _buildAnimatedCard(
                        delay: 350,
                        child: _buildDropdownField(
                          label: 'Your Current Semester',
                          value: _selectedSemester,
                          items: _semesterOptions.map((s) => 'Semester $s').toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSemester = value?.replaceAll('Semester ', '');
                            });
                          },
                          icon: Icons.school_rounded,
                        ),
                      ),

                      // Recruitment Semester Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle('Recruitment Semester', Icons.event_available),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedCard(
                        delay: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_availableSemesters.isEmpty)
                              _buildWarningBox('No recruitment semesters available.')
                            else
                              _buildDropdownField(
                                label: 'Select Recruitment Semester',
                                value: _selectedRecruitmentSemester,
                                items: _availableSemesters,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRecruitmentSemester = value;
                                    // Clear and reload questions when semester changes
                                    if (_selectedDepartments.isNotEmpty) {
                                      _loadQuestionsForAllSelectedDepartments();
                                    }
                                  });
                                },
                                icon: Icons.calendar_today_rounded,
                              ),
                          ],
                        ),
                      ),

                      // Department Selection Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle('Department Interest', Icons.category_rounded),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildDepartmentSelectionCard(),

                      // Club Membership Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle('Club Membership', Icons.card_membership),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedCard(
                        delay: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Are you currently a member of AUST Robotics Club?',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.036,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            SizedBox(height: SizeConfig.screenHeight * 0.015),
                            Row(
                              children: [
                                Expanded(child: _buildMembershipOption('Yes', true)),
                                SizedBox(width: SizeConfig.screenWidth * 0.03),
                                Expanded(child: _buildMembershipOption('No', false)),
                              ],
                            ),
                            if (_isAustRcMember) ...[
                              SizedBox(height: SizeConfig.screenHeight * 0.016),
                              TextFormField(
                                controller: _austRcIdController,
                                decoration: InputDecoration(
                                  labelText: 'AUST RC ID',
                                  hintText: 'Enter your AUST RC ID',
                                  prefixIcon: Icon(Icons.badge_outlined, color: _primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (_isAustRcMember && (value?.isEmpty ?? true)) {
                                    return 'Please provide your AUST RC ID';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Dynamic Department Questions Section
                      if (_selectedDepartments.isNotEmpty) ...[
                        SizedBox(height: SizeConfig.screenHeight * 0.034),
                        _buildSectionTitle('Department Questions', Icons.quiz_rounded),
                        SizedBox(height: SizeConfig.screenHeight * 0.016),
                        _buildDepartmentQuestionsSection(),
                      ],

                      // Image Link Section
                      SizedBox(height: SizeConfig.screenHeight * 0.034),
                      _buildSectionTitle('Profile Image', Icons.image_rounded),
                      SizedBox(height: SizeConfig.screenHeight * 0.016),

                      _buildAnimatedTextField(
                        controller: _imageLinkController,
                        label: 'Image Drive Link',
                        icon: Icons.link_rounded,
                        delay: 600,
                        hintText: 'Paste your Google Drive image link here',
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Image link is required' : null,
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.012),
                      _buildInfoBox(
                        'Upload a formal photo to Google Drive and paste the shareable link here. Make sure the link is set to "Anyone with the link can view".',
                        Icons.info_outline_rounded,
                        Colors.blue,
                      ),

                      // Submit Button
                      SizedBox(height: SizeConfig.screenHeight * 0.04),
                      _buildSubmitButton(),
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

  Widget _buildDepartmentSelectionCard() {
    return _buildAnimatedCard(
      delay: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which departments are you interested in?',
            style: TextStyle(
              fontSize: SizeConfig.screenWidth * 0.038,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.008),
          Text(
            'You can select multiple departments. Each department may have specific questions.',
            style: TextStyle(
              fontSize: SizeConfig.screenWidth * 0.03,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),

          // Selection Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDepartmentSelectionDialog,
              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
              child: Container(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                decoration: BoxDecoration(
                  gradient: _selectedDepartments.isEmpty
                      ? null
                      : LinearGradient(
                    colors: [
                      _primaryColor.withOpacity(0.1),
                      _secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  color: _selectedDepartments.isEmpty ? Colors.grey[100] : null,
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                  border: Border.all(
                    color: _selectedDepartments.isEmpty ? Colors.grey[300]! : _primaryColor,
                    width: _selectedDepartments.isEmpty ? 1 : 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white,
                        size: SizeConfig.screenWidth * 0.05,
                      ),
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDepartments.isEmpty
                                ? 'Tap to select departments'
                                : '${_selectedDepartments.length} department(s) selected',
                            style: TextStyle(
                              fontSize: SizeConfig.screenWidth * 0.038,
                              color: _selectedDepartments.isEmpty
                                  ? Colors.grey[600]
                                  : _primaryColor,
                              fontWeight: _selectedDepartments.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          if (_selectedDepartments.isEmpty)
                            Text(
                              'Required',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.028,
                                color: Colors.red[400],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _primaryColor,
                      size: SizeConfig.screenWidth * 0.045,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected departments chips
          if (_selectedDepartments.isNotEmpty) ...[
            SizedBox(height: SizeConfig.screenHeight * 0.02),
            Wrap(
              spacing: SizeConfig.screenWidth * 0.02,
              runSpacing: SizeConfig.screenHeight * 0.01,
              children: _selectedDepartments.map((dept) {
                final gradientColors = _departmentGradients[dept] ?? [_primaryColor, _secondaryColor];
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.03,
                      vertical: SizeConfig.screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _departmentIcons[dept] ?? Icons.business,
                          color: Colors.white,
                          size: SizeConfig.screenWidth * 0.04,
                        ),
                        SizedBox(width: SizeConfig.screenWidth * 0.015),
                        Text(
                          dept,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.screenWidth * 0.028,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: SizeConfig.screenWidth * 0.01),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDepartments.remove(dept);
                              _departmentQuestions[dept]?.forEach((q) => q.dispose());
                              _departmentQuestions.remove(dept);
                              if (_selectedDepartments.isNotEmpty) {
                                _updateTabController();
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.screenWidth * 0.005),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: SizeConfig.screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDepartmentQuestionsSection() {
    if (_isLoadingQuestions) {
      return _buildAnimatedCard(
        delay: 550,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.screenWidth * 0.08),
            child: Column(
              children: [
                CircularProgressIndicator(color: _primaryColor),
                SizedBox(height: SizeConfig.screenHeight * 0.02),
                Text(
                  'Loading questions...',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: SizeConfig.screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_selectedDepartments.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildAnimatedCard(
      delay: 550,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department Tabs
          if (_selectedDepartments.length > 1) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
              ),
              child: TabBar(
                controller: _departmentTabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.03,
                  fontWeight: FontWeight.normal,
                ),
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _departmentGradients[_selectedDepartments[_currentDepartmentTabIndex]] ??
                        [_primaryColor, _secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                ),
                indicatorPadding: EdgeInsets.all(SizeConfig.screenWidth * 0.01),
                dividerColor: Colors.transparent,
                tabs: _selectedDepartments.map((dept) {
                  return Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.02),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _departmentIcons[dept] ?? Icons.business,
                            size: SizeConfig.screenWidth * 0.04,
                          ),
                          SizedBox(width: SizeConfig.screenWidth * 0.015),
                          Text(dept.split(' ').first),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.025),
          ],

          // Questions for current department
          _buildQuestionsForDepartment(_selectedDepartments[_currentDepartmentTabIndex]),

          // Navigation hints for multiple departments
          if (_selectedDepartments.length > 1) ...[
            SizedBox(height: SizeConfig.screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _selectedDepartments.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.01),
                  width: index == _currentDepartmentTabIndex
                      ? SizeConfig.screenWidth * 0.06
                      : SizeConfig.screenWidth * 0.02,
                  height: SizeConfig.screenWidth * 0.02,
                  decoration: BoxDecoration(
                    color: index == _currentDepartmentTabIndex
                        ? _primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.01),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionsForDepartment(String department) {
    final questions = _departmentQuestions[department] ?? [];
    final gradientColors = _departmentGradients[department] ?? [_primaryColor, _secondaryColor];

    if (questions.isEmpty) {
      return _buildInfoBox(
        'No questions available for $department at the moment.',
        Icons.info_outline_rounded,
        gradientColors[0],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department Header
        Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.03),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientColors[0].withOpacity(0.1), gradientColors[1].withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
            border: Border.all(color: gradientColors[0].withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                ),
                child: Icon(
                  _departmentIcons[department] ?? Icons.business,
                  color: Colors.white,
                  size: SizeConfig.screenWidth * 0.05,
                ),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department,
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: gradientColors[0],
                      ),
                    ),
                    Text(
                      '${questions.length} question(s)',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.03,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // Questions List
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, SizeConfig.screenHeight * 0.02 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.02),
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.screenWidth * 0.025,
                          vertical: SizeConfig.screenHeight * 0.005,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                        ),
                        child: Text(
                          'Q${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.03),
                      Expanded(
                        child: Text(
                          question.question,
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.015),
                  TextFormField(
                    controller: question.controller,
                    maxLines: 4,
                    style: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
                    decoration: InputDecoration(
                      hintText: 'Enter your answer here...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: SizeConfig.screenWidth * 0.032,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                        borderSide: BorderSide(color: gradientColors[0], width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(SizeConfig.screenWidth * 0.035),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'This question is required' : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor],
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSubmitting ? null : _submitForm,
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
            child: Container(
              height: SizeConfig.screenHeight * 0.07,
              alignment: Alignment.center,
              child: _isSubmitting
                  ? SizedBox(
                height: SizeConfig.screenWidth * 0.06,
                width: SizeConfig.screenWidth * 0.06,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: SizeConfig.screenWidth * 0.055,
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.025),
                  Text(
                    'Submit Application',
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.042,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
            ),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: SizeConfig.screenWidth * 0.05),
        ),
        SizedBox(width: SizeConfig.screenWidth * 0.035),
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
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.035),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
              blurRadius: SizeConfig.screenWidth * 0.03,
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
            prefixIcon: Icon(icon, color: _primaryColor, size: SizeConfig.screenWidth * 0.055),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.035),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.04,
              vertical: SizeConfig.screenHeight * 0.02,
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
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
              blurRadius: SizeConfig.screenWidth * 0.03,
              offset: Offset(0, SizeConfig.screenHeight * 0.005),
            ),
          ],
        ),
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
        child: child,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _primaryColor, size: SizeConfig.screenWidth * 0.05),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.038,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.015),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
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
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.04,
              vertical: SizeConfig.screenHeight * 0.018,
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _primaryColor,
            size: SizeConfig.screenWidth * 0.06,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.038,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Please select an option' : null,
        ),
      ],
    );
  }

  Widget _buildMembershipOption(String label, bool value) {
    final isSelected = _isAustRcMember == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _isAustRcMember = value);
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.018),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [_primaryColor, _secondaryColor])
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? Colors.white : Colors.grey,
                size: SizeConfig.screenWidth * 0.055,
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.02),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: SizeConfig.screenWidth * 0.04,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBox(String message) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
        border: Border.all(color: Colors.orange, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange, size: SizeConfig.screenWidth * 0.06),
          SizedBox(width: SizeConfig.screenWidth * 0.03),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: SizeConfig.screenWidth * 0.033,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String message, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.035),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: SizeConfig.screenWidth * 0.05),
          SizedBox(width: SizeConfig.screenWidth * 0.03),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.03,
                color: color.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}