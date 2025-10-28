import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'governing_panel_page.dart';
import 'achievement.dart';
import 'member_recruitment_page.dart';
import 'best_panel_member_page.dart';
import 'admin_login_page.dart';

class FancyFloatingButton extends StatefulWidget {
  const FancyFloatingButton({super.key});

  @override
  State<FancyFloatingButton> createState() => _FancyFloatingButtonState();
}

class _FancyFloatingButtonState extends State<FancyFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _blurAnimation;
  bool _isOpen = false;

  // Configuration
  final double _fabSize = 70.0;
  final double _buttonSize = 60.0;
  final double _radius = 140.0;
  final Color _primaryColor = const Color(0xFF1A5C43);

  @override
  void initState() {
    super.initState();

    // ⏱️ Slower, smoother master clock
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // 🌊 Gentle scale-in for the whole menu radius
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // 🔄 Soft rotation for the main FAB icon
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    // 🌫️ Fade of overlay / accessories
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    // 🔍 If you add blur later, this drives it smoothly
    _blurAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.60, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  void _navigateToPage(Widget page) {
    if (!_isOpen) return;

    setState(() => _isOpen = false);
    _controller.reverse();

    // ⏳ Give the close animation a beat to finish
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  List<_FabMenuItem> _getMenuItems() {
    return [
      _FabMenuItem(
        icon: Icons.calculate_rounded,
        label: 'Governing Panel',
        color: const Color(0xFFFF9800),
        onTap: () => _navigateToPage(const GoverningPanelPage()),
      ),
      _FabMenuItem(
        icon: Icons.emoji_events_rounded,
        label: 'Best Panel Members',
        color: const Color(0xFF8BC34A),
        onTap: () => _navigateToPage(const BestPanelMembersPage()),
      ),
      _FabMenuItem(
        icon: Icons.person_add_rounded,
        label: 'Admin Login',
        color: const Color(0xFF00897B),
        onTap: () => _navigateToPage(const AdminLoginPage()),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Stack(
      children: [
        // Tap-to-close overlay (transparent; timing still driven by fade)
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return IgnorePointer(
              ignoring: !_isOpen,
              child: GestureDetector(
                onTap: _toggleMenu,
                child: child,
              ),
            );
          },
          child: Container(color: Colors.transparent),
        ),

        // Floating button and menu
        Positioned(
          right: 16,
          bottom: 16,
          child: SizedBox(
            width: _radius * 2 + _fabSize,
            height: _radius * 2 + _fabSize,
            child: Stack(
              children: [
                // Radial menu items
                for (int i = 0; i < menuItems.length; i++)
                  _buildMenuItem(menuItems[i], i, menuItems.length),

                // Main FAB
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildMainFab(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Spread items along 90°→180° arc (2nd quadrant).
  /// Stagger is widened and eased for slower, smoother entry/exit.
  Widget _buildMenuItem(_FabMenuItem item, int index, int total) {
    const double startAngle = math.pi / 2;
    const double endAngle = math.pi;
    final double angleStep = (endAngle - startAngle) / (total - 1);
    final double angle = startAngle + (index * angleStep);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Wider, softer stagger
        final double start = 0.25 + (index * 0.10);
        final double end = (0.80 + (index * 0.10)).clamp(0.0, 1.0);
        final double staggeredProgress = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ).value;

        // Fade begins slightly earlier than motion
        final double fadeStart = (start - 0.12).clamp(0.0, 1.0);
        final double fadeEnd = (start + 0.18).clamp(0.0, 1.0);
        final double fadeProgress = CurvedAnimation(
          parent: _controller,
          curve: Interval(fadeStart, fadeEnd, curve: Curves.easeOutCubic),
        ).value;

        final double distance = _radius * staggeredProgress;
        final double dx = math.cos(angle) * distance;
        final double dy = -math.sin(angle) * distance;

        return Positioned(
          right: -dx + (_fabSize - _buttonSize) / 2,
          bottom: -dy + (_fabSize - _buttonSize) / 2,
          child: Transform.scale(
            scale: 0.85 + (staggeredProgress * 0.15), // subtle growth
            child: Opacity(
              opacity: fadeProgress.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: _buildActionButton(item),
    );
  }

  Widget _buildActionButton(_FabMenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isOpen ? item.onTap : null,
        borderRadius: BorderRadius.circular(_buttonSize / 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                // slower morph for hover/press feel
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color,
                      Color.lerp(item.color, Colors.black, 0.1)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.0,
                  ),
                ),
                child: Icon(item.icon, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(maxWidth: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.80),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double rotationProgress = _rotationAnimation.value;
        final double scaleProgress = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.00, 0.30, curve: Curves.easeOutCubic),
        ).value;

        return Transform.scale(
          scale: 0.92 + (scaleProgress * 0.08),
          child: Transform.rotate(
            angle: rotationProgress * math.pi / 1.8, // < 90° for softness
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleMenu,
          borderRadius: BorderRadius.circular(_fabSize / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 550), // was 400ms
            curve: Curves.easeInOutCubic,
            width: _fabSize,
            height: _fabSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isOpen
                    ? [const Color(0xFFEF5350), const Color(0xFFFF7043)]
                    : [_primaryColor, Color.lerp(_primaryColor, Colors.white, 0.1)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isOpen ? const Color(0xFFEF5350) : _primaryColor)
                      .withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(_isOpen ? 0.8 : 0.9),
                width: _isOpen ? 2.5 : 3.0,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600), // was 600ms
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInBack,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                _isOpen ? Icons.close_rounded : Icons.menu,
                key: ValueKey<bool>(_isOpen),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FabMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
