// admin_login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'size_config.dart';

// ✅ Import the page you want to open after successful login
// Make sure this file exports a widget named AdminDashboardPage
import 'admin_homepage.dart'; // or: import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Animations
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _backgroundController;
  late AnimationController _successController;
  late AnimationController _errorController;
  late AnimationController _glowController;

  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  // UI state
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(_formAnimation);

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _backgroundController.dispose();
    _successController.dispose();
    _errorController.dispose();
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1) Verify email is in Admin list (Firestore)
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('Admin Infos')
          .get();

      if (!adminDoc.exists) {
        _showErrorAnimation('Admin configuration not found');
        return;
      }

      final adminEmailField = adminDoc.data()?['Admin_Email'];
      bool isAuthorized = false;

      if (adminEmailField is String) {
        isAuthorized = adminEmailField.toLowerCase() == email.toLowerCase();
      } else if (adminEmailField is List) {
        isAuthorized = adminEmailField.any(
          (e) => e.toString().toLowerCase() == email.toLowerCase(),
        );
      }

      if (!isAuthorized) {
        _showErrorAnimation('Unauthorized access. You are not an admin.');
        return;
      }

      // 2) Firebase Auth sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save admin session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdminLoggedIn', true);
      await prefs.setString('adminEmail', email);

      // Success animation, then navigate
      _showSuccessAnimation('Login Successful!');
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboardPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      }
      _showErrorAnimation(message);
    } catch (e) {
      _showErrorAnimation('An error occurred: ${e.toString()}');
    }
  }

  void _showSuccessAnimation(String _msg) {
    setState(() {
      _isLoading = false;
      _showSuccess = true;
      _showError = false;
    });
    _successController.forward(from: 0);
  }

  void _showErrorAnimation(String message) {
    setState(() {
      _isLoading = false;
      _showError = true;
      _showSuccess = false;
      _errorMessage = message;
    });
    _errorController.forward(from: 0);

    // triple shake
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _errorController.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF0D3B1F),
                        const Color(0xFF1B5E20),
                        (math.sin(_backgroundController.value * 2 * math.pi) +
                                1) /
                            2,
                      )!,
                      const Color(0xFF1B5E20),
                      Color.lerp(
                        const Color(0xFF2E7D32),
                        const Color(0xFF43A047),
                        (math.cos(_backgroundController.value * 2 * math.pi) +
                                1) /
                            2,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(20, (index) {
            return AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                final offset =
                    (_backgroundController.value + index * 0.1) % 1.0;
                return Positioned(
                  left: (index * SizeConfig.screenWidth * 0.125) %
                      SizeConfig.screenWidth,
                  top: SizeConfig.screenHeight * offset,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.circle,
                        size: SizeConfig.screenWidth * 0.025,
                        color: Colors.white),
                  ),
                );
              },
            );
          }),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.06),
              child: Column(
                children: [
                  SizedBox(height: SizeConfig.screenHeight * 0.06),

                  // Animated logo with glow
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: SizeConfig.screenWidth * 0.38,
                          height: SizeConfig.screenWidth * 0.38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43A047).withOpacity(
                                    0.3 + (_glowController.value * 0.4)),
                                blurRadius: SizeConfig.screenWidth * 0.08 +
                                    (_glowController.value *
                                        SizeConfig.screenWidth *
                                        0.04),
                                spreadRadius: SizeConfig.screenWidth * 0.02 +
                                    (_glowController.value *
                                        SizeConfig.screenWidth *
                                        0.01),
                              ),
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(
                                    0.4 + (_glowController.value * 0.3)),
                                blurRadius: SizeConfig.screenWidth * 0.06 +
                                    (_glowController.value *
                                        SizeConfig.screenWidth *
                                        0.03),
                                spreadRadius: SizeConfig.screenWidth * 0.01 +
                                    (_glowController.value *
                                        SizeConfig.screenWidth *
                                        0.005),
                              ),
                              BoxShadow(
                                color: const Color(0xFF1B5E20).withOpacity(
                                    0.5 + (_glowController.value * 0.2)),
                                blurRadius: SizeConfig.screenWidth * 0.04 +
                                    (_glowController.value *
                                        SizeConfig.screenWidth *
                                        0.02),
                                spreadRadius: SizeConfig.screenWidth * 0.004,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF43A047).withOpacity(
                                    0.3 + (_glowController.value * 0.4)),
                                width: SizeConfig.screenWidth * 0.006,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logo2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: SizeConfig.screenHeight * 0.04),

                  // Title
                  FadeTransition(
                    opacity: _formAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Admin Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.screenWidth * 0.065,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.01),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.screenWidth * 0.04,
                            vertical: SizeConfig.screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                                SizeConfig.screenWidth * 0.05),
                          ),
                          child: Text(
                            'AUSTRC Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.screenWidth * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: SizeConfig.screenHeight * 0.05),

                  // Login form
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _formAnimation,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.055),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              SizeConfig.screenWidth * 0.06),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: SizeConfig.screenWidth * 0.06,
                              offset:
                                  Offset(0, SizeConfig.screenHeight * 0.015),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email
                              AnimatedBuilder(
                                animation: _errorController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _showError
                                          ? math.sin(_errorController.value *
                                                  math.pi *
                                                  6) *
                                              10
                                          : 0,
                                      0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.038),
                                  decoration: InputDecoration(
                                    labelText: 'Admin Email',
                                    labelStyle: TextStyle(
                                        fontSize:
                                            SizeConfig.screenWidth * 0.033),
                                    prefixIcon: Icon(Icons.admin_panel_settings,
                                        color: Color(0xFF1B5E20),
                                        size: SizeConfig.screenWidth * 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                      borderSide: BorderSide(
                                          color: Color(0xFF1B5E20), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.screenWidth * 0.035,
                                      vertical: SizeConfig.screenHeight * 0.015,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return 'Email is required';
                                    if (!(value!.contains('@') &&
                                        value.contains('.'))) {
                                      return 'Invalid email format';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(height: SizeConfig.screenHeight * 0.025),

                              // Password
                              AnimatedBuilder(
                                animation: _errorController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _showError
                                          ? math.sin(_errorController.value *
                                                  math.pi *
                                                  6) *
                                              10
                                          : 0,
                                      0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.038),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                        fontSize:
                                            SizeConfig.screenWidth * 0.033),
                                    prefixIcon: Icon(Icons.lock,
                                        color: Color(0xFF1B5E20),
                                        size: SizeConfig.screenWidth * 0.05),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                        size: SizeConfig.screenWidth * 0.05,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                      borderSide: BorderSide(
                                          color: Color(0xFF1B5E20), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.screenWidth * 0.035,
                                      vertical: SizeConfig.screenHeight * 0.015,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Password is required';
                                    }
                                    if (value!.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(height: SizeConfig.screenHeight * 0.028),

                              // Submit
                              SizedBox(
                                width: double.infinity,
                                height: SizeConfig.screenHeight * 0.058,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.screenWidth * 0.035),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height:
                                              SizeConfig.screenWidth * 0.055,
                                          width: SizeConfig.screenWidth * 0.055,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth:
                                                SizeConfig.screenWidth * 0.005,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login,
                                                color: Colors.white,
                                                size: SizeConfig.screenWidth *
                                                    0.05),
                                            SizedBox(
                                                width: SizeConfig.screenWidth *
                                                    0.02),
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize:
                                                    SizeConfig.screenWidth *
                                                        0.042,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              // Error message
                              if (_showError) ...[
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.025),
                                AnimatedBuilder(
                                  animation: _errorController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _errorController,
                                      child: Container(
                                        padding: EdgeInsets.all(
                                            SizeConfig.screenWidth * 0.03),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.screenWidth * 0.025),
                                          border: Border.all(
                                              color: Colors.red, width: 1.5),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.red,
                                                size: SizeConfig.screenWidth *
                                                    0.05),
                                            SizedBox(
                                                width: SizeConfig.screenWidth *
                                                    0.02),
                                            Expanded(
                                              child: Text(
                                                _errorMessage,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize:
                                                      SizeConfig.screenWidth *
                                                          0.032,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: SizeConfig.screenHeight * 0.035),

                  // Footer
                  FadeTransition(
                    opacity: _formAnimation,
                    child: Text(
                      '© 2025 AUSTRC. All rights reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: SizeConfig.screenWidth * 0.03,
                      ),
                    ),
                  ),

                  SizedBox(height: SizeConfig.screenHeight * 0.04),
                ],
              ),
            ),
          ),

          // Success overlay
          if (_showSuccess)
            AnimatedBuilder(
              animation: _successController,
              builder: (context, child) {
                return Opacity(
                  opacity: _successController.value,
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.7 * _successController.value),
                    child: Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _successController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.all(SizeConfig.screenWidth * 0.08),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                SizeConfig.screenWidth * 0.06),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: SizeConfig.screenWidth * 0.06,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: SizeConfig.screenWidth * 0.18,
                                height: SizeConfig.screenWidth * 0.18,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1B5E20),
                                      Color(0xFF43A047)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_rounded,
                                    size: SizeConfig.screenWidth * 0.11,
                                    color: Colors.white),
                              ),
                              SizedBox(height: SizeConfig.screenHeight * 0.025),
                              Text(
                                'Login Successful!',
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.048,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              SizedBox(height: SizeConfig.screenHeight * 0.008),
                              Text(
                                'Welcome back, Admin',
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.032,
                                  color: Colors.grey[600],
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
        ],
      ),
    );
  }
}
