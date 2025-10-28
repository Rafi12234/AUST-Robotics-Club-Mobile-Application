import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'admin_homepage.dart';

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

  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _backgroundController;
  late AnimationController _successController;
  late AnimationController _errorController;

  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Logo Animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Form Animation
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

    // Background Animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Success Animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Error Animation
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _backgroundController.dispose();
    _successController.dispose();
    _errorController.dispose();
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

      // Step 1: Check if email is in Admin list
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('Admin Infos')
          .get();

      if (!adminDoc.exists) {
        _showErrorAnimation('Admin configuration not found');
        return;
      }

      final adminEmail = adminDoc.data()?['Admin_Email'];

      // Check if Admin_Email is a string or array
      bool isAuthorized = false;
      if (adminEmail is String) {
        isAuthorized = adminEmail.toLowerCase() == email.toLowerCase();
      } else if (adminEmail is List) {
        isAuthorized = adminEmail.any((e) =>
        e.toString().toLowerCase() == email.toLowerCase()
        );
      }

      if (!isAuthorized) {
        _showErrorAnimation('Unauthorized access. You are not an admin.');
        return;
      }

      // Step 2: Authenticate with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Success!
      _showSuccessAnimation('Login Successful!');

      // Navigate to admin panel after animation
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {

         Navigator.pushReplacement(
          context,
           MaterialPageRoute(builder: (context) => AdminHomePage()),
         );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful! Navigate to Admin Panel'),
            backgroundColor: Colors.green,
          ),
        );
      }
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

  void _showSuccessAnimation(String message) {
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

    // Shake animation
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _errorController.forward(from: 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
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
                        (math.sin(_backgroundController.value * 2 * math.pi) + 1) / 2,
                      )!,
                      const Color(0xFF1B5E20),
                      Color.lerp(
                        const Color(0xFF2E7D32),
                        const Color(0xFF43A047),
                        (math.cos(_backgroundController.value * 2 * math.pi) + 1) / 2,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating Particles
          ...List.generate(20, (index) {
            return AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                final offset = (_backgroundController.value + index * 0.1) % 1.0;
                return Positioned(
                  left: (index * 50.0) % MediaQuery.of(context).size.width,
                  top: MediaQuery.of(context).size.height * offset,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.circle,
                      size: 10 + (index % 3) * 5,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          }),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Animated Logo
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/logo2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  FadeTransition(
                    opacity: _formAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Admin Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'AUSTRC Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Login Form
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _formAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email Field
                              AnimatedBuilder(
                                animation: _errorController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _showError
                                          ? math.sin(_errorController.value * math.pi * 6) * 10
                                          : 0,
                                      0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Admin Email',
                                    prefixIcon: const Icon(
                                      Icons.admin_panel_settings,
                                      color: Color(0xFF1B5E20),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1B5E20),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Email is required';
                                    }
                                    if (!value!.contains('@')) {
                                      return 'Invalid email format';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              AnimatedBuilder(
                                animation: _errorController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _showError
                                          ? math.sin(_errorController.value * math.pi * 6) * 10
                                          : 0,
                                      0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Color(0xFF1B5E20),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1B5E20),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
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

                              const SizedBox(height: 30),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isLoading
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
                                      Icon(Icons.login, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Login',
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

                              // Error Message
                              if (_showError) ...[
                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _errorController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _errorController,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _errorMessage,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13,
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

                  const SizedBox(height: 30),

                  // Footer
                  FadeTransition(
                    opacity: _formAnimation,
                    child: Text(
                      '© 2025 AUSTRC. All rights reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Success Overlay
          if (_showSuccess)
            AnimatedBuilder(
              animation: _successController,
              builder: (context, child) {
                return Opacity(
                  opacity: _successController.value,
                  child: Container(
                    color: Colors.black.withOpacity(0.7 * _successController.value),
                    child: Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _successController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1B5E20),
                                      Color(0xFF43A047),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Login Successful!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Welcome back, Admin',
                                style: TextStyle(
                                  fontSize: 14,
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