import 'package:flutter/material.dart';
import 'admin_panel_members_page.dart';

class AdminSemesterPanelsPage extends StatefulWidget {
  final String semesterId;

  const AdminSemesterPanelsPage({
    Key? key,
    required this.semesterId,
  }) : super(key: key);

  @override
  State<AdminSemesterPanelsPage> createState() => _AdminSemesterPanelsPageState();
}

class _AdminSemesterPanelsPageState extends State<AdminSemesterPanelsPage>
    with SingleTickerProviderStateMixin {
  // Theme colors - matching other admin pages
  static const Color kGreenDark = Color(0xFF0F3D2E);
  static const Color kGreenMain = Color(0xFF2D6A4F);
  static const Color kGreenLight = Color(0xFF52B788);

  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panels = [
      {
        'title': 'Executive Panel',
        'collection': 'Executive_Panel',
        'icon': Icons.stars_rounded,
        'gradient': [const Color(0xFF0F3D2E), const Color(0xFF2D6A4F)],
      },
      {
        'title': 'Deputy Executive Panel',
        'collection': 'Deputy_Executive_Panel',
        'icon': Icons.workspace_premium_rounded,
        'gradient': [const Color(0xFF1B5E20), const Color(0xFF388E3C)],
      },
      {
        'title': 'Senior Sub Executive Panel',
        'collection': 'Senior_Sub_Executive_Panel',
        'icon': Icons.military_tech_rounded,
        'gradient': [const Color(0xFF0D7C66), const Color(0xFF2D9A74)],
      },
      {
        'title': 'Sub Executive Panel',
        'collection': 'Sub_Executive_Panel',
        'icon': Icons.badge_rounded,
        'gradient': [const Color(0xFF2E7D32), const Color(0xFF52B788)],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: kGreenDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kGreenDark, kGreenMain, kGreenLight],
                ),
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                title: FadeTransition(
                  opacity: _headerController,
                  child: Text(
                    widget.semesterId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content - Panel Options
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final panel = panels[index];
                  return _PanelCard(
                    title: panel['title'] as String,
                    collectionName: panel['collection'] as String,
                    icon: panel['icon'] as IconData,
                    gradient: panel['gradient'] as List<Color>,
                    index: index,
                    semesterId: widget.semesterId,
                  );
                },
                childCount: panels.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PanelCard extends StatefulWidget {
  final String title;
  final String collectionName;
  final IconData icon;
  final List<Color> gradient;
  final int index;
  final String semesterId;

  const _PanelCard({
    required this.title,
    required this.collectionName,
    required this.icon,
    required this.gradient,
    required this.index,
    required this.semesterId,
  });

  @override
  State<_PanelCard> createState() => _PanelCardState();
}

class _PanelCardState extends State<_PanelCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (widget.index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPanelMembersPage(
                      semesterId: widget.semesterId,
                      panelTitle: widget.title,
                      collectionName: widget.collectionName,
                    ),
                  ),
                );
              },
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient[1].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
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
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage panel members',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.8),
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

