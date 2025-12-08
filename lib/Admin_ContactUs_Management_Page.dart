import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:math' as math;

// Brand colors (matching AdminFindAustrcIdPage)
const Color kBrandStart = Color(0xFF0B6B3A);
const Color kBrandEnd = Color(0xFF16A34A);
const Color kDarkGreen = Color(0xFF004D40);
const Color kLightGreen = Color(0xFF81C784);
const Color kAccentGold = Color(0xFFFFB703);

class AdminContactUsPage extends StatefulWidget {
  const AdminContactUsPage({Key? key}) : super(key: key);

  @override
  State<AdminContactUsPage> createState() => _AdminContactUsPageState();
}

class _AdminContactUsPageState extends State<AdminContactUsPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _waveController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

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

  Future<void> _deleteContact(String docId, String contactName) async {
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
              child: const Icon(Icons.warning_rounded, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            const Text('Delete Contact'),
          ],
        ),
        content: Text('Are you sure you want to delete "$contactName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Contact Us')
            .doc(docId)
            .delete();
        _showSnackBar('Contact deleted successfully');
      } catch (e) {
        _showSnackBar('Error deleting contact: $e', isError: true);
      }
    }
  }

  void _navigateToEditPage(String? docId, {Map<String, dynamic>? existingData}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ContactEditPage(
              docId: docId,
              existingData: existingData,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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
      floatingActionButton: _AddContactButton(
        onTap: () => _navigateToEditPage(null),
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
                                  'Manage Contacts',
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
                                  'Admin Panel - Contact Us Page',
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
          .collection('Contact Us')
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

        // Sort by Order field
        final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
        sortedDocs.sort((a, b) {
          final orderA = _parseOrder((a.data() as Map<String, dynamic>)['Order']);
          final orderB = _parseOrder((b.data() as Map<String, dynamic>)['Order']);
          return orderA.compareTo(orderB);
        });

        return _buildContactsList(sortedDocs);
      },
    );
  }

  int _parseOrder(dynamic value) {
    if (value == null) return 999999;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 999999;
    return 999999;
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
            'Loading contacts...',
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
                  Icons.contacts_rounded,
                  size: 80,
                  color: kBrandStart.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + button to add your\nfirst team member',
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

  Widget _buildContactsList(List<QueryDocumentSnapshot> docs) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Card
        _buildStatsCard(docs.length),
        const SizedBox(height: 24),

        // Section Header
        _buildSectionHeader(),
        const SizedBox(height: 16),

        // Contact Cards
        ...docs.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;
          final data = doc.data() as Map<String, dynamic>;

          return _ContactCard(
            docId: doc.id,
            data: data,
            index: index,
            onEdit: () => _navigateToEditPage(doc.id, existingData: data),
            onDelete: () => _deleteContact(doc.id, data['Name'] ?? 'Unknown'),
          );
        }).toList(),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatsCard(int totalContacts) {
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
        padding: const EdgeInsets.all(24),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kBrandStart, kBrandEnd],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
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
                    '$totalContacts',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kBrandStart,
                    ),
                  ),
                  Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kBrandStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, color: kBrandStart, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'By Order',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kBrandStart,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBrandStart.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.list_alt_rounded, color: kBrandStart, size: 22),
        ),
        const SizedBox(width: 12),
        const Text(
          'All Contacts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B4332),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kAccentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.touch_app_rounded, color: kAccentGold, size: 16),
              SizedBox(width: 4),
              Text(
                'Tap to Edit',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kAccentGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// CONTACT CARD
// ============================================
class _ContactCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.docId,
    required this.data,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.data['Name']?.toString() ?? 'Unknown';
    final designation = widget.data['Designation']?.toString() ?? '';
    final department = widget.data['Department']?.toString() ?? '';
    final imageUrl = widget.data['Image']?.toString() ?? '';
    final order = widget.data['Order'];

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
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onEdit();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kBrandStart.withOpacity(_isPressed ? 0.2 : 0.1),
                  blurRadius: _isPressed ? 25 : 15,
                  offset: Offset(0, _isPressed ? 10 : 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          kBrandStart.withOpacity(0.2),
                          kBrandEnd.withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandStart.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) => _buildPlaceholder(),
                      )
                          : _buildPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B4332),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (order != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kAccentGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$order',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: kAccentGold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (designation.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kBrandStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              designation,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kBrandStart,
                              ),
                            ),
                          ),
                        ],
                        if (department.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            department,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions
                  Column(
                    children: [
                      _IconActionButton(
                        icon: Icons.edit_rounded,
                        color: kBrandStart,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(height: 8),
                      _IconActionButton(
                        icon: Icons.delete_rounded,
                        color: Colors.redAccent,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: kBrandStart.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: kBrandStart,
          size: 32,
        ),
      ),
    );
  }
}

// ============================================
// ICON ACTION BUTTON
// ============================================
class _IconActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        child: Icon(
          widget.icon,
          color: widget.color,
          size: 20,
        ),
      ),
    );
  }
}

// ============================================
// ADD CONTACT BUTTON
// ============================================
class _AddContactButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddContactButton({required this.onTap});

  @override
  State<_AddContactButton> createState() => _AddContactButtonState();
}

