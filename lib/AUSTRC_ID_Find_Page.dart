import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

// Brand colors
const Color kBrandStart = Color(0xFF0B6B3A);
const Color kBrandEnd = Color(0xFF16A34A);
const Color kDarkGreen = Color(0xFF004D40);
const Color kLightGreen = Color(0xFF81C784);
const Color kAccentGold = Color(0xFFFFB703);

class ForgotAustrcIdPage extends StatefulWidget {
  const ForgotAustrcIdPage({Key? key}) : super(key: key);

  @override
  State<ForgotAustrcIdPage> createState() => _ForgotAustrcIdPageState();
}

class _ForgotAustrcIdPageState extends State<ForgotAustrcIdPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _formController;
  late AnimationController _shakeController;
  late AnimationController _successController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;
  late Animation<double> _shakeAnimation;

  // Form
  final _formKey = GlobalKey<FormState>();
  final _austIdController = TextEditingController();
  final _eduMailController = TextEditingController();
  final _austIdFocusNode = FocusNode();
  final _eduMailFocusNode = FocusNode();

  // States
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _foundAustrcId = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _headerSlide = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _startAnimationSequence() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    _formController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _austIdController.dispose();
    _eduMailController.dispose();
    _austIdFocusNode.dispose();
    _eduMailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyAndSubmit() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    HapticFeedback.mediumImpact();

    try {
      final austId = _austIdController.text.trim();
      final eduMail = _eduMailController.text.trim().toLowerCase();

      // Query Firebase to verify
      final membersCollection = FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_AUSTRC_ID')
          .collection('Members');

      final querySnapshot = await membersCollection.get();

      bool found = false;
      String austrcId = '';

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final storedAustId = data['AUST_ID']?.toString().trim() ?? '';
        final storedEduMail = data['Edu_Mail']?.toString().trim().toLowerCase() ?? '';

        if (storedAustId == austId && storedEduMail == eduMail) {
          found = true;
          austrcId = data['AUSTRC_ID']?.toString() ?? '';
          break;
        }
      }

      if (found) {
        // Store the request in Firebase
        await _storeRequestInFirebase(austId, eduMail);

        setState(() {
          _isSuccess = true;
          _foundAustrcId = austrcId;
        });
        _successController.forward();
        HapticFeedback.heavyImpact();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'No matching record found. Please verify your AUST ID and Edu Mail are correct.';
        });
        _triggerShake();
        HapticFeedback.vibrate();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'An error occurred. Please check your internet connection and try again.';
      });
      _triggerShake();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Store request in Firebase
  Future<void> _storeRequestInFirebase(String austId, String eduMail) async {
    try {
      await FirebaseFirestore.instance
          .collection('Find_AUSTRC_ID')
          .doc(austId)
          .set({
        'AUST_ID': austId,
        'Edu_Mail': eduMail,
        'Requested_At': FieldValue.serverTimestamp(),
        'Status': 'Pending',
      }, SetOptions(merge: true));
    } catch (e) {
      // Log error but don't fail the process
      debugPrint('Error storing request: $e');
    }
  }

  void _triggerShake() {
    _shakeController.reset();
    _shakeController.forward();
    HapticFeedback.lightImpact();
  }

  void _resetForm() {
    setState(() {
      _isSuccess = false;
      _hasError = false;
      _errorMessage = '';
      _foundAustrcId = '';
    });
    _austIdController.clear();
    _eduMailController.clear();
    _successController.reset();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(topInset),
          Expanded(
            child: Stack(
              children: [
                _AnimatedBackground(
                  waveController: _waveController,
                  particleController: _particleController,
                ),
                _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topInset) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(
            opacity: _headerFade.value.clamp(0.0, 1.0),
            child: Container(
              height: 140 + topInset,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kBrandStart.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Static pattern instead of animated
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: CustomPaint(
                        painter: _StaticHeaderPatternPainter(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _AnimatedBackButton(
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(30 * (1 - value), 0),
                                        child: Opacity(
                                          opacity: value.clamp(0.0, 1.0),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot AUSTRC ID',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      'Recover your membership ID',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StaticHeaderBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _isSuccess
          ? _SuccessView(
        key: const ValueKey('success'),
        successController: _successController,
        austrcId: _foundAustrcId,
        onReset: _resetForm,
      )
          : _FormView(
        key: const ValueKey('form'),
        formController: _formController,
        formSlide: _formSlide,
        formFade: _formFade,
        shakeController: _shakeController,
        shakeAnimation: _shakeAnimation,
        pulseController: _pulseController,
        floatingController: _floatingController,
        formKey: _formKey,
        austIdController: _austIdController,
        eduMailController: _eduMailController,
        austIdFocusNode: _austIdFocusNode,
        eduMailFocusNode: _eduMailFocusNode,
        isLoading: _isLoading,
        hasError: _hasError,
        errorMessage: _errorMessage,
        onSubmit: _verifyAndSubmit,
      ),
    );
  }
}

// ============================================
// STATIC HEADER PATTERN PAINTER (No Animation - No Flicker)
// ============================================
class _StaticHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Static circles
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.1 + i * 0.18);
      final y = size.height * 0.35;
      final radius = 20.0 + i * 8;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// STATIC HEADER BADGE (No Animation - No Flicker)
// ============================================
class _StaticHeaderBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.help_outline_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

// ============================================
// FORM VIEW
// ============================================
class _FormView extends StatelessWidget {
  final AnimationController formController;
  final Animation<double> formSlide;
  final Animation<double> formFade;
  final AnimationController shakeController;
  final Animation<double> shakeAnimation;
  final AnimationController pulseController;
  final AnimationController floatingController;
  final GlobalKey<FormState> formKey;
  final TextEditingController austIdController;
  final TextEditingController eduMailController;
  final FocusNode austIdFocusNode;
  final FocusNode eduMailFocusNode;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final VoidCallback onSubmit;

  const _FormView({
    Key? key,
    required this.formController,
    required this.formSlide,
    required this.formFade,
    required this.shakeController,
    required this.shakeAnimation,
    required this.pulseController,
    required this.floatingController,
    required this.formKey,
    required this.austIdController,
    required this.eduMailController,
    required this.austIdFocusNode,
    required this.eduMailFocusNode,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: formController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, formSlide.value),
            child: Opacity(
              opacity: formFade.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Illustration
            _FormIllustration(floatingController: floatingController),

            const SizedBox(height: 32),

            // Info Card
            _InfoCard(),

            const SizedBox(height: 24),

            // Form Card
            AnimatedBuilder(
              animation: shakeController,
              builder: (context, child) {
                final shakeOffset = math.sin(shakeAnimation.value * math.pi * 4) * 10;
                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: child,
                );
              },
              child: _FormCard(
                formKey: formKey,
                austIdController: austIdController,
                eduMailController: eduMailController,
                austIdFocusNode: austIdFocusNode,
                eduMailFocusNode: eduMailFocusNode,
                hasError: hasError,
                errorMessage: errorMessage,
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            _SubmitButton(
              pulseController: pulseController,
              isLoading: isLoading,
              onSubmit: onSubmit,
            ),

            const SizedBox(height: 16),

            // Helper Text
            _HelperText(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FORM ILLUSTRATION
// ============================================
class _FormIllustration extends StatelessWidget {
  final AnimationController floatingController;

  const _FormIllustration({required this.floatingController});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value.clamp(0.0, 1.2),
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -10 * floatingController.value),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        kBrandStart.withOpacity(0.1),
                        kBrandEnd.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: kBrandStart.withOpacity(0.2),
                      width: 3,
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        kBrandStart.withOpacity(0.15),
                        kBrandEnd.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                // Center circle with icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [kBrandStart, kBrandEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandStart.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                // Floating elements
                ..._buildFloatingElements(floatingController.value),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingElements(double animValue) {
    final elements = [
      _FloatingElement(
        angle: 0,
        radius: 90,
        icon: Icons.badge_rounded,
        color: kAccentGold,
        animValue: animValue,
      ),
      _FloatingElement(
        angle: math.pi * 0.66,
        radius: 90,
        icon: Icons.email_rounded,
        color: kBrandEnd,
        animValue: animValue,
      ),
      _FloatingElement(
        angle: math.pi * 1.33,
        radius: 90,
        icon: Icons.verified_user_rounded,
        color: kBrandStart,
        animValue: animValue,
      ),
    ];

    return elements.map((element) {
      final angle = element.angle + (animValue * math.pi * 0.3);
      final x = math.cos(angle) * element.radius;
      final y = math.sin(angle) * element.radius;

      return Positioned(
        left: 80 + x - 16,
        top: 80 + y - 16,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: element.color.withOpacity(0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(element.icon, color: element.color, size: 18),
        ),
      );
    }).toList();
  }
}

class _FloatingElement {
  final double angle;
  final double radius;
  final IconData icon;
  final Color color;
  final double animValue;

  _FloatingElement({
    required this.angle,
    required this.radius,
    required this.icon,
    required this.color,
    required this.animValue,
  });
}

// ============================================
// INFO CARD
// ============================================
class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kBrandStart.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your details to request your AUSTRC ID',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _InfoStep(
              number: '1',
              title: 'Enter Your Details',
              description: 'Provide your AUST ID and registered Edu Mail',
              icon: Icons.edit_note_rounded,
              color: kBrandStart,
            ),
            const SizedBox(height: 12),
            _InfoStep(
              number: '2',
              title: 'Verification',
              description: 'We\'ll verify your information in our database',
              icon: Icons.verified_rounded,
              color: kBrandEnd,
            ),
            const SizedBox(height: 12),
            _InfoStep(
              number: '3',
              title: 'Receive ID via Email',
              description: 'Admin will send your AUSTRC ID to your Edu Mail',
              icon: Icons.mark_email_read_rounded,
              color: kAccentGold,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InfoStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4332),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Icon(icon, color: color, size: 22),
      ],
    );
  }
}

// ============================================
// FORM CARD
// ============================================
class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController austIdController;
  final TextEditingController eduMailController;
  final FocusNode austIdFocusNode;
  final FocusNode eduMailFocusNode;
  final bool hasError;
  final String errorMessage;

  const _FormCard({
    required this.formKey,
    required this.austIdController,
    required this.eduMailController,
    required this.austIdFocusNode,
    required this.eduMailFocusNode,
    required this.hasError,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: hasError
              ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: hasError
                  ? Colors.red.withOpacity(0.15)
                  : kBrandStart.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBrandStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: kBrandStart,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Your Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AUST ID Field
              _CustomTextField(
                controller: austIdController,
                focusNode: austIdFocusNode,
                label: 'AUST ID',
                hint: 'Enter your AUST ID',
                icon: Icons.badge_rounded,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your AUST ID';
                  }
                  return null;
                },
                onSubmitted: (_) {
                  eduMailFocusNode.requestFocus();
                },
              ),
              const SizedBox(height: 20),

              // Edu Mail Field
              _CustomTextField(
                controller: eduMailController,
                focusNode: eduMailFocusNode,
                label: 'Edu Mail',
                hint: 'example@aust.edu',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Edu Mail';
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@aust\.edu$',
                    caseSensitive: false,
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid @aust.edu email';
                  }
                  return null;
                },
              ),

              // Error Message
              if (hasError) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

// ============================================
// CUSTOM TEXT FIELD
// ============================================
class _CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final void Function(String)? onSubmitted;

  const _CustomTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.validator,
    this.onSubmitted,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _isFocused ? kBrandStart : const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? kBrandStart.withOpacity(0.15)
                    : Colors.transparent,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onFieldSubmitted: widget.onSubmitted,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B4332),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isFocused
                        ? kBrandStart.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isFocused ? kBrandStart : Colors.grey[500],
                    size: 20,
                  ),
                ),
              ),
              filled: true,
              fillColor: _isFocused
                  ? kBrandStart.withOpacity(0.03)
                  : Colors.grey.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: kBrandStart,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.red.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// SUBMIT BUTTON
