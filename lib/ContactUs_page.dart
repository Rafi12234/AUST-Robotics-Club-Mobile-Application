import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

// Colors and constants
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const String kContactCollection = 'Contact Us';

// Contact Us Page
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  static const routeName = '/contact_us';
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const ContactUsPage());
  static void open(BuildContext context) =>
      Navigator.of(context).push(route());

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  // Launch URL helper
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Slightly greener page background to match the club's color theme
      backgroundColor: const Color(0xFFF0FBF6),
      body: SafeArea(
        child: Column(
          children: [
            // POLISHED APP BAR (white + green) with subtle elevation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: kGreenMain.withOpacity(0.06))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Back button - green rounded
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kGreenMain.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: kGreenDark, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title
                  const Expanded(
                    child: Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kGreenDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // Small brand accent on the right - show project logo if available
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kGreenMain.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kGreenMain.withOpacity(0.22)),
                    ),
                    child: Image.asset(
                      'assets/images/logo2.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_rounded, color: kGreenMain, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection(kContactCollection)
                    .snapshots(),
                builder: (context, snapshot) {
                  // DEBUG LOG
                  debugPrint(
                      'ContactUs stream: state=${snapshot.connectionState}, '
                          'hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, '
                          'docs=${snapshot.data?.docs.length ?? 0}');

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No contacts found in "$kContactCollection".',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // WE HAVE DATA – SHOW THE LIST
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = docs[index].data();

                      final name = data['Name']?.toString() ?? 'Unnamed';
                      final designation =
                          data['Designation']?.toString() ?? '';
                      final department =
                          data['Department']?.toString() ?? '';
                      final phone =
                          data['Contact_Number']?.toString() ?? '';
                      final email = data['Edu_Mail']?.toString() ?? '';
                      final imageUrl = data['Image']?.toString() ?? '';

                      // Build polished card with info on left and image on right
                      final card = Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kGreenMain.withOpacity(0.06)),
                              boxShadow: [
                                BoxShadow(
                                  color: kGreenMain.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // TEXT INFO (left)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0B3A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (designation.isNotEmpty)
                                        Text(
                                          designation,
                                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                        ),
                                      if (department.isNotEmpty)
                                        Text(
                                          department,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          if (phone.isNotEmpty)
                                            GestureDetector(
                                              onTap: () => _launchUrl('tel:$phone'),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.phone_rounded, size: 16, color: kGreenDark),
                                                  const SizedBox(width: 6),
                                                  Text(phone, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                                                ],
                                              ),
                                            ),
                                          if (phone.isNotEmpty && email.isNotEmpty) const SizedBox(width: 16),
                                          if (email.isNotEmpty)
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _launchUrl('mailto:$email'),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.email_outlined, size: 16, color: kGreenDark),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        email,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // IMAGE (right)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: 84,
                                          height: 84,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 84,
                                          height: 84,
                                          color: kGreenMain.withOpacity(0.12),
                                          child: const Icon(Icons.person_rounded, color: kGreenDark, size: 36),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      // Wrap with staggered animation
                      return _StaggeredItem(
                        delay: Duration(milliseconds: 80 * (index + 1)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: card,
                        ),
                      );
                     },
                   );
                 },
               ),
             ),
          ],
        ),
      ),
    );
  }
}

// Small helper that shows the child with a staggered fade+slide animation after [delay].
class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _StaggeredItem({required this.child, required this.delay, Key? key}) : super(key: key);

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 420),
      opacity: _visible ? 1 : 0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _visible ? 0 : 10, 0),
        child: widget.child,
      ),
    );
  }
}
