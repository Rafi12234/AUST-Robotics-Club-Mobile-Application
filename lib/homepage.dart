// homepage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← Firestore

/// AUST RC brand greens + white
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kOnPrimary = Colors.white;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep body behind status bar = false so AppBar is fully visible
      extendBodyBehindAppBar: false,

      // -------------------- DO NOT TOUCH (your AppBar kept as-is) --------------------
      appBar: AppBar(
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF005022),
        foregroundColor: kOnPrimary,
        elevation: 6,
        centerTitle: false,
        titleSpacing: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kGreenDark, kGreenMain],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo2.png',
                height: 45,
                width: 45,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: const Text(
                      'RC',
                      style: TextStyle(
                        color: kOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'AUST ROBOTICS CLUB',
                    style: TextStyle(
                      color: kOnPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TypewriterText(
                    text: 'Robotics for Building a Safer Future',
                    style: TextStyle(
                      color: Color.fromARGB(217, 255, 255, 255),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    speed: Duration(milliseconds: 60),
                    pause: Duration(milliseconds: 900),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 12),
          Icon(Icons.notifications_none),
          SizedBox(width: 8),
        ],
      ),
      // ------------------------------------------------------------------------------

      body: SafeArea(
        child: HomeBody(),
      ),
      backgroundColor: Colors.white,
    );
  }
}

/// ========================== BODY CONTENT ===================================
/// Welcome card + Firestore-powered, infinite carousel
class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _WelcomeCard(),
        const SizedBox(height: 16),
        const _RecentEventsCarousel(),
        const SizedBox(height: 8),
        // Right-aligned "Explore All Events" button
        Align(
          alignment: Alignment.centerRight,
          child: _ExploreEventsButton(),
        ),
        SizedBox(height: 16),
        _QuickActionsRow(),
        SizedBox(height: 16),
        _EducationalProgramsSection(),
      ],
    );
  }

}

/// A friendly welcome container (green theme)
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFD7F0DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8E3C8)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: kGreenMain.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.handshake_rounded, color: kGreenDark),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Welcome to AUST Robotics Club!\nExplore our latest events and projects.",
              style: TextStyle(
                color: Color(0xFF1B4332),
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Firestore listener → dynamic list of poster URLs → infinite auto-sliding carousel
class _RecentEventsCarousel extends StatefulWidget {
  const _RecentEventsCarousel();

  @override
  State<_RecentEventsCarousel> createState() => _RecentEventsCarouselState();
}

class _RecentEventsCarouselState extends State<_RecentEventsCarousel> {
  final _docRef =
  FirebaseFirestore.instance.collection('All_Data').doc('Recent_Events');

  late final PageController _controller;
  Timer? _timer;
  static const _autoSlideEvery = Duration(seconds: 3);
  static const _animDuration = Duration(milliseconds: 400);

  // We use a high initial page for a seamless infinite illusion.
  int _initialPage(int itemCount) => itemCount * 1000;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoSlide(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;

    // Ensure we start from a stable far page to allow infinite feel.
    final start = _initialPage(itemCount);
    if (_controller.hasClients) {
      _controller.jumpToPage(start);
    } else {
      // Delay to the next frame if controller isn't attached yet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(start);
        }
      });
    }

    _timer = Timer.periodic(_autoSlideEvery, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(duration: _animDuration, curve: Curves.easeOut);
    });
  }

  /// Extracts all fields that look like "Event_<number>" and sorts by number DESC
  List<String> _extractSortedUrls(Map<String, dynamic>? data) {
    if (data == null) return const [];
    final reg = RegExp(r'^Event_(\d+)$');
    final entries = <MapEntry<int, String>>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1) ?? '');
        if (n != null) entries.add(MapEntry(n, value.trim()));
      }
    });

    // Most recent first (e.g., Event_6 before Event_5)
    entries.sort((a, b) => b.key.compareTo(a.key));
    return entries.map((e) => e.value).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _docRef.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _errorBox('Failed to load recent events.\n${snap.error}');
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return _skeleton(height: 180);
        }

        final urls = _extractSortedUrls(snap.data?.data());
        if (urls.isEmpty) {
          return _emptyBox(
              'No recent event posters yet.\nAdd Event_1, Event_2, … to Firestore.');
        }

        // Kick off/refresh auto-slide whenever list changes
        _startAutoSlide(urls.length);

        // Reverse = true makes the motion look left→right while we call nextPage().
        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            // reverse: true, // movement appears left-to-right
            itemBuilder: (context, index) {
              final url = urls[index % urls.length];
              return _PosterCard(url: url);
            },
          ),
        );
      },
    );
  }

  Widget _skeleton({double height = 180}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F1),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      height: 140,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFB00020)),
      ),
    );
  }
}

