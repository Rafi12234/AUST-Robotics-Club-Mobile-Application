import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';

/// ============================================
/// AUST RC BRAND COLORS
/// ============================================
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kGreenDeep = Color(0xFF0F3D2E);
const kGreenAccent = Color(0xFF1A5C43);
const kGreenLight = Color(0xFFB8E6D5);
const kOnPrimary = Colors.white;

/// ============================================
/// FAQ/FEEDBACK PAGE
/// ============================================
class FAQFeedbackPage extends StatefulWidget {
  const FAQFeedbackPage({super.key});

  @override
  State<FAQFeedbackPage> createState() => _FAQFeedbackPageState();
}

class _FAQFeedbackPageState extends State<FAQFeedbackPage>
    with TickerProviderStateMixin {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _austIdController = TextEditingController();
  final _feedbackController = TextEditingController();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // State Variables
  bool _isLoading = false;
  bool _isSubmitted = false;
  int _currentStep = 0;
  String? _selectedDepartment;

  // Department List
  final List<String> _departments = [
    'Computer Science & Engineering (CSE)',
    'Electrical & Electronic Engineering (EEE)',
    'Civil Engineering (CE)',
    'Industrial & Production Engineering (IPE)',
    'Mechanical & Production Engineering (MPE)',
    'Textile Engineering (TE)',
    'Architecture (ARCH)',
    'Business Administration (BBA)',
  ];

  // FAQ Items
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How can I become a member of AUST Robotics Club?',
      'answer':
      'You can become a member by registering through our official app or website during the membership drive. Follow our social media pages for announcements about new member registrations.',
    },
    {
      'question': 'What are the benefits of joining AUST Robotics Club?',
      'answer':
      'Members get access to workshops, robotics competitions, networking opportunities, hands-on projects, mentorship from seniors, and exclusive club events.',
    },
    {
      'question': 'Do I need prior robotics experience to join?',
      'answer':
      'No! We welcome members of all skill levels. Our workshops and training sessions are designed to help beginners learn from scratch.',
    },
    {
      'question': 'How can I participate in competitions?',
      'answer':
      'Active members can participate in National and International robotics competitions. Team selections are based on skills, dedication, and availability.',
    },
    {
      'question': 'How can I contact the club for more information?',
      'answer':
      'You can reach us through our official Facebook page, Instagram, or email. You can also use this feedback form to send us your queries.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _austIdController.dispose();
    _feedbackController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Validate AUST ID format
  bool _isValidAustId(String id) {
    // Must be exactly 11 digits, no other characters
    // Accepts: 21010401234 only
    final regex = RegExp(r'^\d{11}$');
    return regex.hasMatch(id.trim());
  }

  // Show confirmation dialog
  Future<bool> _showConfirmationDialog() async {
    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kGreenMain.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: kGreenMain,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirm Submission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to submit this feedback?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConfirmationRow(
                            'Name', _nameController.text),
                        const SizedBox(height: 8),
                        _buildConfirmationRow(
                            'Department', _selectedDepartment ?? ''),
                        const SizedBox(height: 8),
                        _buildConfirmationRow(
                            'AUST ID', _austIdController.text),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, false);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenMain,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ) ??
        false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Submit feedback to Firebase
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      // Create document name from user info
      final documentName =
          '${_nameController.text.trim()}_${_austIdController.text.trim()}';

      // Prepare data
      final feedbackData = {
        'name': _nameController.text.trim(),
        'department': _selectedDepartment,
        'austId': _austIdController.text.trim(),
        'feedback': _feedbackController.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': Theme.of(context).platform.toString(),
        },
      };

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('FAQ Data')
          .doc(documentName)
          .set(feedbackData);

      // Show success state
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });

      // Reset animations for success state
      _scaleController.reset();
      _scaleController.forward();

      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to submit feedback. Please try again.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // Reset form
  void _resetForm() {
    setState(() {
      _isSubmitted = false;
      _currentStep = 0;
      _nameController.clear();
      _departmentController.clear();
      _austIdController.clear();
      _feedbackController.clear();
      _selectedDepartment = null;
    });
    _scaleController.reset();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Content
              Expanded(
                child: _isSubmitted
                    ? _buildSuccessState()
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: SizeConfig.screenHeight * 0.025),

                      // Header
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildHeader(),
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.03),

                      // FAQ Section
                      _buildFAQSection(),

                      SizedBox(height: SizeConfig.screenHeight * 0.04),

                      // Feedback Form
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildFeedbackForm(),
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.035),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: SizeConfig.screenWidth * 0.025,
            offset: Offset(0, SizeConfig.screenHeight * 0.002),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
              decoration: BoxDecoration(
                color: kGreenMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: kGreenDark,
                size: SizeConfig.screenWidth * 0.035,
              ),
            ),
          ),
          SizedBox(width: SizeConfig.screenWidth * 0.04),
          Expanded(
            child: Text(
              'FAQ & Feedback',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.04,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
            decoration: BoxDecoration(
              color: kGreenMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
            ),
            child: Icon(
              Icons.question_answer_rounded,
              color: kGreenMain,
              size: SizeConfig.screenWidth * 0.055,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.02),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.06),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGreenMain, kGreenDark],
          ),
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.06),
          boxShadow: [
            BoxShadow(
              color: kGreenMain.withOpacity(0.3),
              blurRadius: SizeConfig.screenWidth * 0.05,
              offset: Offset(0, SizeConfig.screenHeight * 0.012),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: SizeConfig.screenWidth * 0.1,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.02),
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.06,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Text(
              'Find answers to common questions or share your valuable feedback with us',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.035,
                color: Colors.white.withOpacity(0.85),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: Colors.blue,
                  size: SizeConfig.screenWidth * 0.05,
                ),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.03),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.045,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          // FAQ Items
          ...List.generate(_faqItems.length, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, SizeConfig.screenHeight * 0.025 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.015),
                child: _FAQItem(
                  question: _faqItems[index]['question']!,
                  answer: _faqItems[index]['answer']!,
                  index: index,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.02),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.06),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: SizeConfig.screenWidth * 0.05,
              offset: Offset(0, SizeConfig.screenHeight * 0.012),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                    ),
                    child: Icon(
                      Icons.rate_review_rounded,
                      color: Colors.orange,
                      size: SizeConfig.screenWidth * 0.05,
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Your Feedback',
                        style: TextStyle(
                          fontSize: SizeConfig.screenWidth * 0.045,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Help us improve your experience',
                        style: TextStyle(
                          fontSize: SizeConfig.screenWidth * 0.03,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),

              // Progress Indicator
              _buildProgressIndicator(),

              SizedBox(height: SizeConfig.screenHeight * 0.03),

              // Step Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentStep(),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: SizeConfig.screenHeight * 0.005,
                  decoration: BoxDecoration(
                    color: isActive ? kGreenMain : Colors.grey[200],
                    borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.005),
                  ),
                ),
              ),
              if (index < 2) SizedBox(width: SizeConfig.screenWidth * 0.02),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildDepartmentStep();
      case 2:
        return _buildFeedbackStep();
      default:
        return _buildPersonalInfoStep();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Personal Information',
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.035,
            fontWeight: FontWeight.w700,
            color: kGreenMain,
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // Name Field
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            if (value.trim().length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),

        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // AUST ID Field
        _buildTextField(
          controller: _austIdController,
          label: 'AUST ID',
          hint: 'e.g., 21.01.04.123',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your AUST ID';
            }
            if (!_isValidAustId(value.trim())) {
              return 'Invalid format. Use: XX.XX.XX.XXX';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentStep() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Select Department',
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.035,
            fontWeight: FontWeight.w700,
            color: kGreenMain,
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // Department Dropdown
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
            border: Border.all(
              color: _selectedDepartment != null
                  ? kGreenMain.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: InputDecoration(
              labelText: 'Department',
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.school_outlined,
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.02,
              ),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[500],
            ),
            items: _departments.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(
                  dept,
                  style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedDepartment = value);
              HapticFeedback.selectionClick();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your department';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // Info Card
        Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blue[600],
                size: SizeConfig.screenWidth * 0.05,
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.03),
              Expanded(
                child: Text(
                  'Select the department you are currently enrolled in.',
                  style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.032,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackStep() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3: Your Feedback',
          style: TextStyle(
            fontSize: SizeConfig.screenWidth * 0.035,
            fontWeight: FontWeight.w700,
            color: kGreenMain,
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // Feedback Field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
            border: Border.all(
              color: _feedbackController.text.isNotEmpty
                  ? kGreenMain.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextFormField(
            controller: _feedbackController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Your Feedback',
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              hintText: 'Share your thoughts, suggestions, or questions...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: SizeConfig.screenWidth * 0.035,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
              counterStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: SizeConfig.screenWidth * 0.03,
              ),
            ),
            style: TextStyle(
              fontSize: SizeConfig.screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your feedback';
              }
              if (value.trim().length < 10) {
                return 'Feedback must be at least 10 characters';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: SizeConfig.screenHeight * 0.02),

        // Preview Card
        Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
          decoration: BoxDecoration(
            color: kGreenMain.withOpacity(0.05),
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
            border: Border.all(
              color: kGreenMain.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview_rounded,
                    color: kGreenMain,
                    size: SizeConfig.screenWidth * 0.045,
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.02),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.032,
                      fontWeight: FontWeight.w700,
                      color: kGreenMain,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.015),
              _buildPreviewRow('Name', _nameController.text),
              _buildPreviewRow('Department', _selectedDepartment ?? '-'),
              _buildPreviewRow('AUST ID', _austIdController.text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: SizeConfig.screenWidth * 0.22,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.03,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.03,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? kGreenMain.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: SizeConfig.screenWidth * 0.035,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey[500],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenWidth * 0.04,
            vertical: SizeConfig.screenHeight * 0.013,
          ),
        ),
        style: TextStyle(
          fontSize: SizeConfig.screenWidth * 0.035,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) => setState(() {}),
        validator: validator,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Back Button
        if (_currentStep > 0)
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _currentStep--);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.02),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.grey[700],
                      size: SizeConfig.screenWidth * 0.05,
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.02),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.035,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (_currentStep > 0) SizedBox(width: SizeConfig.screenWidth * 0.03),

        // Next/Submit Button
        Expanded(
          flex: _currentStep > 0 ? 1 : 1,
          child: GestureDetector(
            onTap: _isLoading
                ? null
                : () {
              HapticFeedback.mediumImpact();

              if (_currentStep < 2) {
                bool isValid = true;

                if (_currentStep == 0) {
                  if (_nameController.text.trim().isEmpty ||
                      _nameController.text.trim().length < 3) {
                    isValid = false;
                  }
                  if (!_isValidAustId(_austIdController.text.trim())) {
                    isValid = false;
                  }
                } else if (_currentStep == 1) {
                  if (_selectedDepartment == null) {
                    isValid = false;
                  }
                }

                if (isValid) {
                  setState(() => _currentStep++);
                } else {
                  _formKey.currentState?.validate();
                }
              } else {
                _submitFeedback();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.02),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kGreenMain, kGreenDark],
                ),
                borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: kGreenMain.withOpacity(0.3),
                    blurRadius: SizeConfig.screenWidth * 0.025,
                    offset: Offset(0, SizeConfig.screenHeight * 0.005),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    SizedBox(
                      width: SizeConfig.screenWidth * 0.05,
                      height: SizeConfig.screenWidth * 0.05,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    Text(
                      _currentStep < 2 ? 'Next' : 'Submit Feedback',
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.035,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.02),
                    Icon(
                      _currentStep < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: SizeConfig.screenWidth * 0.05,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation Container
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: SizeConfig.screenWidth * 0.3,
                  height: SizeConfig.screenWidth * 0.3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kGreenMain, kGreenDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kGreenMain.withOpacity(0.3),
                        blurRadius: SizeConfig.screenWidth * 0.075,
                        offset: Offset(0, SizeConfig.screenHeight * 0.012),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: SizeConfig.screenWidth * 0.15,
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.04),

              // Success Title
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, SizeConfig.screenHeight * 0.025 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.07,
                    fontWeight: FontWeight.w900,
                    color: kGreenDark,
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.015),

              // Success Message
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  'Your feedback has been submitted successfully. We appreciate your time and input!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.038,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.05),

              // Action Buttons
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, SizeConfig.screenHeight * 0.035 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Submit Another Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _resetForm();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.02),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kGreenMain, kGreenDark],
                          ),
                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: kGreenMain.withOpacity(0.3),
                              blurRadius: SizeConfig.screenWidth * 0.025,
                              offset: Offset(0, SizeConfig.screenHeight * 0.005),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_comment_rounded,
                              color: Colors.white,
                              size: SizeConfig.screenWidth * 0.05,
                            ),
                            SizedBox(width: SizeConfig.screenWidth * 0.02),
                            Text(
                              'Submit Another Feedback',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.015),

                    // Go Back Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.grey[700],
                              size: SizeConfig.screenWidth * 0.05,
                            ),
                            SizedBox(width: SizeConfig.screenWidth * 0.02),
                            Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// FAQ ITEM WIDGET
