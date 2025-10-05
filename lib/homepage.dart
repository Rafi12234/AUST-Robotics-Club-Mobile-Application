// homepage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← Firestore
import 'governing_panel_page.dart';

/// AUST RC brand greens + white
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kOnPrimary = Colors.white;
class EventItem {
  final int number;
  final String imageUrl;
  final String title;

  EventItem({required this.number, required this.imageUrl, required this.title});
}

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
        const SizedBox(height: 16),
        const _MentorshipTrainingSection(),   // 👈 add this line
        const SizedBox(height: 16),
        const VoiceOfAUSTRC(),



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
class _EventItem {
  final int number;
  final String imageUrl;
  final String title;
  const _EventItem({required this.number, required this.imageUrl, required this.title});
}

/// Firestore listener → dynamic list of poster URLs → infinite auto-sliding carousel
class _RecentEventsCarousel extends StatefulWidget {
  const _RecentEventsCarousel();

  @override
  State<_RecentEventsCarousel> createState() => _RecentEventsCarouselState();
}

class _RecentEventsCarouselState extends State<_RecentEventsCarousel>
    with AutomaticKeepAliveClientMixin {
  final _docRef =
  FirebaseFirestore.instance.collection('All_Data').doc('Recent_Events');

  late final PageController _controller;
  Timer? _timer;
  static const _autoSlideEvery = Duration(seconds: 3);
  static const _animDuration = Duration(milliseconds: 400);

  int? _lastCount;
  bool _didInitialJump = false;
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

  @override
  bool get wantKeepAlive => true;

  void _ensureStartPosition(int itemCount) {
    if (_didInitialJump || itemCount <= 0) return;
    final start = _initialPage(itemCount);
    if (_controller.hasClients) {
      _controller.jumpToPage(start);
      _didInitialJump = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.hasClients) {
          _controller.jumpToPage(start);
          _didInitialJump = true;
        }
      });
    }
  }

  void _ensureAutoTimer(int itemCount) {
    if (_timer != null || itemCount <= 1) return;
    _timer = Timer.periodic(_autoSlideEvery, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(duration: _animDuration, curve: Curves.easeOut);
    });
  }

  List<EventItem> _extractSortedEvents(Map<String, dynamic>? data) {
    if (data == null) return const [];
    final reg = RegExp(r'^Event_(\d+)$');
    final items = <EventItem>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1) ?? '');
        if (n != null) {
          final url = value.trim();
          final titleKey = 'Event_${n}_Name';
          final title = (data[titleKey] as String?)?.trim() ?? 'Event $n';
          items.add(EventItem(number: n, imageUrl: url, title: title));
        }
      }
    });

    items.sort((a, b) => b.number.compareTo(a.number));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _docRef.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _errorBox('Failed to load recent events.\n${snap.error}');
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return _skeleton(height: 200);
        }

        final events = _extractSortedEvents(snap.data?.data());
        if (events.isEmpty) {
          _timer?.cancel();
          _timer = null;
          _didInitialJump = false;
          _lastCount = 0;
          return _emptyBox(
              'No recent event posters yet.\nAdd Event_1, Event_1_Name … to Firestore.');
        }

        if (_lastCount != events.length) {
          _lastCount = events.length;
          _didInitialJump = false;
          _timer?.cancel();
          _timer = null;
        }

        _ensureStartPosition(events.length);
        _ensureAutoTimer(events.length);

        return SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            allowImplicitScrolling: true,
            itemBuilder: (context, index) {
              final item = events[index % events.length];
              return _PosterCard(item: item);
            },
          ),
        );
      },
    );
  }

  Widget _skeleton({double height = 200}) => Container(
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

  Widget _emptyBox(String message) => Container(
    height: 160,
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

  Widget _errorBox(String message) => Container(
    height: 160,
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
/// Single poster with rounded corners, shadow, network loading & bottom title
class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.item});
  final EventItem item;

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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
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

              // Bottom gradient + title
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.flash_on_rounded, color: kGreenDark, size: 20),
            SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F3D2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Horizontal scrollable buttons
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _QuickActionButton(
                label: 'Governing Panel',
                icon: Icons.groups_rounded,
                primary: const Color(0xFF0B6B3A),
                secondary: const Color(0xFF16A34A),
                accent: const Color(0xFFD1FAE5),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) =>  GoverningPanelPage()),
                  );
                },
              ),
              const SizedBox(width: 16),
              const _QuickActionButton(
                label: 'Research & Projects',
                icon: Icons.biotech_rounded,
                primary: Color(0xFF065F46),
                secondary: Color(0xFF22C55E),
                accent: Color(0xFFCCFBF1),
              ),
              const SizedBox(width: 16),
              const _QuickActionButton(
                label: 'Activities',
                icon: Icons.event_available_rounded,
                primary: Color(0xFF047857),
                secondary: Color(0xFF10B981),
                accent: Color(0xFFD1FAE5),
              ),
              const SizedBox(width: 16),
              const _QuickActionButton(
                label: 'Achievements',
                icon: Icons.emoji_events_rounded,
                primary: Color(0xFF4D7C0F),
                secondary: Color(0xFF84CC16),
                accent: Color(0xFFECFCCB),
              ),
            ],
          ),
        ),
      ],
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
                borderRadius: BorderRadius.circular(40),
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
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
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
class _MentorProgramItem {
  final int number;       // e.g., 3 for MentorShip_3
  final String imageUrl;  // direct link
  final String title;     // MentorShip_3_Name

