import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'executive_panel_page.dart';
import 'size_config.dart';

// Brand colors
const Color kBrandStart = Color(0xFF0B6B3A);
const Color kBrandEnd = Color(0xFF16A34A);
const Color kDarkGreen = Color(0xFF004D40);
const Color kLightGreen = Color(0xFF81C784);
const Color kAccentGold = Color(0xFFFFB703);

// Panel Types Enum
enum PanelType {
  executive,
  deputyExecutive,
  seniorSubExecutive,
  subExecutive,
}

class GoverningPanelPage extends StatefulWidget {
  const GoverningPanelPage({Key? key}) : super(key: key);

  @override
  State<GoverningPanelPage> createState() => _GoverningPanelPageState();
}

class _GoverningPanelPageState extends State<GoverningPanelPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  // Navigation States
  bool _showSemesters = false;
  bool _showPanelCategories = false;
  String? _selectedSemester;
  bool _isInitialAnimationComplete = false;

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
  }

  void _startAnimationSequence() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isInitialAnimationComplete = true);
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Sorting helpers
  int? _extractYear(String label) {
    final m = RegExp(r'(\d{4})').firstMatch(label);
    return m != null ? int.parse(m.group(1)!) : null;
  }

  int _seasonPriority(String label) {
    final l = label.toLowerCase();
    if (l.contains('fall')) return 2;
    if (l.contains('spring')) return 1;
    return 0;
  }

  void _revealSemesters() {
    HapticFeedback.mediumImpact();
    setState(() => _showSemesters = true);
  }

  void _hideSemesters() {
    HapticFeedback.lightImpact();
    setState(() {
      _showSemesters = false;
      _showPanelCategories = false;
      _selectedSemester = null;
    });
  }

  void _selectSemester(String semester) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedSemester = semester;
      _showPanelCategories = true;
    });
  }

  void _hidePanelCategories() {
    HapticFeedback.lightImpact();
    setState(() {
      _showPanelCategories = false;
      _selectedSemester = null;
    });
  }

  void _navigateToPanelPage(PanelType panelType) {
    HapticFeedback.mediumImpact();

    if (panelType == PanelType.executive) {
      // Navigate to existing Executive Panel Page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ExecutivePanelPage(semesterId: _selectedSemester!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      // Navigate to Poster Gallery Page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _PanelPosterGalleryPage(
                semesterId: _selectedSemester!,
                panelType: panelType,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  String _getHeaderSubtitle() {
    if (_showPanelCategories && _selectedSemester != null) {
      return 'Select panel category';
    } else if (_showSemesters) {
      return 'Select a semester to explore';
    }
    return 'Leadership & Excellence';
  }

  void _handleBackPress() {
    if (_showPanelCategories) {
      _hidePanelCategories();
    } else if (_showSemesters) {
      _hideSemesters();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _AnimatedBackground(
            waveController: _waveController,
            particleController: _particleController,
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                _buildHeader(topInset),
                Expanded(child: _buildContent(screenSize)),
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
              height: SizeConfig.screenHeight*0.13,
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
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: CustomPaint(
                        painter: _HeaderPatternPainter(animation: _floatingController),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(SizeConfig.screenWidth*0.03, SizeConfig.screenHeight*0.047, SizeConfig.screenWidth*0.035, SizeConfig.screenHeight*0.02),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _AnimatedBackButton(onTap: _handleBackPress),
                            SizedBox(width: SizeConfig.screenWidth*0.03),
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
                                    child: Text(
                                      _showPanelCategories && _selectedSemester != null
                                          ? _selectedSemester!
                                          : 'Governing Panel',
                                      style: TextStyle(
                                        fontSize: SizeConfig.screenWidth*0.05,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.screenHeight*0.005),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.5),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      _getHeaderSubtitle(),
                                      key: ValueKey(_getHeaderSubtitle()),
                                      style: TextStyle(
                                        fontSize: SizeConfig.screenWidth*0.03,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _HeaderBadge(animation: _pulseController),
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

  Widget _buildContent(Size screenSize) {
    final semestersQuery = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Governing_Panel')
        .collection('Semesters');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: semestersQuery.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _LoadingState();
        }
        if (snap.hasError) {
          return _ErrorState(error: snap.error.toString());
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyState();
        }

        final sortedDocs = [...docs];
        sortedDocs.sort((a, b) {
          final ay = _extractYear(a.id) ?? -1;
          final by = _extractYear(b.id) ?? -1;
          if (ay != by) return by.compareTo(ay);
          return _seasonPriority(b.id).compareTo(_seasonPriority(a.id));
        });

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: _showPanelCategories && _selectedSemester != null
              ? _PanelCategoriesList(
            key: const ValueKey('categories'),
            semesterName: _selectedSemester!,
            onBack: _hidePanelCategories,
            onSelectPanel: _navigateToPanelPage,
          )
              : _showSemesters
              ? _SemestersList(
            key: const ValueKey('semesters'),
            sortedDocs: sortedDocs,
            onBack: _hideSemesters,
            onSelectSemester: _selectSemester,
          )
              : _WelcomeSection(
            key: const ValueKey('welcome'),
            floatingController: _floatingController,
            pulseController: _pulseController,
            onExplore: _revealSemesters,
            isAnimationComplete: _isInitialAnimationComplete,
          ),
        );
      },
    );
  }
}

// ============================================
// PANEL CATEGORIES LIST
// ============================================
class _PanelCategoriesList extends StatelessWidget {
  final String semesterName;
  final VoidCallback onBack;
  final Function(PanelType) onSelectPanel;

  const _PanelCategoriesList({
    Key? key,
    required this.semesterName,
    required this.onBack,
    required this.onSelectPanel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      _PanelCategoryData(
        type: PanelType.executive,
        title: 'Executive Panel',
        subtitle: 'Meet our top leaders',
        icon: Icons.stars_rounded,
        gradient: [const Color(0xFFFFB703), const Color(0xFFFB8500)],
      ),
      _PanelCategoryData(
        type: PanelType.deputyExecutive,
        title: 'Deputy Executive Panel',
        subtitle: 'Supporting leadership team',
        icon: Icons.military_tech_rounded,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      ),
      _PanelCategoryData(
        type: PanelType.seniorSubExecutive,
        title: 'Senior Sub Executive Panel',
        subtitle: 'Experienced coordinators',
        icon: Icons.workspace_premium_rounded,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
      ),
      _PanelCategoryData(
        type: PanelType.subExecutive,
        title: 'Sub Executive Panel',
        subtitle: 'Dedicated team members',
        icon: Icons.groups_rounded,
        gradient: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      ),
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        // Back Section
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-30 * (1 - value), 0),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, color: kBrandStart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Back to Semesters',
                    style: TextStyle(
                      color: kBrandStart,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section Header
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(opacity: value.clamp(0.0, 1.0), child: child);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBrandStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.category_rounded, color: kBrandStart, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  Text(
                    'Choose a panel to explore',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Cards
        ...categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return _PanelCategoryCard(
            category: category,
            index: index,
            onTap: () => onSelectPanel(category.type),
          );
        }).toList(),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _PanelCategoryData {
  final PanelType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  _PanelCategoryData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _PanelCategoryCard extends StatefulWidget {
  final _PanelCategoryData category;
  final int index;
  final VoidCallback onTap;

  const _PanelCategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  State<_PanelCategoryCard> createState() => _PanelCategoryCardState();
}

class _PanelCategoryCardState extends State<_PanelCategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.category.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.category.gradient[0].withOpacity(_isPressed ? 0.5 : 0.3),
                  blurRadius: _isPressed ? 25 : 18,
                  offset: Offset(0, _isPressed ? 12 : 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CustomPaint(
                      painter: _CardPatternPainter(color: Colors.white),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          widget.category.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.category.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// PANEL POSTER GALLERY PAGE
// ============================================
class _PanelPosterGalleryPage extends StatefulWidget {
  final String semesterId;
  final PanelType panelType;

  const _PanelPosterGalleryPage({
    Key? key,
    required this.semesterId,
    required this.panelType,
  }) : super(key: key);

  @override
  State<_PanelPosterGalleryPage> createState() => _PanelPosterGalleryPageState();
}

class _PanelPosterGalleryPageState extends State<_PanelPosterGalleryPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerSlide = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  String _getPanelTitle() {
    switch (widget.panelType) {
      case PanelType.deputyExecutive:
        return 'Deputy Executive Panel';
      case PanelType.seniorSubExecutive:
        return 'Senior Sub Executive Panel';
      case PanelType.subExecutive:
        return 'Sub Executive Panel';
      default:
        return 'Panel';
    }
  }

  String _getCollectionName() {
    switch (widget.panelType) {
      case PanelType.deputyExecutive:
        return 'Deputy_Executive_Panel';
      case PanelType.seniorSubExecutive:
        return 'Senior_Sub_Executive_Panel';
      case PanelType.subExecutive:
        return 'Sub_Executive_Panel';
      default:
        return '';
    }
  }

  String _getDocumentName() {
    switch (widget.panelType) {
      case PanelType.deputyExecutive:
        return 'Deputy_Executive_1';
      case PanelType.seniorSubExecutive:
        return 'Senior_Sub_Executive_1';
      case PanelType.subExecutive:
        return 'Sub_Executive_1';
      default:
        return '';
    }
  }

  List<Color> _getGradientColors() {
    switch (widget.panelType) {
      case PanelType.deputyExecutive:
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      case PanelType.seniorSubExecutive:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case PanelType.subExecutive:
        return [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
      default:
        return [kBrandStart, kBrandEnd];
    }
  }

  IconData _getPanelIcon() {
    switch (widget.panelType) {
      case PanelType.deputyExecutive:
        return Icons.military_tech_rounded;
      case PanelType.seniorSubExecutive:
        return Icons.workspace_premium_rounded;
      case PanelType.subExecutive:
        return Icons.groups_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final gradientColors = _getGradientColors();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          // Header
          _buildHeader(topInset, gradientColors),

          // Content
          Expanded(
            child: _buildContent(gradientColors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topInset, List<Color> gradientColors) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(
            opacity: _headerFade.value.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPanelTitle(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.semesterId,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icon Badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getPanelIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(List<Color> gradientColors) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Governing_Panel')
          .collection('Semesters')
          .doc(widget.semesterId)
          .collection(_getCollectionName())
          .doc(_getDocumentName())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(gradientColors[0]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading posters...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), gradientColors);
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyWidget(gradientColors);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null || data.isEmpty) {
          return _buildEmptyWidget(gradientColors);
        }

        // Extract image URLs
        final List<String> imageUrls = [];
        data.forEach((key, value) {
          if (key.startsWith('Image_') && value is String && value.isNotEmpty) {
            imageUrls.add(value);
          }
        });

        // Sort by image number
        imageUrls.sort((a, b) {
          final keyA = data.entries.firstWhere((e) => e.value == a).key;
          final keyB = data.entries.firstWhere((e) => e.value == b).key;
          final numA = int.tryParse(keyA.replaceAll('Image_', '')) ?? 0;
          final numB = int.tryParse(keyB.replaceAll('Image_', '')) ?? 0;
          return numA.compareTo(numB);
        });

        if (imageUrls.isEmpty) {
          return _buildEmptyWidget(gradientColors);
        }

        return _buildPosterGrid(imageUrls, gradientColors);
      },
    );
  }

  Widget _buildPosterGrid(List<String> imageUrls, List<Color> gradientColors) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Card
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
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
                  color: gradientColors[0].withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${imageUrls.length} Poster${imageUrls.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: gradientColors[0],
                      ),
                    ),
                    Text(
                      'Tap any poster to view full size',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Poster Grid
        ...imageUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final url = entry.value;
          return _PosterCard(
            imageUrl: url,
            index: index,
            gradientColors: gradientColors,
          );
        }).toList(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyWidget(List<Color> gradientColors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value.clamp(0.0, 1.2),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: gradientColors[0].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 80,
                  color: gradientColors[0].withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Posters Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Posters for this panel will\nappear here once uploaded',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, List<Color> gradientColors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// POSTER CARD
// ============================================
class _PosterCard extends StatefulWidget {
  final String imageUrl;
  final int index;
  final List<Color> gradientColors;

  const _PosterCard({
    required this.imageUrl,
    required this.index,
    required this.gradientColors,
  });

  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard> {
  bool _isPressed = false;

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullImageViewer(
            imageUrl: widget.imageUrl,
            gradientColors: widget.gradientColors,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _showFullImage(context);
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors[0].withOpacity(_isPressed ? 0.3 : 0.15),
                  blurRadius: _isPressed ? 25 : 20,
                  offset: Offset(0, _isPressed ? 15 : 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Image
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(widget.gradientColors[0]),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay gradient at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Poster number badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.gradientColors),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradientColors[0].withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Poster ${widget.index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap to view indicator
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            color: widget.gradientColors[0],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              color: widget.gradientColors[0],
                              fontSize: 12,
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
      ),
    );
  }
}

// ============================================
// FULL IMAGE VIEWER
// ============================================
class _FullImageViewer extends StatelessWidget {
  final String imageUrl;
  final List<Color> gradientColors;

  const _FullImageViewer({
    required this.imageUrl,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tap background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),

          // Image with zoom
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),

          // Hint text at bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pinch_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Pinch to zoom • Tap outside to close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
// HEADER PATTERN PAINTER
// ============================================
class _HeaderPatternPainter extends CustomPainter {
  final AnimationController animation;

  _HeaderPatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final progress = (animation.value + i * 0.15) % 1.0;
      final x = size.width * (0.1 + i * 0.18);
      final y = size.height * (0.3 + math.sin(progress * math.pi * 2) * 0.1);
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
  bool shouldRepaint(covariant _HeaderPatternPainter oldDelegate) => true;
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
          math.sin((i / size.width * 4 * math.pi) + (animation * 2 * math.pi)) * 30 +
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
        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: SizeConfig.screenWidth * 0.035,
        ),
      ),
    );
  }
}

// ============================================
// HEADER BADGE
// ============================================
class _HeaderBadge extends StatelessWidget {
  final AnimationController animation;

  const _HeaderBadge({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(SizeConfig.screenWidth * 0.023),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15 + animation.value * 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3 + animation.value * 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1 * animation.value),
                blurRadius: 15 * animation.value,
                spreadRadius: 3 * animation.value,
              ),
            ],
          ),
          child:  Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: SizeConfig.screenWidth * 0.04,
          ),
        );
      },
    );
  }
}

