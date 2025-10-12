import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NEW: import the detail page
import 'executive_panel_page.dart';

class GoverningPanelPage extends StatefulWidget {
  const GoverningPanelPage({Key? key}) : super(key: key);

  @override
  State<GoverningPanelPage> createState() => _GoverningPanelPageState();
}

class _GoverningPanelPageState extends State<GoverningPanelPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _buttonController;
  late Animation<double> _headerFade;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonGlow;

  bool _showSemesters = false;

  // Brand colors
  static const Color brandStart = Color(0xFF0B6B3A);
  static const Color brandEnd = Color(0xFF16A34A);
  static const Color darkGreen = Color(0xFF004D40);

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _buttonScale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _buttonGlow = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _headerController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _revealSemesters() {
    setState(() {
      _showSemesters = true;
    });
  }

  // ------------------ Added helpers for sorting ------------------
  int? _extractYear(String label) {
    final m = RegExp(r'(\d{4})').firstMatch(label);
    return m != null ? int.parse(m.group(1)!) : null;
  }

  int _seasonPriority(String label) {
    final l = label.toLowerCase();
    if (l.contains('fall')) return 2;   // Fall before Spring
    if (l.contains('spring')) return 1;
    return 0;                           // Unknown seasons go last within year
  }
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFFE8F5E9);
    const bgGradientEnd = Color(0xFFF1F8E9);
    final double topInset = MediaQuery.of(context).padding.top;

    final semestersQuery = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Governing_Panel')
        .collection('Semesters');

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
              SizedBox(
                height: 120 + topInset,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: brandStart.withOpacity(0.30),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom: -1,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [brandStart, brandEnd],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding:
                            EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
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
                                    const Expanded(
                                      child: Text(
                                        'Governing Panel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 48),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _showSemesters
                                      ? 'Select a semester to view details'
                                      : 'Welcome to the panel management',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: semestersQuery.snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            // Not const: CircularProgressIndicator isn’t const
                            // (keep the list non-const to avoid issues)
                          ],
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.redAccent),
                            SizedBox(height: 16),
                            Text(
                              'Error loading semesters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snap.connectionState == ConnectionState.waiting) {
                      // (safety: though already handled above)
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 20),
                            Text(
                              'No semesters yet',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add documents under\nAll_Data/Governing_Panel/Semesters',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ------------------ Modified sorting ------------------
                    // Sort by year desc, then season (Fall before Spring)
                    final sortedDocs = [...docs];
                    sortedDocs.sort((a, b) {
                      final ay = _extractYear(a.id) ?? -1;
                      final by = _extractYear(b.id) ?? -1;

                      if (ay != by) return by.compareTo(ay); // year desc

                      final sa = _seasonPriority(a.id);
                      final sb = _seasonPriority(b.id);
                      return sb.compareTo(sa); // Fall(2) > Spring(1) > others
                    });
                    // ------------------------------------------------------

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
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
                      child: _showSemesters
                          ? _buildSemestersList(sortedDocs)
                          : _buildInitialButton(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative illustration
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -10 * _buttonController.value),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                brandStart.withOpacity(0.2),
                                brandEnd.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  brandStart.withOpacity(0.3),
                                  brandEnd.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32), // a bit smaller to help on short screens

                  Text(
                    'Ready to Explore?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'View semester information and panel details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Animated button
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _buttonScale.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: brandEnd.withOpacity(_buttonGlow.value),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _revealSemesters,
                              borderRadius: BorderRadius.circular(20),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [brandStart, brandEnd],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.touch_app_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        'Select the Semester for Panel Information',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16), // bottom breathing room
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildSemestersList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedDocs,
      ) {
    return SingleChildScrollView(
      key: const ValueKey('list'),
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showSemesters = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(12),
                      //   border: Border.all(
                      //     color: brandStart.withOpacity(0.3),
                      //     width: 1.5,
                      //   ),
                      // ),
                      // child: Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     const Icon(
                      //       Icons.arrow_back_rounded,
                      //       color: brandStart,
                      //       size: 20,
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Text(
                      //       'Back',
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w600,
                      //         color: brandStart,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ),
              ),
            ),

            // Semester button list
            ...List.generate(sortedDocs.length, (index) {
              final doc = sortedDocs[index];
              final label = doc.id;

              return _SemesterButton(
                label: label,
                index: index,
                onTap: () {
                  // CHANGED: open the semester's Executive Panel page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExecutivePanelPage(semesterId: label),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---- Semester Button (single, correct definition) ----
class _SemesterButton extends StatefulWidget {
  final String label;
  final int index;
  final VoidCallback onTap;

  const _SemesterButton({
    required this.label,
    required this.index,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_SemesterButton> createState() => _SemesterButtonState();
}

class _SemesterButtonState extends State<_SemesterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFF0B6B3A), Color(0xFF16A34A)],
      // const [Color(0xFF0D47A1), Color(0xFF42A5F5)],
      // const [Color(0xFF4A148C), Color(0xFF9C27B0)],
      // const [Color(0xFFE65100), Color(0xFFFF9800)],
      // const [Color(0xFFB71C1C), Color(0xFFEF5350)],
       const [Color(0xFF0BAB64), Color(0xFF3BB78F)],
    ];
    final colorPair = gradients[widget.index % gradients.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (widget.index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colorPair,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorPair[1].withOpacity(_isPressed ? 0.5 : 0.3),
                      blurRadius: _isPressed ? 20 : 12,
                      spreadRadius: _isPressed ? 2 : 0,
                      offset: Offset(0, _isPressed ? 8 : 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to view details',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
