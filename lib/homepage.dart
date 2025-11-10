// homepage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← Firestore
import 'governing_panel_page.dart';
import 'ResearchProjectsPage.dart';
import 'event_page.dart';
import 'achievement.dart';
import 'member_recruitment_page.dart';
import 'educational_mentorship_training_programs_page.dart';
import 'FancyFloatingButton.dart';
import 'size_config.dart';

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
    SizeConfig.init(context);
    return Scaffold(
      // Keep body behind status bar = false so AppBar is fully visible
      extendBodyBehindAppBar: false,

      // -------------------- AppBar (unchanged) --------------------
      appBar: AppBar(
        toolbarHeight: SizeConfig.screenHeight*0.08,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF005022),
        foregroundColor: kOnPrimary,
        elevation: 6,
        centerTitle: false,
        titleSpacing: SizeConfig.screenWidth*0.04,
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
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo2.png',
                height: SizeConfig.screenHeight*0.045,
                width: SizeConfig.screenHeight*0.045,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 20,
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
            SizedBox(width: SizeConfig.screenWidth*0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AUST ROBOTICS CLUB',
                    style: TextStyle(
                      color: kOnPrimary,
                      fontSize: SizeConfig.screenWidth*0.035,
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
                      fontSize: SizeConfig.screenWidth*0.028,
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
        // actions: const [
        //   Icon(Icons.search),
        //   SizedBox(width: 12),
        //   Icon(Icons.notifications_none),
        //   SizedBox(width: 8),
        // ],
      ),
      // ------------------------------------------------------------------------------

      body: const SafeArea(
        child: HomeBody(),
      ),

      // 👇 Add the Floating Action Button here
      floatingActionButton: FancyFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

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
        SizedBox(height: SizeConfig.screenHeight*0.015),
        const _RecentEventsCarousel(),
        SizedBox(height: SizeConfig.screenHeight*0.001),
        // Right-aligned "Explore All Events" button
        Align(
          alignment: Alignment.centerRight,
          child: _ExploreEventsButton(),
        ),
        SizedBox(height: SizeConfig.screenHeight*0.005),
        _QuickActionsRow(),
        SizedBox(height: SizeConfig.screenHeight*0.005),
        //_EducationalProgramsSection(),
        SizedBox(height: SizeConfig.screenHeight*0.015),
         _MentorshipTrainingSection(),   // 👈 add this line
        SizedBox(height: SizeConfig.screenHeight*0.03),
        VoiceOfAUSTRC(),
      ],
    );
  }

}

/// A friendly welcome container (green theme)
// Modern Welcome Card with Smooth Animations
class _WelcomeCard extends StatefulWidget {
  const _WelcomeCard();

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F3D2E),
                Color(0xFF1A5C43),
                Color(0xFF267556),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kGreenDark.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated Background Pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: _WelcomePatternPainter(),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Animated Icon Container
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: (1 - value) * 0.5,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handshake_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text Content with Slide Animation
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(30 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome to AUST Robotics Club!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                height: 1.3,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7FE5A9),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    "Explore our latest events and projects",
                                    style: TextStyle(
                                      color: Color(0xFFB8E6D5),
                                      fontSize: 13.5,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Animated Arrow Indicator
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(8 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },

                    ),
                  ],
                ),
              ),

              // Shimmer Effect Overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: -1.0, end: 2.0),
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.easeInOut,
                    builder: (context, shimmerValue, child) {
                      return CustomPaint(
                        painter: _WelcomeShimmerPainter(shimmerProgress: shimmerValue),
                      );
                    },
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

// Custom Painter for Background Pattern
class _WelcomePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw circular patterns
    for (var i = 0; i < 8; i++) {
      final xPos = size.width * (0.2 + (i * 0.15));
      final yPos = size.height * (i.isEven ? 0.3 : 0.7);
      canvas.drawCircle(Offset(xPos, yPos), 40, circlePaint);
    }

    // Draw grid lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * i / 6, 0),
        Offset(size.width * i / 6, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Shimmer Effect
class _WelcomeShimmerPainter extends CustomPainter {
  final double shimmerProgress;

  _WelcomeShimmerPainter({required this.shimmerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(
          size.width * shimmerProgress - size.width * 0.3,
          0,
          size.width * 0.6,
          size.height,
        ),
      );

    canvas.drawRect(Offset.zero & size, shimmerPaint);
  }

  @override
  bool shouldRepaint(_WelcomeShimmerPainter oldDelegate) =>
      oldDelegate.shimmerProgress != shimmerProgress;
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
    return Column(
      children: [
        SizedBox(height: 20,),
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A5C43), Color(0xFF0F3D2E)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Explore All Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(4 * value, 0),
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 13,),
      ],
    );
  }
}