/// ============================================
class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final int index;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.index,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
          border: Border.all(
            color: _isExpanded
                ? kGreenMain.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            width: _isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isExpanded
                  ? kGreenMain.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _isExpanded ? SizeConfig.screenWidth * 0.038 : SizeConfig.screenWidth * 0.025,
              offset: Offset(0, SizeConfig.screenHeight * 0.005),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
          child: Column(
            children: [
              // Question Row
              Padding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                child: Row(
                  children: [
                    // Question Number
                    Container(
                      width: SizeConfig.screenWidth * 0.08,
                      height: SizeConfig.screenWidth * 0.08,
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? kGreenMain
                            : kGreenMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.025),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.035,
                            fontWeight: FontWeight.w700,
                            color: _isExpanded ? Colors.white : kGreenMain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: SizeConfig.screenWidth * 0.03),

                    // Question Text
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: SizeConfig.screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: _isExpanded
                              ? kGreenDark
                              : const Color(0xFF1F2937),
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(width: SizeConfig.screenWidth * 0.03),

                    // Expand Icon
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: _isExpanded
                              ? kGreenMain.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _isExpanded ? kGreenMain : Colors.grey[600],
                          size: SizeConfig.screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Answer Section
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    SizeConfig.screenWidth * 0.04,
                    0,
                    SizeConfig.screenWidth * 0.04,
                    SizeConfig.screenWidth * 0.04,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: kGreenMain.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                    ),
                    child: Text(
                      widget.answer,
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.032,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
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
}