// ============================================
// WELCOME SECTION
// ============================================
class _WelcomeSection extends StatelessWidget {
  final AnimationController floatingController;
  final AnimationController pulseController;
  final VoidCallback onExplore;
  final bool isAnimationComplete;

  const _WelcomeSection({
    Key? key,
    required this.floatingController,
    required this.pulseController,
    required this.onExplore,
    required this.isAnimationComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all( SizeConfig.screenWidth * 0.05),
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          // _WelcomeIllustration(
          //   floatingController: floatingController,
          //   isAnimationComplete: isAnimationComplete,
          // ),
          SizedBox(height: SizeConfig.screenHeight * 0.04),
          _WelcomeText(isAnimationComplete: isAnimationComplete),
          SizedBox(height: SizeConfig.screenHeight * 0.06),
          _ExploreButton(
            pulseController: pulseController,
            onTap: onExplore,
            isAnimationComplete: isAnimationComplete,
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.05),
        ],
      ),
    );
  }
}

// ============================================
// WELCOME ILLUSTRATION
// ============================================
class _WelcomeIllustration extends StatelessWidget {
  final AnimationController floatingController;
  final bool isAnimationComplete;

  const _WelcomeIllustration({
    required this.floatingController,
    required this.isAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isAnimationComplete ? 1 : 0),
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
            offset: Offset(0, -15 * floatingController.value),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: SizeConfig.screenWidth * 0.36,
                  height: SizeConfig.screenWidth * 0.36,
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
                Container(
                  width: SizeConfig.screenWidth * 0.1,
                  height: SizeConfig.screenWidth * 0.1,
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
                Container(
                  width: SizeConfig.screenWidth * 0.18,
                  height: SizeConfig.screenWidth * 0.18,
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
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.diversity_3_rounded,
                    color: Colors.white,
                    size: SizeConfig.screenWidth * 0.08,
                  ),
                ),
                ..._buildOrbitingElements(floatingController.value),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildOrbitingElements(double animValue) {
    return List.generate(4, (index) {
      final angle = (index * math.pi / 2) + (animValue * math.pi * 0.5);
      final radius = 110.0;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      final icons = [
        Icons.star_rounded,
        Icons.emoji_events_rounded,
        Icons.workspace_premium_rounded,
        Icons.auto_awesome_rounded,
      ];

      final colors = [kAccentGold, kBrandEnd, kBrandStart, kLightGreen];

      return Positioned(
        left: 100 + x - 18,
        top: 100 + y - 18,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors[index].withOpacity(0.4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icons[index], color: colors[index], size: 20),
        ),
      );
    });
  }
}

