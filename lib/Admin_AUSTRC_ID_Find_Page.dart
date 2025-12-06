import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

// Brand colors
const Color kBrandStart = Color(0xFF0B6B3A);
const Color kBrandEnd = Color(0xFF16A34A);
const Color kDarkGreen = Color(0xFF004D40);
const Color kLightGreen = Color(0xFF81C784);
const Color kAccentGold = Color(0xFFFFB703);

class AdminFindAustrcIdPage extends StatefulWidget {
  const AdminFindAustrcIdPage({Key? key}) : super(key: key);

  @override
  State<AdminFindAustrcIdPage> createState() => _AdminFindAustrcIdPageState();
}

class _AdminFindAustrcIdPageState extends State<AdminFindAustrcIdPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _waveController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  // Cache for AUSTRC IDs
  final Map<String, String?> _austrcIdCache = {};
  final Map<String, bool> _loadingCache = {};

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
  }

  @override
  void dispose() {
    _headerController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Find AUSTRC ID from Members collection
  Future<String?> _findAustrcId(String austId, String eduMail) async {
    final cacheKey = '$austId-$eduMail';

    if (_austrcIdCache.containsKey(cacheKey)) {
      return _austrcIdCache[cacheKey];
    }

    try {
      final membersCollection = FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_AUSTRC_ID')
          .collection('Members');

      final querySnapshot = await membersCollection.get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final storedAustId = data['AUST_ID']?.toString().trim() ?? '';
        final storedEduMail = data['Edu_Mail']?.toString().trim().toLowerCase() ?? '';

        if (storedAustId == austId && storedEduMail == eduMail.toLowerCase()) {
          final austrcId = data['AUSTRC_ID']?.toString() ?? '';
          _austrcIdCache[cacheKey] = austrcId;
          return austrcId;
        }
      }

      _austrcIdCache[cacheKey] = null;
      return null;
    } catch (e) {
      debugPrint('Error finding AUSTRC ID: $e');
      return null;
    }
  }

  // Send email via Gmail
  Future<void> _sendEmail(String eduMail, String austrcId, String austId) async {
    final subject = Uri.encodeComponent('Your AUSTRC ID - Recovery Request');
    final body = Uri.encodeComponent('''
Dear AUSTRC Member,

Greetings from AUST Robotics Club!

We have received your request to recover your AUSTRC ID. Please find your details below:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 AUST ID: $austId
🆔 AUSTRC ID: $austrcId
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please keep this information safe for future reference.

If you did not request this information, please contact us immediately.

Best Regards,
AUST Robotics Club
Administration Team
''');

    final Uri emailUri = Uri.parse('mailto:$eduMail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        HapticFeedback.mediumImpact();
      } else {
        _showSnackBar('Could not open email client', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error opening email: $e', isError: true);
    }
  }

  // Delete request after handling
  Future<void> _deleteRequest(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Find_AUSTRC_ID')
          .doc(docId)
          .delete();

      HapticFeedback.mediumImpact();
      _showSnackBar('Request removed successfully');
    } catch (e) {
      _showSnackBar('Error removing request: $e', isError: true);
    }
  }

  // Mark request as completed
  Future<void> _markAsCompleted(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Find_AUSTRC_ID')
          .doc(docId)
          .update({
        'Status': 'Completed',
        'Completed_At': FieldValue.serverTimestamp(),
      });

      HapticFeedback.mediumImpact();
      _showSnackBar('Marked as completed');
    } catch (e) {
      _showSnackBar('Error updating status: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : kBrandStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show confirmation dialog
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : kBrandStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDestructive ? Icons.warning_rounded : Icons.help_outline_rounded,
                color: isDestructive ? Colors.redAccent : kBrandStart,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.redAccent : kBrandStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(topInset),
          Expanded(
            child: Stack(
              children: [
                _AnimatedBackground(
                  waveController: _waveController,
                  particleController: _particleController,
                ),
                _buildContent(),
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
              height: 140 + topInset,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
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
                                child: const Text(
                                  'ID Recovery Requests',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  );
                                },
                                child: Text(
                                  'Admin Panel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StaticHeaderBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Find_AUSTRC_ID')
          .orderBy('Requested_At', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return _buildRequestsList(docs);
      },
    );
  }

  Widget _buildLoadingState() {
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
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kBrandStart),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading requests...',
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

  Widget _buildErrorState(String error) {
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

  Widget _buildEmptyState() {
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
                  Icons.inbox_rounded,
                  size: 80,
                  color: kBrandStart.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Pending Requests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'All ID recovery requests have been\nprocessed. Check back later!',
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

  Widget _buildRequestsList(List<QueryDocumentSnapshot> docs) {
    // Separate pending and completed requests
    final pendingDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['Status'] != 'Completed';
    }).toList();

    final completedDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['Status'] == 'Completed';
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Card
        _buildStatsCard(pendingDocs.length, completedDocs.length),
        const SizedBox(height: 24),

        // Pending Requests Section
        if (pendingDocs.isNotEmpty) ...[
          _buildSectionHeader(
            'Pending Requests',
            Icons.pending_actions_rounded,
            pendingDocs.length,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          ...pendingDocs.asMap().entries.map((entry) {
            return _RequestCard(
              key: ValueKey(entry.value.id),
              doc: entry.value,
              index: entry.key,
              onFindAustrcId: _findAustrcId,
              onSendEmail: _sendEmail,
              onMarkCompleted: _markAsCompleted,
              onDelete: _deleteRequest,
              showConfirmDialog: _showConfirmDialog,
            );
          }).toList(),
          const SizedBox(height: 24),
        ],

        // Completed Requests Section
        if (completedDocs.isNotEmpty) ...[
          _buildSectionHeader(
            'Completed',
            Icons.check_circle_rounded,
            completedDocs.length,
            kBrandStart,
          ),
          const SizedBox(height: 16),
          ...completedDocs.asMap().entries.map((entry) {
            return _RequestCard(
              key: ValueKey(entry.value.id),
              doc: entry.value,
              index: entry.key,
              isCompleted: true,
              onFindAustrcId: _findAustrcId,
              onSendEmail: _sendEmail,
              onMarkCompleted: _markAsCompleted,
              onDelete: _deleteRequest,
              showConfirmDialog: _showConfirmDialog,
            );
          }).toList(),
        ],

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStatsCard(int pending, int completed) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kBrandStart.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.pending_actions_rounded,
                label: 'Pending',
                count: pending,
                color: Colors.orange,
              ),
            ),
            Container(
              height: 50,
              width: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.check_circle_rounded,
                label: 'Completed',
                count: completed,
                color: kBrandStart,
              ),
            ),
            Container(
              height: 50,
              width: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.summarize_rounded,
                label: 'Total',
                count: pending + completed,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B4332),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// STAT ITEM
// ============================================
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ============================================
// REQUEST CARD
// ============================================
class _RequestCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final int index;
  final bool isCompleted;
  final Future<String?> Function(String, String) onFindAustrcId;
  final Future<void> Function(String, String, String) onSendEmail;
  final Future<void> Function(String) onMarkCompleted;
  final Future<void> Function(String) onDelete;
  final Future<bool> Function({
  required String title,
  required String message,
  required String confirmText,
  bool isDestructive,
  }) showConfirmDialog;

  const _RequestCard({
    Key? key,
    required this.doc,
    required this.index,
    this.isCompleted = false,
    required this.onFindAustrcId,
    required this.onSendEmail,
    required this.onMarkCompleted,
    required this.onDelete,
    required this.showConfirmDialog,
  }) : super(key: key);

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _austrcId;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _loadAustrcId();
  }

  Future<void> _loadAustrcId() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final data = widget.doc.data() as Map<String, dynamic>;
    final austId = data['AUST_ID']?.toString() ?? '';
    final eduMail = data['Edu_Mail']?.toString() ?? '';

    final result = await widget.onFindAustrcId(austId, eduMail);

    if (mounted) {
      setState(() {
        _austrcId = result;
        _notFound = result == null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final austId = data['AUST_ID']?.toString() ?? 'N/A';
    final eduMail = data['Edu_Mail']?.toString() ?? 'N/A';
    final requestedAt = data['Requested_At'] as Timestamp?;
    final status = data['Status']?.toString() ?? 'Pending';

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: widget.isCompleted
                ? Border.all(color: kBrandStart.withOpacity(0.3), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.isCompleted
                    ? kBrandStart.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main Content
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isExpanded = !_isExpanded);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isCompleted
                                    ? [kBrandStart, kBrandEnd]
                                    : [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              widget.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.person_search_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  austId,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B4332),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  eduMail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                          ),
                        ],
                      ),

                      // Status & Time
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatusChip(
                            status: status,
                            isCompleted: widget.isCompleted,
                          ),
                          const Spacer(),
                          if (requestedAt != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimestamp(requestedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedContent(austId, eduMail),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(String austId, String eduMail) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),

          // AUSTRC ID Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _notFound
                  ? Colors.red.withOpacity(0.05)
                  : kBrandStart.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _notFound
                    ? Colors.red.withOpacity(0.2)
                    : kBrandStart.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _notFound
                        ? Colors.red.withOpacity(0.1)
                        : kBrandStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _notFound ? Icons.error_outline_rounded : Icons.badge_rounded,
                    color: _notFound ? Colors.redAccent : kBrandStart,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUSTRC ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _isLoading
                          ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation(kBrandStart),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Searching...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                          : Text(
                        _notFound
                            ? 'Not Found in Database'
                            : _austrcId ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _notFound
                              ? Colors.redAccent
                              : const Color(0xFF1B4332),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isLoading && !_notFound && _austrcId != null)
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _austrcId!));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('AUSTRC ID copied!'),
                          backgroundColor: kBrandStart,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      color: kBrandStart,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          if (!widget.isCompleted) ...[
            // Send Email Button
            _ActionButton(
              label: 'Send Email with AUSTRC ID',
              icon: Icons.email_rounded,
              gradient: [const Color(0xFF064E3B), kBrandStart, kBrandEnd],
              enabled: !_isLoading && !_notFound && _austrcId != null,
              onTap: () async {
                if (_austrcId != null) {
                  await widget.onSendEmail(eduMail, _austrcId!, austId);
                }
              },
            ),
            const SizedBox(height: 12),

            // Mark as Completed & Delete Row
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Mark Completed',
                    icon: Icons.check_circle_outline_rounded,
                    isOutlined: true,
                    outlineColor: kBrandStart,
                    onTap: () async {
                      final confirmed = await widget.showConfirmDialog(
                        title: 'Mark as Completed',
                        message:
                        'Are you sure you want to mark this request as completed?',
                        confirmText: 'Complete',
                      );
                      if (confirmed) {
                        await widget.onMarkCompleted(widget.doc.id);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isOutlined: true,
                    outlineColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () async {
                      final confirmed = await widget.showConfirmDialog(
                        title: 'Delete Request',
                        message:
                        'Are you sure you want to delete this request? This action cannot be undone.',
                        confirmText: 'Delete',
                        isDestructive: true,
                      );
                      if (confirmed) {
                        await widget.onDelete(widget.doc.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            // Only delete for completed
            _ActionButton(
              label: 'Remove from List',
              icon: Icons.delete_outline_rounded,
              isOutlined: true,
              outlineColor: Colors.redAccent,
              textColor: Colors.redAccent,
              onTap: () async {
                final confirmed = await widget.showConfirmDialog(
                  title: 'Remove Request',
                  message: 'Remove this completed request from the list?',
                  confirmText: 'Remove',
                  isDestructive: true,
                );
                if (confirmed) {
                  await widget.onDelete(widget.doc.id);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ============================================
// STATUS CHIP
// ============================================
class _StatusChip extends StatelessWidget {
  final String status;
  final bool isCompleted;

  const _StatusChip({
    required this.status,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? kBrandStart.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted ? kBrandStart : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isCompleted ? kBrandStart : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// ACTION BUTTON
// ============================================
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color>? gradient;
  final bool isOutlined;
  final Color? outlineColor;
  final Color? textColor;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.gradient,
    this.isOutlined = false,
    this.outlineColor,
    this.textColor,
    this.enabled = true,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: widget.isOutlined || !isEnabled
              ? null
              : LinearGradient(
            colors: widget.gradient ?? [kBrandStart, kBrandEnd],
          ),
          color: !isEnabled
              ? Colors.grey[200]
              : widget.isOutlined
              ? Colors.transparent
              : null,
          borderRadius: BorderRadius.circular(14),
          border: widget.isOutlined
              ? Border.all(
            color: isEnabled
                ? (widget.outlineColor ?? kBrandStart)
                : Colors.grey[300]!,
            width: 2,
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: !isEnabled
                  ? Colors.grey[400]
                  : widget.isOutlined
                  ? (widget.textColor ?? kBrandStart)
                  : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: !isEnabled
                    ? Colors.grey[400]
                    : widget.isOutlined
                    ? (widget.textColor ?? kBrandStart)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// STATIC HEADER BADGE
// ============================================
class _StaticHeaderBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.admin_panel_settings_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
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
          math.sin((i / size.width * 4 * math.pi) + (animation * 2 * math.pi)) *
              30 +
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