class _AddContactButtonState extends State<_AddContactButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kBrandStart, kBrandEnd],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: kBrandStart.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Add Contact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// CONTACT EDIT PAGE
// ============================================
class _ContactEditPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const _ContactEditPage({
    this.docId,
    this.existingData,
  });

  @override
  State<_ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<_ContactEditPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  final _formKey = GlobalKey<FormState>();
  final _docNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _eduMailController = TextEditingController();
  final _orderController = TextEditingController();

  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadExistingData();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerSlide = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerController.forward();
  }

  void _loadExistingData() {
    if (widget.existingData != null) {
      _docNameController.text = widget.docId ?? '';
      _nameController.text = widget.existingData!['Name']?.toString() ?? '';
      _designationController.text = widget.existingData!['Designation']?.toString() ?? '';
      _departmentController.text = widget.existingData!['Department']?.toString() ?? '';
      _contactNumberController.text = widget.existingData!['Contact_Number']?.toString() ?? '';
      _eduMailController.text = widget.existingData!['Edu_Mail']?.toString() ?? '';
      _orderController.text = widget.existingData!['Order']?.toString() ?? '';
      _imageUrl = widget.existingData!['Image']?.toString();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _docNameController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _contactNumberController.dispose();
    _eduMailController.dispose();
    _orderController.dispose();
    super.dispose();
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

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploadingImage = true);

      // Upload to Cloudinary
      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'contacts'),
      );

      setState(() {
        _imageUrl = response.secureUrl;
        _isUploadingImage = false;
      });

      _showSnackBar('Image uploaded successfully!');
    } catch (e) {
      setState(() => _isUploadingImage = false);
      _showSnackBar('Error uploading image: $e', isError: true);
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newDocName = _docNameController.text.trim();
    if (newDocName.isEmpty) {
      _showSnackBar('Document name is required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final contactData = {
        'Name': _nameController.text.trim(),
        'Designation': _designationController.text.trim(),
        'Department': _departmentController.text.trim(),
        'Contact_Number': _contactNumberController.text.trim(),
        'Edu_Mail': _eduMailController.text.trim(),
        'Image': _imageUrl ?? '',
        'Order': int.tryParse(_orderController.text.trim()) ?? 999,
      };

      final contactCollection = FirebaseFirestore.instance.collection('Contact Us');

      if (widget.docId != null) {
        // Updating existing contact
        if (newDocName != widget.docId) {
          // Document name changed - need to rename

          // Show loading message
          _showSnackBar('Renaming document...', isError: false);

          // Create new document with new name
          await contactCollection.doc(newDocName).set(contactData);

          // Delete old document
          await contactCollection.doc(widget.docId).delete();

          _showSnackBar('Contact updated and renamed successfully!');

          if (mounted) {
            // Navigate to the new document page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => _ContactEditPage(
                  docId: newDocName,
                  existingData: contactData,
                ),
              ),
            );
          }
        } else {
          // Document name unchanged - just update
          await contactCollection.doc(widget.docId).update(contactData);
          _showSnackBar('Contact updated successfully!');

          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        // Creating new contact with specified document name
        await contactCollection.doc(newDocName).set(contactData);
        _showSnackBar('Contact created successfully!');

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showSnackBar('Error saving contact: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isEditing = widget.docId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          _buildHeader(topInset, isEditing),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Document Name Field (at the top)
                    _buildFormField(
                      controller: _docNameController,
                      label: 'Document Name',
                      icon: Icons.label_rounded,
                      hint: 'e.g., President, Vice_President, Advisor_1',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Document name is required';
                        }
                        // Check for valid document name (no special characters except underscore)
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                          return 'Use only letters, numbers, and underscores';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Info note for document name
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kBrandStart.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: kBrandStart.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: kBrandStart,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This will be the document ID in Firebase. Use a descriptive name like "President" or "Advisor_1".',
                              style: TextStyle(
                                fontSize: 12,
                                color: kDarkGreen,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Form Fields
                    _buildFormField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_rounded,
                      hint: 'Enter full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      controller: _designationController,
                      label: 'Designation',
                      icon: Icons.work_rounded,
                      hint: 'e.g., President, Vice President',
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      controller: _departmentController,
                      label: 'Department',
                      icon: Icons.business_rounded,
                      hint: 'e.g., CSE, EEE',
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      controller: _contactNumberController,
                      label: 'Contact Number',
                      icon: Icons.phone_rounded,
                      hint: '+880 1XXX-XXXXXX',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      controller: _eduMailController,
                      label: 'Edu Mail',
                      icon: Icons.email_rounded,
                      hint: 'example@aust.edu',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      controller: _orderController,
                      label: 'Display Order',
                      icon: Icons.sort_rounded,
                      hint: '1, 2, 3... (lower = higher priority)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    _buildSaveButton(isEditing),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topInset, bool isEditing) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(
            opacity: _headerFade.value.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 24),
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
              child: Row(
                children: [
                  _AnimatedBackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Contact' : 'Add New Contact',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing ? 'Update team member details' : 'Fill in team member details',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                      color: Colors.white,
                      size: 24,
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

  Widget _buildImageSection() {
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
        padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.image_rounded, color: kBrandStart),
                const SizedBox(width: 12),
                const Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          kBrandStart.withOpacity(0.2),
                          kBrandEnd.withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandStart.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _imageUrl != null && _imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: _imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: kBrandStart.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(kBrandStart),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder(),
                      )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  if (_isUploadingImage)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kBrandStart, kBrandEnd],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kBrandStart.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _imageUrl != null ? Icons.edit_rounded : Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to ${_imageUrl != null ? 'change' : 'upload'} photo',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: kBrandStart.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: kBrandStart,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kBrandStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kBrandStart, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4332),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBrandStart, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return GestureDetector(
      onTap: _isLoading ? null : _saveContact,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!])
              : const LinearGradient(
            colors: [Color(0xFF064E3B), kBrandStart, kBrandEnd],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _isLoading ? Colors.grey.withOpacity(0.3) : kBrandStart.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Saving...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              Icon(
                isEditing ? Icons.save_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isEditing ? 'Save Changes' : 'Create Contact',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
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
        Icons.contacts_rounded,
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