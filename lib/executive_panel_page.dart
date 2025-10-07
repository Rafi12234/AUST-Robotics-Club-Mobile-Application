import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExecutivePanelPage extends StatelessWidget {
  final String semesterId;

  const ExecutivePanelPage({
    Key? key,
    required this.semesterId,
  }) : super(key: key);

  // Keep colors aligned with your other page
  static const Color brandStart = Color(0xFF0B6B3A);
  static const Color brandEnd = Color(0xFF16A34A);
  static const Color bgGradientStart = Color(0xFFE8F5E9);
  static const Color bgGradientEnd = Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Governing_Panel')
        .collection('Semesters')
        .doc(semesterId)
        .collection('Executive_Panel')
        .orderBy('Order'); // ← Sort by your Order field

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
          child: Column(
            children: [
              _Header(semesterId: semesterId),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: query.snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return const _ErrorState();
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const _EmptyState();
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final data = docs[i].data();

                        final name        = (data['Name'] ?? '').toString();
                        final designation = (data['Designation'] ?? '').toString();
                        final department  = (data['Department'] ?? '').toString();
                        final email       = (data['Email'] ?? '').toString();
                        final imageUrl    = (data['Image'] ?? '').toString();
                        final facebook    = (data['Facebook'] ?? '').toString();
                        final linkedIn    = (data['LinkedIn'] ?? '').toString();

                        return _ProfileCard(
                          imageUrl: imageUrl,
                          name: name,
                          designation: designation,
                          department: department,
                          email: email,
                          facebook: facebook,
                          linkedIn: linkedIn,
                        );
                      },
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
}

class _Header extends StatelessWidget {
  final String semesterId;
  const _Header({required this.semesterId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ExecutivePanelPage.brandStart, ExecutivePanelPage.brandEnd],
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
                const Text(
                  'Executive Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  semesterId,
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

class _ProfileCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String facebook;
  final String linkedIn;

  const _ProfileCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.facebook,
    required this.linkedIn,
  }) : super(key: key);

  Future<void> _launch(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;
    final uri = Uri.tryParse(u);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _mailto(String address) async {
    final a = address.trim();
    if (a.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: a);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = imageUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ExecutivePanelPage.brandStart.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Picture (Cloudinary URL)
          AspectRatio(
            aspectRatio: 16 / 16,
            child: hasImg
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => _ImageFallback(),
            )
                : _ImageFallback(),
          ),

          // 2) Name
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              name.isNotEmpty ? name : '—',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // 3) Designation
          if (designation.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                designation,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

          // 4) Department
          if (department.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                department,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

          const SizedBox(height: 8),

          // 5) Email
          if (email.trim().isNotEmpty)
            _InfoRow(
              icon: Icons.email_outlined,
              label: email,
              onTap: () => _mailto(email),
            ),

          // 6) Facebook
          if (facebook.trim().isNotEmpty)
            _InfoRow(
              icon: Icons.facebook_rounded,
              label: 'Facebook Profile',
              onTap: () => _launch(facebook),
            ),

          // 7) LinkedIn
          if (linkedIn.trim().isNotEmpty)
            _InfoRow(
              icon: Icons.link_rounded,
              label: 'LinkedIn Profile',
              onTap: () => _launch(linkedIn),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: ExecutivePanelPage.brandStart),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ExecutivePanelPage.brandStart.withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.person_outline_rounded, size: 56, color: Colors.black45),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            SizedBox(height: 12),
            Text(
              'Could not load the executive panel.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: Colors.grey, size: 56),
            SizedBox(height: 12),
            Text(
              'No profiles found for this semester.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Add documents in:\nAll_Data/Governing_Panel/Semesters/<Semester>/Executive_Panel',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