/// —— Creative Grid-Based Quick Actions with Floating Card Design
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Title with Gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kGreenDark.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.smart_button_sharp, color: Colors.white, size: 28),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Action Buttons',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All important options are in one place ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB8E6D5),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          // Creative 2x2 Grid Layout
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.9,
            children: [
              _QuickActionCard(
                label: 'Governing\nPanel',
                icon: Icons.groups_rounded,
                primary: const Color(0xFF0B6B3A),
                secondary: const Color(0xFF16A34A),
                delay: 0,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GoverningPanelPage()),
                  );
                },
              ),
              _QuickActionCard(
                label: 'Research &\nProjects',
                icon: Icons.biotech_rounded,
                primary: const Color(0xFF065F46),
                secondary: const Color(0xFF22C55E),
                delay: 100,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ResearchProjectsPage()),
                  );
                },
              ),
              _QuickActionCard(
                label: 'Member\nRecruitment',
                icon: Icons.event_available_rounded,
                primary: const Color(0xFF047857),
                secondary: const Color(0xFF10B981),
                delay: 200,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MemberRecruitmentPage()),
                  );
                },
              ),
              _QuickActionCard(
                label: 'Achievements',
                icon: Icons.emoji_events_rounded,
                primary: const Color(0xFF4D7C0F),
                secondary: const Color(0xFF84CC16),
                delay: 300,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AchievementPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Floating Card Design with Layered Depth Effect
class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.delay,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color primary;
  final Color secondary;
  final int delay;
  final VoidCallback? onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _entryController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();

    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _pressController.dispose();
    _entryController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _entryAnimation,
      child: FadeTransition(
        opacity: _entryAnimation,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _shimmerController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _pressController.forward(),
                onTapUp: (_) {
                  _pressController.reverse();
                  widget.onTap?.call();
                },
                onTapCancel: () => _pressController.reverse(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        widget.primary,
                        widget.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primary.withOpacity(0.4 * _elevationAnimation.value),
                        blurRadius: 16 * _elevationAnimation.value,
                        offset: Offset(0, 8 * _elevationAnimation.value),
                        spreadRadius: 2 * _elevationAnimation.value,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1 * _elevationAnimation.value),
                        blurRadius: 8 * _elevationAnimation.value,
                        offset: Offset(0, 4 * _elevationAnimation.value),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Animated shimmer overlay
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomPaint(
                            painter: _ShimmerPainter(
                              animation: _shimmerController,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.screenWidth*0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon with background circle
                            Container(
                              padding: EdgeInsets.all(SizeConfig.screenWidth*0.022),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                size: SizeConfig.screenWidth*0.050,
                                color: Colors.white,
                              ),
                            ),
                            // Label
                            Text(
                              widget.label,
                              style:TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: SizeConfig.screenWidth*0.035,
                                height: 1.2,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Corner accent
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for diagonal shimmer effect
class _ShimmerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _ShimmerPainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final progress = animation.value;
    final shimmerWidth = size.width * 0.3;
    final startX = -shimmerWidth + (size.width + shimmerWidth * 2) * progress;

    final path = Path()
      ..moveTo(startX, 0)
      ..lineTo(startX + shimmerWidth, 0)
      ..lineTo(startX + shimmerWidth * 1.5, size.height)
      ..lineTo(startX + shimmerWidth * 0.5, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) => true;
}
/// ======================= Educational Programs ==========================
// class _EducationalProgramsSection extends StatelessWidget {
//   const _EducationalProgramsSection();
//
//   @override
//   Widget build(BuildContext context) {
//     final docRef = FirebaseFirestore.instance
//         .collection('All_Data')
//         .doc('Educational_Programs');
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section header
//         Row(
//           children: const [
//             Icon(Icons.school_rounded, color: kGreenDark),
//             SizedBox(width: 8),
//             Text(
//               'Educational Programs',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: Color(0xFF0F3D2E),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//
//         StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//           stream: docRef.snapshots(),
//           builder: (context, snapshot) {
//             Widget body;
//
//             if (snapshot.hasError) {
//               body = _EduErrorBox('Failed to load programs.\n${snapshot.error}');
//             } else if (snapshot.connectionState == ConnectionState.waiting ||
//                 !snapshot.hasData) {
//               body = const _EduGridSkeleton();
//             } else {
//               final data = snapshot.data?.data() ?? {};
//               final items = _ProgramItem.fromFirestoreMap(data);
//
//               if (items.isEmpty) {
//                 body = const _EduEmptyBox(
//                   'No programs yet.\nAdd Program_1 and Program_1_Name in Firestore.',
//                 );
//               } else {
//                 body = GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: items.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 12,
//                     crossAxisSpacing: 12,
//                     childAspectRatio: 3 / 4, // poster look
//                   ),
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     return _ProgramCard(item: item, index: index);
//                   },
//                 );
//               }
//             }
//
//             // Add the CTA button at the bottom-right
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 body,
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: OutlinedButton.icon(
//                     icon: const Icon(Icons.arrow_forward_rounded, size: 18),
//                     label: const Text('See All Educational Programs'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: kGreenDark,
//                       side: const BorderSide(color: kGreenMain, width: 1.2),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 8),
//                       shape: const StadiumBorder(),
//                       textStyle: const TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                     onPressed: () {
//                       // TODO: navigate to your full programs screen/route
//                       // Navigator.pushNamed(context, '/educational-programs');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Navigate to: All Educational Programs'),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
//
// }

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
  final int number;
  final String imageUrl;
  final String title;

  _MentorProgramItem({
    required this.number,
    required this.imageUrl,
    required this.title,
  });

  static List<_MentorProgramItem> fromFirestoreMap(Map<String, dynamic> data) {
    final reg = RegExp(r'^MentorShip_(\d+)$', caseSensitive: false);
    final list = <_MentorProgramItem>[];

    data.forEach((key, value) {
      final m = reg.firstMatch(key);
      if (m != null && value is String && value.trim().isNotEmpty) {
        final n = int.tryParse(m.group(1)!);
        if (n != null) {
          final url = value.trim();
          final nameKey = 'MentorShip_${n}_Name';
          final title = (data[nameKey] as String?)?.trim() ?? 'Mentorship $n';
          list.add(_MentorProgramItem(number: n, imageUrl: url, title: title));
        }
      }
    });

    list.sort((a, b) => b.number.compareTo(a.number));
    return list;
  }
}
// Enhanced Mentorship Training Section with Modern Design
class _MentorshipTrainingSection extends StatelessWidget {
  const _MentorshipTrainingSection();

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Mentorship_Training');

    return Container(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [
      //       const Color(0xFF0B6B3A),
      //       const Color(0xFFFFFFFF),
      //       const Color(0xFFF5FBF8),
      //     ],
      //   ),
      //   borderRadius: BorderRadius.circular(24),
      // ),
      //padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Header with Gradient
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(1, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kGreenDark.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Educational & Mentorship',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Training Programs',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB8E6D5),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Live data with enhanced cards
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

              if (items.isEmpty) {
                return const _MTEmptyBox('No mentorship programs yet.');
              }

              // Horizontal scrollable cards (3 items max for preview)
              final previewItems = items.take(3).toList();
              return SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: previewItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    return _MentorModernCard(
                      item: previewItems[index],
                      index: index,
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Enhanced CTA Button
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: 0.95 + (0.05 * value), child: child),
              );
            },
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A5C43), Color(0xFF0F3D2E)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kGreenMain.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EducationalProgramsPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Explore All Programs',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(4 * value, 0),
                                child: child,
                              );
                            },
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Card with Glassmorphism Effect
class _MentorModernCard extends StatefulWidget {
  const _MentorModernCard({required this.item, required this.index});

  final _MentorProgramItem item;
  final int index;

  @override
  State<_MentorModernCard> createState() => _MentorModernCardState();
}

class _MentorModernCardState extends State<_MentorModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset((1 - animValue) * 50, 0),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -6.0 : 0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE8F5E9),
                              const Color(0xFFC8E6C9),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(kGreenDark),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 48, color: Color(0xFFB00020)),
                    ),
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGreenMain.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kGreenMain.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'Program #${widget.item.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        widget.item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Shine Effect on Hover
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
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
    );
  }
}

// Enhanced Skeleton Loader
class _MTSkeletonList extends StatelessWidget {
  const _MTSkeletonList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, i) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8F5E9),
                    const Color(0xFFF1F8F4),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Modern Empty State
class _MTEmptyBox extends StatelessWidget {
  const _MTEmptyBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Error State
class _MTErrorBox extends StatelessWidget {
  const _MTErrorBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F5), Color(0xFFFFEBEE)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB00020), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB00020),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3D2E), Color(0xFF1A5C43)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kGreenDark.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.white, size: 28),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice of AUSTRC',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Voices from or dedicated members',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB8E6D5),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
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
              width: 520,
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