/// Single poster with rounded corners, shadow, network loading & error states
class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            // progress indicator
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              final expected = progress.expectedTotalBytes;
              final loaded = progress.cumulativeBytesLoaded;
              return Container(
                color: const Color(0xFFF5F5F5),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: expected != null ? loaded / expected : null,
                  ),
                ),
              );
            },
            // graceful error
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFFDECEC),
                alignment: Alignment.center,
                child: const Text(
                  'Failed to load poster',
                  style: TextStyle(color: Color(0xFFB00020)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ======================= (unchanged) Typewriter text =======================
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 80),
    this.pause = const Duration(milliseconds: 800),
  });

  final String text;
  final TextStyle? style;
  final Duration speed;
  final Duration pause;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _index = 0;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.speed, (t) {
      if (!mounted) return;
      if (_index < widget.text.length) {
        setState(() => _index++);
      } else {
        _timer?.cancel();
        Future.delayed(widget.pause, () {
          if (!mounted) return;
          setState(() => _index = 0);
          _start();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.speed != widget.speed ||
        oldWidget.pause != widget.pause) {
      _index = 0;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.text.substring(0, _index.clamp(0, widget.text.length));
    return Text(
      visible,
      style: widget.style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ExploreEventsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: kGreenDark,
        side: const BorderSide(color: kGreenMain, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onPressed: () {
        // TODO: navigate to your events screen / route
        // Navigator.pushNamed(context, '/events');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to: All Events')),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Explore All Events'),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 18),
        ],
      ),
    );
  }
}

/// —— Horizontal, scrollable quick actions row
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _QuickActionButton(
            label: 'Governing Panel',
            icon: Icons.groups_rounded,
            primary: Color(0xFF0B6B3A),    // deep green
            secondary: Color(0xFF16A34A),  // main green
            accent: Color(0xFFD1FAE5),     // light mint
          ),
          SizedBox(width: 16),
          _QuickActionButton(
            label: 'Research & Projects',
            icon: Icons.biotech_rounded,
            primary: Color(0xFF065F46),    // emerald dark
            secondary: Color(0xFF22C55E),  // emerald
            accent: Color(0xFFCCFBF1),     // light cyan
          ),
          SizedBox(width: 16),
          _QuickActionButton(
            label: 'Activities',
            icon: Icons.event_available_rounded,
            primary: Color(0xFF047857),    // teal dark
            secondary: Color(0xFF10B981),  // teal
            accent: Color(0xFFD1FAE5),     // light mint
          ),
          SizedBox(width: 16),
          _QuickActionButton(
            label: 'Achievements',
            icon: Icons.emoji_events_rounded,
            primary: Color(0xFF4D7C0F),    // olive green
            secondary: Color(0xFF84CC16),  // lime green
            accent: Color(0xFFECFCCB),     // light lime
          ),
        ],
      ),
    );
  }
}

/// Professional gradient button with subtle shadows and refined styling
class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color primary;
  final Color secondary;
  final Color accent;
  final VoidCallback? onTap;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap ??
                    () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Open: ${widget.label}')),
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.primary,
                    widget.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  // Main shadow
                  BoxShadow(
                    color: widget.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  // Subtle inner highlight
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    blurStyle: BlurStyle.inner, // inner blur
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.2,
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
}
/// ======================= Educational Programs ==========================
class _EducationalProgramsSection extends StatelessWidget {
  const _EducationalProgramsSection();

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Educational_Programs');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: const [
            Icon(Icons.school_rounded, color: kGreenDark),
            SizedBox(width: 8),
            Text(
              'Educational Programs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F3D2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            Widget body;

            if (snapshot.hasError) {
              body = _EduErrorBox('Failed to load programs.\n${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              body = const _EduGridSkeleton();
            } else {
              final data = snapshot.data?.data() ?? {};
              final items = _ProgramItem.fromFirestoreMap(data);

              if (items.isEmpty) {
                body = const _EduEmptyBox(
                  'No programs yet.\nAdd Program_1 and Program_1_Name in Firestore.',
                );
              } else {
                body = GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 4, // poster look
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ProgramCard(item: item, index: index);
                  },
                );
              }
            }

            // Add the CTA button at the bottom-right
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                body,
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('See All Educational Programs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGreenDark,
                      side: const BorderSide(color: kGreenMain, width: 1.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      // TODO: navigate to your full programs screen/route
                      // Navigator.pushNamed(context, '/educational-programs');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigate to: All Educational Programs'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

}

/// Data holder for a program
class _ProgramItem {
  final int number;      // e.g., 6 for Program_6
  final String imageUrl; // direct link (imgbb)
  final String name;     // Program_6_Name

  _ProgramItem({required this.number, required this.imageUrl, required this.name});

  static List<_ProgramItem> fromFirestoreMap(Map<String, dynamic> data) {
    final reg = RegExp(r'^Program_(\d+)$');
    final list = <_ProgramItem>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1)!);
        if (n != null) {
          final url = value.trim();
          final nameKey = 'Program_${n}_Name';
          final name = (data[nameKey] as String?)?.trim() ?? 'Program $n';
          list.add(_ProgramItem(number: n, imageUrl: url, name: name));
        }
      }
    });

    // Newest first (higher number)
    list.sort((a, b) => b.number.compareTo(a.number));
    return list;
  }
}

/// Pretty, rounded poster card with fade-in + name below
class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.item, required this.index});

  final _ProgramItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Smooth staggered fade-in without extra packages
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      // small staggering based on index
      // delay: Duration(milliseconds: 40 * (index % 10)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: open program details if you have a screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Open: ${item.name}')),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poster
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: const Color(0xFFF5F5F5),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFDECEC),
                              alignment: Alignment.center,
                              child: const Text(
                                'Image error',
                                style: TextStyle(color: Color(0xFFB00020)),
                              ),
                            );
                          },
                        ),
                        // Subtle gradient top & bottom for premium feel
                        const _PosterGradient(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Name under poster
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F3D2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft overlay so posters look richer (no text on image, just styling)
class _PosterGradient extends StatelessWidget {
  const _PosterGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Container(
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.12), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton/loading grid
class _EduGridSkeleton extends StatelessWidget {
  const _EduGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3F1),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

/// Empty state
class _EduEmptyBox extends StatelessWidget {
  const _EduEmptyBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}

/// Error state
class _EduErrorBox extends StatelessWidget {
  const _EduErrorBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFB00020)),
      ),
    );
  }
}