  _MentorProgramItem({
    required this.number,
    required this.imageUrl,
    required this.title,
  });

  static List<_MentorProgramItem> fromFirestoreMap(Map<String, dynamic> data) {
    // handle “MentorShip” or “Mentorship” variants (case-insensitive)
    final reg = RegExp(r'^MentorShip_(\d+)$', caseSensitive: false);
    final list = <_MentorProgramItem>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1)!);
        if (n != null) {
          final url = value.trim();
          final nameKey = 'MentorShip_${n}_Name'; // keep same capitalization
          final title = (data[nameKey] as String?)?.trim() ?? 'Mentorship $n';
          list.add(_MentorProgramItem(number: n, imageUrl: url, title: title));
        }
      }
    });

    // newest first (higher number means more recent)
    list.sort((a, b) => b.number.compareTo(a.number));
    return list;
  }
}
class _MentorshipTrainingSection extends StatelessWidget {
  const _MentorshipTrainingSection();

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Mentorship_Training');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.support_agent_rounded, color: kGreenDark),
              SizedBox(width: 8),
              Text(
                'Mentorship & Training Programs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F3D2E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Live data
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _MTErrorBox('Failed to load mentorship programs.');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _MTSkeletonList();
            }

            final data = snapshot.data?.data() ?? {};
            final items = _MentorProgramItem.fromFirestoreMap(data);

            if (items.isEmpty) {
              return const _MTEmptyBox('No mentorship programs yet.');
            }

            // Zig-zag alternating wide cards (not a grid, not a carousel)
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _MentorZigZagCard(item: item, index: index);
              },
            );
          },
        ),

        const SizedBox(height: 12),

        // Bottom action
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('See all Mentorship Programs'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kGreenDark,
              side: const BorderSide(color: kGreenMain, width: 1.2),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              // TODO: Navigate to mentorship list screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open: All Mentorship Programs')),
              );
            },
          ),
        ),
      ],
    );
  }
}
class _MentorZigZagCard extends StatelessWidget {
  const _MentorZigZagCard({required this.item, required this.index});

  final _MentorProgramItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isLeft = index.isEven; // alternate sides
    final width = MediaQuery.of(context).size.width;

