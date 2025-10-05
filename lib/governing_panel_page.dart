import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isExpanded = false;
  String? _selectedSemester;

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
                            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios_new,
                                          color: Colors.white),
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
                            CircularProgressIndicator(color: darkGreen, strokeWidth: 3),
                            SizedBox(height: 16),
                            Text('Loading semesters...', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                            SizedBox(height: 16),
                            Text('Error loading semesters',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
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
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Sort by newest first (reversed)
                    final sortedDocs = docs.reversed.toList();

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
    return Center(
      key: const ValueKey('button'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                        color: brandStart,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            Text(
              'Ready to Explore?',
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
            const SizedBox(height: 40),

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
          ],
        ),
      ),
    );
  }

  Widget _buildSemestersList(List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedDocs) {
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
                        _isExpanded = false;
                        _selectedSemester = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: brandStart.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            color: brandStart,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: brandStart,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Semester dropdown list
            ...List.generate(sortedDocs.length, (index) {
              final doc = sortedDocs[index];
              final label = doc.id;
              final isSelected = _selectedSemester == label;
              final isExpanded = _isExpanded && isSelected;

              return _SemesterDropdownCard(
                label: label,
                index: index,
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _isExpanded = !_isExpanded;
                    } else {
                      _selectedSemester = label;
                      _isExpanded = true;
                    }
                  });
                },
                onViewDetails: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening $label...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: brandStart,
                      duration: const Duration(seconds: 2),
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

// Semester Dropdown Card
class _SemesterDropdownCard extends StatefulWidget {
  final String label;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;

  const _SemesterDropdownCard({
    required this.label,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    required this.onViewDetails,
    Key? key,
  }) : super(key: key);

  @override
  State<_SemesterDropdownCard> createState() => _SemesterDropdownCardState();
}

class _SemesterDropdownCardState extends State<_SemesterDropdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(_SemesterDropdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFF0B6B3A), Color(0xFF16A34A)],
      const [Color(0xFF0D47A1), Color(0xFF42A5F5)],
      const [Color(0xFF4A148C), Color(0xFF9C27B0)],
      const [Color(0xFFE65100), Color(0xFFFF9800)],
      const [Color(0xFFB71C1C), Color(0xFFEF5350)],
      const [Color(0xFF004D40), Color(0xFF26A69A)],
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
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorPair[1].withOpacity(0.3),
                  blurRadius: widget.isExpanded ? 20 : 12,
                  spreadRadius: widget.isExpanded ? 2 : 0,
                  offset: Offset(0, widget.isExpanded ? 8 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Header
                  InkWell(
                    onTap: widget.onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colorPair,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to expand',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RotationTransition(
                            turns: _iconRotation,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable Content
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: colorPair[0].withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colorPair[0],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Semester Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.event,
                              label: 'Period',
                              value: widget.label,
                              color: colorPair[0],
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.people_outline,
                              label: 'Members',
                              value: 'View panel members',
                              color: colorPair[0],
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.description_outlined,
                              label: 'Documents',
                              value: 'Access semester files',
                              color: colorPair[0],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: widget.onViewDetails,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorPair[0],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'View Full Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}