// ============================================
// WELCOME TEXT
// ============================================
class _WelcomeText extends StatelessWidget {
  final bool isAnimationComplete;

  const _WelcomeText({required this.isAnimationComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isAnimationComplete ? 1 : 0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Text(
            'Explore Our Leadership',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.screenWidth * 0.065,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B4332),
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ),
         SizedBox(height: SizeConfig.screenHeight * 0.015),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isAnimationComplete ? 1 : 0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Text(
            'Discover the dedicated individuals who guide\nour club towards excellence',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.screenWidth * 0.033,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;
  final int index;

  const _FeatureCard({required this.feature, required this.index});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(
          left: widget.index == 0 ? 0 : 6,
          right: widget.index == 2 ? 0 : 6,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.feature.color.withOpacity(_isPressed ? 0.3 : 0.15),
              blurRadius: _isPressed ? 20 : 15,
              offset: Offset(0, _isPressed ? 8 : 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.feature.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.feature.icon,
                color: widget.feature.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.feature.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.feature.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EXPLORE BUTTON (Continued)
// ============================================
class _ExploreButton extends StatefulWidget {
  final AnimationController pulseController;
  final VoidCallback onTap;
  final bool isAnimationComplete;

  const _ExploreButton({
    required this.pulseController,
    required this.onTap,
    required this.isAnimationComplete,
  });

  @override
  State<_ExploreButton> createState() => _ExploreButtonState();
}

class _ExploreButtonState extends State<_ExploreButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.isAnimationComplete ? 1 : 0),
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
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: SizeConfig.screenWidth * 0.04, horizontal: SizeConfig.screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandStart.withOpacity(
                        0.3 + (widget.pulseController.value * 0.2),
                      ),
                      blurRadius: 20 + (widget.pulseController.value * 15),
                      offset: const Offset(0, 8),
                      spreadRadius: widget.pulseController.value * 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.033),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: SizeConfig.screenWidth * 0.05,
                      ),
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Semester',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.043,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'View panel information',
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.033,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.03),
                    Container(
                      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: SizeConfig.screenWidth * 0.04,
                      ),
                    ),
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
// SEMESTERS LIST
// ============================================
class _SemestersList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedDocs;
  final VoidCallback onBack;
  final Function(String) onSelectSemester;

  const _SemestersList({
    Key? key,
    required this.sortedDocs,
    required this.onBack,
    required this.onSelectSemester,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        // Back Section
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-30 * (1 - value), 0),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, color: kBrandStart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Back to Overview',
                    style: TextStyle(
                      color: kBrandStart,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section Header
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(opacity: value.clamp(0.0, 1.0), child: child);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBrandStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.history_rounded, color: kBrandStart, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Semesters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  Text(
                    '${sortedDocs.length} semester${sortedDocs.length > 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Semester Cards
        ...sortedDocs.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;
          return _SemesterCard(
            label: doc.id,
            index: index,
            totalCount: sortedDocs.length,
            onTap: () => onSelectSemester(doc.id),
          );
        }).toList(),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ============================================
// SEMESTER CARD
// ============================================
class _SemesterCard extends StatefulWidget {
  final String label;
  final int index;
  final int totalCount;
  final VoidCallback onTap;

  const _SemesterCard({
    required this.label,
    required this.index,
    required this.totalCount,
    required this.onTap,
  });

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _isPressed = false;

  IconData _getSeasonIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('spring')) return Icons.local_florist_rounded;
    if (l.contains('fall')) return Icons.park_rounded;
    if (l.contains('summer')) return Icons.wb_sunny_rounded;
    if (l.contains('winter')) return Icons.ac_unit_rounded;
    return Icons.calendar_today_rounded;
  }

  Color _getSeasonColor(String label) {
    final l = label.toLowerCase();
    if (l.contains('spring')) return  const Color(0xFF047857);
    if (l.contains('fall')) return const Color(0xFF059669);
    if (l.contains('summer')) return const Color(0xFFFBBF24);
    if (l.contains('winter')) return const Color(0xFF3B82F6);
    return kBrandStart;
  }

  @override
  Widget build(BuildContext context) {
    final seasonColor = _getSeasonColor(widget.label);
    final isLatest = widget.index == 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  seasonColor,
                  seasonColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: seasonColor.withOpacity(_isPressed ? 0.5 : 0.3),
                  blurRadius: _isPressed ? 25 : 18,
                  offset: Offset(0, _isPressed ? 12 : 8),
                  spreadRadius: _isPressed ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CustomPaint(
                      painter: _CardPatternPainter(color: Colors.white),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getSeasonIcon(widget.label),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLatest)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'LATEST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to view panel categories',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// CARD PATTERN PAINTER
// ============================================
class _CardPatternPainter extends CustomPainter {
  final Color color;

  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.2),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      40,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// LOADING STATE
// ============================================
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBrandStart.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kBrandStart),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading semesters...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// ERROR STATE
// ============================================
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EMPTY STATE
// ============================================
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value.clamp(0.0, 1.2),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: kBrandStart.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 80,
                  color: kBrandStart.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Semesters Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add semester documents to\nAll_Data/Governing_Panel/Semesters',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}