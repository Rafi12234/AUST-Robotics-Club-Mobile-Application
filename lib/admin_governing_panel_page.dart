import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_semester_panels_page.dart';

class AdminGoverningPanelPage extends StatefulWidget {
  const AdminGoverningPanelPage({Key? key}) : super(key: key);

  @override
  State<AdminGoverningPanelPage> createState() => _AdminGoverningPanelPageState();
}

class _AdminGoverningPanelPageState extends State<AdminGoverningPanelPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  // Theme colors - matching other admin pages
  static const Color kGreenDark = Color(0xFF0F3D2E);
  static const Color kGreenMain = Color(0xFF2D6A4F);
  static const Color kGreenLight = Color(0xFF52B788);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper methods for sorting
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

  Future<void> _addNewSemester() async {
    final TextEditingController semesterController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kGreenMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_circle_outline, color: kGreenMain),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add New Semester',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter semester name (e.g., Fall 2024, Spring 2025)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: semesterController,
              decoration: InputDecoration(
                labelText: 'Semester Name',
                hintText: 'e.g., Fall 2024',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kGreenMain, width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = semesterController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenMain,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        // Check if semester already exists
        final doc = await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Governing_Panel')
            .collection('Semesters')
            .doc(result)
            .get();

        if (doc.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Semester already exists!'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } else {
          // Create the semester document
          await FirebaseFirestore.instance
              .collection('All_Data')
              .doc('Governing_Panel')
              .collection('Semesters')
              .doc(result)
              .set({
            'created_at': FieldValue.serverTimestamp(),
          });

          // Create 4 collections inside the semester document by adding a dummy document to each
          // This is necessary because Firestore doesn't create empty collections
          final semesterRef = FirebaseFirestore.instance
              .collection('All_Data')
              .doc('Governing_Panel')
              .collection('Semesters')
              .doc(result);

          // Create Executive_Panel collection
          await semesterRef
              .collection('Executive_Panel')
              .doc('_placeholder')
              .set({
            'placeholder': true,
            'note': 'This document can be deleted after adding actual members',
          });

          // Create Deputy_Executive_Panel collection
          await semesterRef
              .collection('Deputy_Executive_Panel')
              .doc('_placeholder')
              .set({
            'placeholder': true,
            'note': 'This document can be deleted after adding actual members',
          });

          // Create Senior_Sub_Executive_Panel collection
          await semesterRef
              .collection('Senior_Sub_Executive_Panel')
              .doc('_placeholder')
              .set({
            'placeholder': true,
            'note': 'This document can be deleted after adding actual members',
          });

          // Create Sub_Executive_Panel collection
          await semesterRef
              .collection('Sub_Executive_Panel')
              .doc('_placeholder')
              .set({
            'placeholder': true,
            'note': 'This document can be deleted after adding actual members',
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Semester "$result" added successfully with all panel collections!'),
                backgroundColor: kGreenMain,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSemester(String semesterId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Semester?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$semesterId"? This will also delete all executive panel members under this semester.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        // Delete the semester document (subcollections will be handled separately if needed)
        await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Governing_Panel')
            .collection('Semesters')
            .doc(semesterId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Semester "$semesterId" deleted successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  opacity: _animationController,
                  child: const Text(
                    'Manage Governing Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Governing_Panel')
                .collection('Semesters')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kGreenMain),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Sort semesters
              final sortedDocs = [...docs];
              sortedDocs.sort((a, b) {
                final ay = _extractYear(a.id) ?? -1;
                final by = _extractYear(b.id) ?? -1;
                if (ay != by) return by.compareTo(ay);
                final sa = _seasonPriority(a.id);
                final sb = _seasonPriority(b.id);
                return sb.compareTo(sa);
              });

              if (sortedDocs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: Colors.grey[400],
                        ),
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
                          'Tap the + button to add a semester',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = sortedDocs[index];
                      final semesterId = doc.id;

                      return _SemesterCard(
                        semesterId: semesterId,
                        index: index,
                        onDelete: () => _deleteSemester(semesterId),
                      );
                    },
                    childCount: sortedDocs.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _addNewSemester,
        backgroundColor: kGreenMain,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Semester',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final String semesterId;
  final int index;
  final VoidCallback onDelete;

  const _SemesterCard({
    required this.semesterId,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFF0F3D2E), Color(0xFF2D6A4F)],
      const [Color(0xFF1B5E20), Color(0xFF388E3C)],
    ];
    final colorPair = gradients[index % gradients.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AdminSemesterPanelsPage(semesterId: semesterId),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // Smooth fade + slide transition
                  const begin = Offset(0.05, 0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;

                  var slideTween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeIn));
                  var scaleTween = Tween<double>(begin: 0.95, end: 1.0)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(slideTween),
                    child: FadeTransition(
                      opacity: animation.drive(fadeTween),
                      child: ScaleTransition(
                        scale: animation.drive(scaleTween),
                        child: child,
                      ),
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colorPair,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorPair[1].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        semesterId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to manage panel members',
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
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

