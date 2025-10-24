import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      // Load available semesters by listing all documents in New_Member_Recruitment collection
      final semesterSnapshot = await FirebaseFirestore.instance
          .collection('New_Member_Recruitment')
          .get();

      List<String> semesters = [];
      for (var doc in semesterSnapshot.docs) {
        // Exclude the Payment Number document from the semester list
        if (doc.id != 'Form ON_OFF and Payment Number') {
          semesters.add(doc.id);
        }
      }

      // Sort semesters if needed (optional)
      semesters.sort();

      setState(() {
        _availableSemesters = semesters.isNotEmpty ? semesters : [];
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Form Currently Closed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _accessMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 16,
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

    try {
      // Create document reference using Edu-Mail as collection and Name as document
      final docRef = FirebaseFirestore.instance
          .collection('New_Member_Recruitment')
          .doc(_selectedCurrentSemester!)
          .collection(_eduMailController.text.trim())
          .doc(_nameController.text.trim());

      await docRef.set({
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
        'Submitted_At': FieldValue.serverTimestamp(),
      });

      setState(() => _isSubmitting = false);

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to the club! Your application has been submitted successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Curved App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Join Our Club',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
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
                      right: -30,
                      top: 50,
                      child: Icon(
                        Icons.group_add_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 50,
                      child: Text(
                        'New Member Registration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 17,
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
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                ),
              ),
            )
                : !_isFormAccessible
                ? const SizedBox.shrink()
                : FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionTitle('Personal Information', Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        delay: 100,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _departmentController,
                        label: 'Department',
                        icon: Icons.school,
                        delay: 150,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Department is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        delay: 200,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Phone number is required' : null,
                      ),

                      // Academic Information Section
                      const SizedBox(height: 32),
                      _buildSectionTitle('Academic Information', Icons.menu_book),
                      const SizedBox(height: 16),

                      // Semester Selection
                      _buildAnimatedCard(
                        delay: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Your Semester',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _semesterOptions.map((semester) {
                                final isSelected = _selectedSemester == semester;
                                return ChoiceChip(
                                  label: Text(semester),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSemester = selected ? semester : null;
                                    });
                                  },
                                  selectedColor: const Color(0xFF2E7D32),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  backgroundColor: Colors.grey[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Current Semester Dropdown
                      _buildAnimatedCard(
                        delay: 300,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCurrentSemester,
                          decoration: InputDecoration(
                            labelText: 'Current Semester',
                            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _availableSemesters.map((semester) {
                            return DropdownMenuItem(
                              value: semester,
                              child: Text(semester),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCurrentSemester = value);
                          },
                          validator: (value) =>
                          value == null ? 'Please select current semester' : null,
                        ),
                      ),

                      // Contact Information Section
                      const SizedBox(height: 32),
                      _buildSectionTitle('Contact Information', Icons.email_outlined),
                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _personalEmailController,
                        label: 'Personal Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        delay: 350,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Email is required';
                          if (!value!.contains('@')) return 'Invalid email format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _eduMailController,
                        label: 'Educational Email',
                        icon: Icons.school,
                        keyboardType: TextInputType.emailAddress,
                        delay: 400,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Educational email is required';
                          if (!value!.contains('@')) return 'Invalid email format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _imageLinkController,
                        label: 'Image Drive Link',
                        icon: Icons.link,
                        delay: 450,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Image link is required' : null,
                      ),

                      // Payment Section
                      const SizedBox(height: 32),
                      _buildSectionTitle('Payment Information', Icons.payment),
                      const SizedBox(height: 16),

                      // Must Send Money Notice
                      _buildAnimatedCard(
                        delay: 500,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF6B6B).withOpacity(0.1),
                                const Color(0xFFEE5A6F).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B6B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'MUST SEND MONEY\nBefore submitting the form',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6B6B),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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
                      const SizedBox(height: 12),
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

                      const SizedBox(height: 16),

                      // Payment Method Selection
                      _buildAnimatedCard(
                        delay: 650,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method Used',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPaymentOption('Bkash', Colors.pink),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildPaymentOption('Nagad', Colors.orange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: _transactionIdController,
                        label: 'Transaction ID',
                        icon: Icons.receipt_long,
                        delay: 700,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Transaction ID is required' : null,
                      ),

                      // Submit Button
                      const SizedBox(height: 32),
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
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Application',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
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
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildPaymentNumberCard(
      String method, String number, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        number,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
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
            ),
            const SizedBox(width: 8),
            Text(
              method,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}