    // Poster (image only — no overlay inside the picture)
    final poster = DecoratedBox(
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
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xFFF5F5F5),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFFDECEC),
              alignment: Alignment.center,
              child: const Text('Image error', style: TextStyle(color: Color(0xFFB00020))),
            ),
          ),
        ),
      ),
    );

    // Staggered entrance
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final dx = (1 - value) * (isLeft ? -18 : 18);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(dx, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: SizedBox(
          width: width * 0.82, // wide card (distinct from grid & carousel)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              poster,
              const SizedBox(height: 6),
              // Title OUTSIDE the poster, bottom-right aligned
              Row(
                children: [
                  const Spacer(),
                  Flexible(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF0F3D2E),
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _MTSkeletonList extends StatelessWidget {
  const _MTSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) {
        final isLeft = i.isEven;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3F1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }
}
class _MTEmptyBox extends StatelessWidget {
  const _MTEmptyBox(this.message);
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
      child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
    );
  }
}
class _MTErrorBox extends StatelessWidget {
  const _MTErrorBox(this.message);
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
      child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB00020))),
    );
  }
}

/// ================= VOICE OF AUSTRC =================

class VoiceOfAUSTRC extends StatefulWidget {
  const VoiceOfAUSTRC({super.key});

  @override
  State<VoiceOfAUSTRC> createState() => _VoiceOfAUSTRCState();
}

class _VoiceOfAUSTRCState extends State<VoiceOfAUSTRC>
    with AutomaticKeepAliveClientMixin {
  final _docRef =
  FirebaseFirestore.instance.collection('All_Data').doc('Voice_of_AUSTRC');

  late final PageController _controller;
  Timer? _timer;

  // Slide config
  static const _autoSlideEvery = Duration(seconds: 3);
  static const _animDuration = Duration(milliseconds: 500);

  int _initialPageIndex = 5000; // large enough for "infinite" feel

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.9,
      initialPage: _initialPageIndex,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _startTimer(List<String> urls) {
    _timer?.cancel();
    if (urls.length <= 1) return;

    _timer = Timer.periodic(_autoSlideEvery, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(
        duration: _animDuration,
        curve: Curves.easeOut,
      );
    });
  }

  /// Extract fields like Voice_1, Voice_2 and sort by number ascending
  List<String> _extractUrls(Map<String, dynamic>? data) {
    if (data == null) return [];
    final reg = RegExp(r'^Voice_(\d+)$');
    final entries = <MapEntry<int, String>>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1)!);
        if (n != null) entries.add(MapEntry(n, value.trim()));
      }
    });

    entries.sort((a, b) => a.key.compareTo(b.key)); // Voice_1 → Voice_2 …
    return entries.map((e) => e.value).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: const [
            Icon(Icons.campaign_rounded, color: kGreenDark),
            SizedBox(width: 8),
            Text(
              'Voice of AUSTRC',
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
          stream: _docRef.snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return _errorBox('Failed to load posters.\n${snap.error}');
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return _skeleton();
            }

            final urls = _extractUrls(snap.data?.data());
            if (urls.isEmpty) {
              return _emptyBox('No posters yet.\nAdd Voice_1, Voice_2 …');
            }
            _startTimer(urls);
            return SizedBox(
              height: 400,
              width: 450,
              child: PageView.builder(
                controller: _controller,
                allowImplicitScrolling: true,
                itemBuilder: (context, index) {
                  final url = urls[index % urls.length];
                  return _VoicePosterCard(url: url);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _skeleton() => Container(
    height: 200,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F3F1),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: const SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _emptyBox(String message) => Container(
    height: 150,
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

  Widget _errorBox(String message) => Container(
    height: 150,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(12),
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

/// Single poster card with rounded corners and shadow
class _VoicePosterCard extends StatelessWidget {
  final String url;
  const _VoicePosterCard({required this.url});

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
            gaplessPlayback: true,
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
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFFDECEC),
              alignment: Alignment.center,
              child: const Text(
                'Image error',
                style: TextStyle(color: Color(0xFFB00020)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