// ============================================
class _SubmitButton extends StatefulWidget {
  final AnimationController pulseController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.pulseController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: AnimatedBuilder(
        animation: widget.pulseController,
        builder: (context, child) {
          return GestureDetector(
            onTapDown: widget.isLoading
                ? null
                : (_) => setState(() => _isPressed = true),
            onTapUp: widget.isLoading
                ? null
                : (_) {
              setState(() => _isPressed = false);
              widget.onSubmit();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Verifying...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// HELPER TEXT
// ============================================
class _HelperText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(opacity: value.clamp(0.0, 1.0), child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.amber[700],
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Make sure to use the same email address you registered with during membership.',
                style: TextStyle(
                  color: Colors.amber[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SUCCESS VIEW
// ============================================
class _SuccessView extends StatelessWidget {
  final AnimationController successController;
  final String austrcId;
  final VoidCallback onReset;

  const _SuccessView({
    Key? key,
    required this.successController,
    required this.austrcId,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Success Animation
          _SuccessAnimation(controller: successController),

          const SizedBox(height: 40),

          // Success Message
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Column(
              children: [
                const Text(
                  'Request Submitted!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your request has been verified and submitted successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Info Card
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kBrandStart.withOpacity(0.1),
                    kBrandEnd.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: kBrandStart.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kBrandStart.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: kBrandStart,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'What happens next?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _NextStep(
                    number: '1',
                    text: 'Your request has been recorded',
                    icon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(height: 12),
                  const _NextStep(
                    number: '2',
                    text: 'Admin will review your request',
                    icon: Icons.admin_panel_settings_rounded,
                  ),
                  const SizedBox(height: 12),
                  const _NextStep(
                    number: '3',
                    text: 'Your AUSTRC ID will be sent to your Edu Mail',
                    icon: Icons.email_rounded,
                  ),
                  const SizedBox(height: 12),
                  const _NextStep(
                    number: '4',
                    text: 'Please check your inbox within 24-48 hours',
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Back to Home Button
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Column(
              children: [
                _ActionButton(
                  label: 'Submit Another Request',
                  icon: Icons.refresh_rounded,
                  isPrimary: true,
                  onTap: onReset,
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Go Back',
                  icon: Icons.arrow_back_rounded,
                  isPrimary: false,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String text;
  final IconData icon;

  const _NextStep({
    required this.number,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kBrandStart, kBrandEnd],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(icon, color: kBrandStart, size: 20),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: widget.isPrimary
              ? const LinearGradient(
            colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
          )
              : null,
          color: widget.isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: widget.isPrimary
              ? null
              : Border.all(color: kBrandStart.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.isPrimary
                  ? kBrandStart.withOpacity(_isPressed ? 0.4 : 0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isPressed ? 20 : 15,
              offset: Offset(0, _isPressed ? 8 : 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.isPrimary ? Colors.white : kBrandStart,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.isPrimary ? Colors.white : kBrandStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SUCCESS ANIMATION
// ============================================
class _SuccessAnimation extends StatelessWidget {
  final AnimationController controller;

  const _SuccessAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value.clamp(0.0, 1.2),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 180 * value,
                height: 180 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kBrandStart.withOpacity(0.2 / value),
                    width: 3,
                  ),
                ),
              );
            },
          ),
          // Middle ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  kBrandStart.withOpacity(0.15),
                  kBrandEnd.withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Center circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kBrandStart, kBrandEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kBrandStart.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),
          // Confetti particles
          ..._buildConfetti(),
        ],
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final colors = [kBrandStart, kBrandEnd, kAccentGold, kLightGreen];
    return List.generate(12, (index) {
      final angle = (index / 12) * 2 * math.pi;
      final radius = 100.0 + (index % 3) * 20;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      return Positioned(
        left: 90 + x - 6,
        top: 90 + y - 6,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + (index * 50)),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: index % 2 == 0 ? null : BorderRadius.circular(3),
            ),
          ),
        ),
      );
    });
  }
}

// ============================================
// ANIMATED BACKGROUND
// ============================================
class _AnimatedBackground extends StatelessWidget {
  final AnimationController waveController;
  final AnimationController particleController;

  const _AnimatedBackground({
    required this.waveController,
    required this.particleController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE8F5E9),
                Color(0xFFF1F8E9),
                Color(0xFFFAFAFA),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: _WaveBackgroundPainter(animation: waveController.value),
              size: Size.infinite,
            );
          },
        ),
        AnimatedBuilder(
          animation: particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(animation: particleController.value),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

// ============================================
// WAVE BACKGROUND PAINTER
// ============================================
class _WaveBackgroundPainter extends CustomPainter {
  final double animation;

  _WaveBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          kBrandStart.withOpacity(0.03),
          kBrandEnd.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (var i = 0; i <= size.width; i++) {
      final y = size.height * 0.7 +
          math.sin((i / size.width * 4 * math.pi) + (animation * 2 * math.pi)) *
              30 +
          math.sin((i / size.width * 2 * math.pi) + (animation * math.pi)) * 20;
      path.lineTo(i.toDouble(), y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

// ============================================
// PARTICLE PAINTER
// ============================================
class _ParticlePainter extends CustomPainter {
  final double animation;

  _ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      _Particle(0.1, 0.2, 4, kBrandStart.withOpacity(0.2)),
      _Particle(0.3, 0.4, 6, kBrandEnd.withOpacity(0.15)),
      _Particle(0.5, 0.15, 3, kLightGreen.withOpacity(0.2)),
      _Particle(0.7, 0.35, 5, kBrandStart.withOpacity(0.1)),
      _Particle(0.85, 0.25, 4, kBrandEnd.withOpacity(0.18)),
      _Particle(0.2, 0.6, 3, kLightGreen.withOpacity(0.15)),
      _Particle(0.6, 0.55, 5, kBrandStart.withOpacity(0.12)),
      _Particle(0.9, 0.5, 4, kBrandEnd.withOpacity(0.1)),
    ];

    for (final p in particles) {
      final offsetY = math.sin((animation + p.x) * 2 * math.pi) * 20;
      final x = size.width * p.x;
      final y = size.height * p.y + offsetY;
      paint.color = p.color;
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final Color color;

  _Particle(this.x, this.y, this.radius, this.color);
}

// ============================================
// ANIMATED BACK BUTTON
// ============================================
class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.onTap});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}