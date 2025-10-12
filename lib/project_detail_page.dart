import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectDetailPage extends StatefulWidget {
  final String docId; // document name inside research_projects
  const ProjectDetailPage({Key? key, required this.docId}) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PageController _pageController = PageController();
  int _current = 0;

  // App theme (match your app)
  static const Color brandStart = Color(0xFF0B6B3A);
  static const Color brandEnd = Color(0xFF16A34A);
  static const Color bgGradientStart = Color(0xFFE8F5E9);
  static const Color bgGradientEnd = Color(0xFFF1F8E9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Collect image URLs from fields named like:
  /// Image_1 / Image-2 / Image 3 (case-insensitive). Orders by the number.
  List<String> _extractImageUrls(Map<String, dynamic> data) {
    final entries = <_ImgField>[];
    final re = RegExp(r'^image[\s_\-]?(\d+)$', caseSensitive: false);

    // If you later add an array field `Images`, support that first.
    final arr = data['Images'];
    if (arr is List) {
      return arr
          .map((e) => (e ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    data.forEach((key, value) {
      if (value == null) return;
      final m = re.firstMatch(key.trim());
      if (m != null) {
        final n = int.tryParse(m.group(1) ?? '') ?? 0;
        final url = value.toString().trim();
        if (url.isNotEmpty) entries.add(_ImgField(n, url));
      }
    });

    entries.sort((a, b) => a.n.compareTo(b.n));
    return entries.map((e) => e.url).toList();
  }

  void _jumpRelative(int delta, int total) {
    if (total <= 1) return;
    final next = (_current + delta).clamp(0, total - 1);
    if (next == _current) return;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
    // DO NOT setState here; let onPageChanged drive _current to avoid jitter
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final docRef = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Research_Projects')
        .collection('research_projects')
        .doc(widget.docId);

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
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: docRef.snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError || !snap.hasData || !snap.data!.exists) {
                return const _ErrorState();
              }

              final data = snap.data!.data() ?? {};
              final title = (data['Title'] ?? '').toString();
              final subtitle = (data['Subtitle'] ?? '').toString();
              final by = (data['Project_by'] ?? '').toString();
              final desc = (data['Project_Des'] ?? '').toString();
              final images = _extractImageUrls(data);

              // Keep current index in bounds if images changed
              if (_current >= images.length && images.isNotEmpty) {
                _current = images.length - 1;
              }
              if (images.isEmpty && _current != 0) {
                _current = 0;
              }

              return Column(
                children: [
                  _Header(title: 'Project Detail', sub: widget.docId),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        if (title.trim().isNotEmpty)
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const SizedBox(height: 6),
                        if (subtitle.trim().isNotEmpty)
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (by.trim().isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  by,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Carousel
                        if (images.isNotEmpty)
                          _Carousel(
                            controller: _pageController,
                            images: images,
                            current: _current,
                            onChanged: (i) => setState(() => _current = i),
                            onPrev: () => _jumpRelative(-1, images.length),
                            onNext: () => _jumpRelative(1, images.length),
                          ),

                        if (images.isNotEmpty) const SizedBox(height: 16),

                        if (desc.trim().isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: brandStart.withOpacity(0.12),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              desc,
                              style: const TextStyle(fontSize: 15, height: 1.5),
                              textAlign: TextAlign.start,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String sub;
  const _Header({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_ProjectDetailPageState.brandStart, _ProjectDetailPageState.brandEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final int current;
  final ValueChanged<int> onChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _Carousel({
    Key? key,
    required this.controller,
    required this.images,
    required this.current,
    required this.onChanged,
    required this.onPrev,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final multi = images.length > 1;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: PageView.builder(
                  key: const PageStorageKey('project_images'), // keep position
                  controller: controller,
                  itemCount: images.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: onChanged,
                  itemBuilder: (context, i) {
                    final url = images[i];
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 48, color: Colors.black45),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (multi)
                Positioned(
                  left: 8,
                  child: _RoundButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onPrev,
                  ),
                ),
              if (multi)
                Positioned(
                  right: 8,
                  child: _RoundButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: onNext,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (multi)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: active ? 20 : 8,
                decoration: BoxDecoration(
                  color: active
                      ? _ProjectDetailPageState.brandStart
                      : _ProjectDetailPageState.brandStart.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon,
              size: 28, color: _ProjectDetailPageState.brandStart),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Could not load this project.'),
      ),
    );
  }
}

class _ImgField {
  final int n;
  final String url;
  _ImgField(this.n, this.url);
}
