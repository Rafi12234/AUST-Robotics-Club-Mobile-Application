import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math' as math;

// ============================================
// AUST RC BRAND COLORS
// ============================================
const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kGreenDeep = Color(0xFF0F3D2E);
const kGreenAccent = Color(0xFF1A5C43);
const kGreenLight = Color(0xFFB8E6D5);
const kOnPrimary = Colors.white;
const String kContactCollection = 'Contact Us';

// ============================================
// CONTACT US PAGE
// ============================================
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  static const routeName = '/contact_us';
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const ContactUsPage());
  static void open(BuildContext context) => Navigator.of(context).push(route());

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _fabController;
  late AnimationController _pulseController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _pulseAnimation;

  // Scroll Controller
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingHeader = false;

  // Selected contact for detail view
  Map<String, dynamic>? _selectedContact;
  bool _isDetailSheetVisible = false; // ✅ FIXED: Renamed variable

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _initAnimations() {
    // Header Animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    // FAB Animation
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    // Pulse Animation for call button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabController.forward();
    });
  }

  void _onScroll() {
    final showHeader = _scrollController.offset > 100;
    if (showHeader != _showFloatingHeader) {
      setState(() => _showFloatingHeader = showHeader);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _fabController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Launch URL helper with haptic feedback
  Future<void> _launchUrl(String url, {bool isEmail = false}) async {
    HapticFeedback.mediumImpact();

    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showSnackBar('Could not open ${isEmail ? 'email' : 'phone'} app');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}');
      }
    }
  }

  // Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    await _launchUrl('tel:$cleanNumber');
  }

  // Send email
  Future<void> _sendEmail(String email, {String? name}) async {
    final subject = Uri.encodeComponent('Inquiry from AUST RC App');
    final body = Uri.encodeComponent('Dear ${name ?? 'Sir/Madam'},\n\n');
    await _launchUrl('mailto:$email?subject=$subject&body=$body', isEmail: true);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ✅ FIXED: Renamed method to avoid conflict
  void _openContactDetail(Map<String, dynamic> contact) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedContact = contact;
      _isDetailSheetVisible = true;
    });
  }

  void _closeContactDetail() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDetailSheetVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _selectedContact = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBF6),
      body: Stack(
        children: [
          // Background Decoration
          _buildBackgroundDecoration(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(),

                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),

          // Contact Detail Bottom Sheet
          if (_selectedContact != null) _buildContactDetailSheet(),

          // Overlay when sheet is visible
          if (_isDetailSheetVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeContactDetail,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.black.withOpacity(_isDetailSheetVisible ? 0.3 : 0),
                ),
              ),
            ),

          // Contact Detail Bottom Sheet (on top of overlay)
          if (_selectedContact != null) _buildContactDetailSheet(),

          // Floating Action Button
          if (!_isDetailSheetVisible) _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPainter(),
      ),
    );
  }

  Widget _buildAppBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_headerAnimation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: kGreenMain.withOpacity(0.06)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            _AnimatedIconButton(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 14),

            // Title with animation
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kGreenDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      'Get in touch with our team',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Logo
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kGreenMain.withOpacity(0.15),
                      kGreenDark.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kGreenMain.withOpacity(0.2)),
                ),
                child: Image.asset(
                  'assets/images/logo2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy_rounded,
                    color: kGreenMain,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(kContactCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingState();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return _buildContactList(docs);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: kGreenMain.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.people_alt_rounded,
                color: kGreenMain,
                size: 35,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kGreenMain),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading contacts...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
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
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenMain,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: kGreenMain.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.contacts_rounded,
                  color: kGreenMain,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Contact information will appear here\nonce added to the system.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: _buildHeaderSection(docs.length),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: _buildQuickActions(),
        ),

        // Contact Cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final data = docs[index].data();
                return _ContactCard(
                  data: data,
                  index: index,
                  onTap: () => _openContactDetail(data), // ✅ FIXED
                  onCall: () => _makePhoneCall(
                      data['Contact_Number']?.toString() ?? ''),
                  onEmail: () => _sendEmail(
                    data['Edu_Mail']?.toString() ?? '',
                    name: data['Name']?.toString(),
                  ),
                );
              },
              childCount: docs.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(int contactCount) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_headerAnimation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kGreenMain, kGreenDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated Icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'We\'re Here to Help!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Connect with our team members for any queries or assistance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Stats Row
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        icon: Icons.people_alt_rounded,
                        value: contactCount.toString(),
                        label: 'Team Members',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      _buildStatItem(
                        icon: Icons.access_time_rounded,
                        value: '24/7',
                        label: 'Available',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email Us',
                  color: Colors.orange,
                  delay: const Duration(milliseconds: 200),
                  onTap: () => _sendEmail('austrc@aust.edu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.location_on_rounded,
                  label: 'Visit Us',
                  color: Colors.purple,
                  delay: const Duration(milliseconds: 300),
                  onTap: () => _launchUrl(
                    'https://maps.google.com/?q=AUST+Dhaka+Bangladesh',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.public_rounded,
                  label: 'Website',
                  color: Colors.teal,
                  delay: const Duration(milliseconds: 400),
                  onTap: () => _launchUrl('https://aust.edu'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Team Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kGreenMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: kGreenMain,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Our Team',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildContactDetailSheet() {
    final contact = _selectedContact!;
    final name = contact['Name']?.toString() ?? 'Unnamed';
    final designation = contact['Designation']?.toString() ?? '';
    final department = contact['Department']?.toString() ?? '';
    final phone = contact['Contact_Number']?.toString() ?? '';
    final email = contact['Edu_Mail']?.toString() ?? '';
    final imageUrl = contact['Image']?.toString() ?? '';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      bottom: _isDetailSheetVisible ? 0 : -500, // ✅ FIXED
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent tap through
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) {
            _closeContactDetail();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Section
                    Row(
                      children: [
                        // Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: kGreenMain.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderImage(),
                            )
                                : _buildPlaceholderImage(),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              if (designation.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kGreenMain.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    designation,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kGreenMain,
                                      fontWeight: FontWeight.w600,
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

                        // Close button
                        GestureDetector(
                          onTap: _closeContactDetail,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Action Buttons
                    Row(
                      children: [
                        // Call Button
                        if (phone.isNotEmpty)
                          Expanded(
                            child: ScaleTransition(
                              scale: _pulseAnimation,
                              child: _DetailActionButton(
                                icon: Icons.phone_rounded,
                                label: 'Call Now',
                                sublabel: phone,
                                color: kGreenMain,
                                onTap: () => _makePhoneCall(phone),
                              ),
                            ),
                          ),

                        if (phone.isNotEmpty && email.isNotEmpty)
                          const SizedBox(width: 12),

                        // Email Button
                        if (email.isNotEmpty)
                          Expanded(
                            child: _DetailActionButton(
                              icon: Icons.email_rounded,
                              label: 'Send Email',
                              sublabel: email,
                              color: Colors.orange,
                              onTap: () => _sendEmail(email, name: name),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Copy Buttons
                    Row(
                      children: [
                        if (phone.isNotEmpty)
                          Expanded(
                            child: _CopyButton(
                              icon: Icons.copy_rounded,
                              label: 'Copy Phone',
                              value: phone,
                            ),
                          ),
                        if (phone.isNotEmpty && email.isNotEmpty)
                          const SizedBox(width: 12),
                        if (email.isNotEmpty)
                          Expanded(
                            child: _CopyButton(
                              icon: Icons.copy_rounded,
                              label: 'Copy Email',
                              value: email,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: kGreenMain.withOpacity(0.15),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: kGreenMain,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      right: 16,
      bottom: 16 + MediaQuery.of(context).padding.bottom,
      child: ScaleTransition(
        scale: _fabScaleAnimation,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _sendEmail('austrc@aust.edu');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kGreenMain, kGreenDark],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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

// ============================================
// CUSTOM BACKGROUND PAINTER
// ============================================
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGreenMain.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      100,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      150,
      paint,
    );

    paint.color = kGreenMain.withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.6),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// ANIMATED ICON BUTTON
// ============================================
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AnimatedIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isPressed
              ? kGreenMain.withOpacity(0.2)
              : kGreenMain.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
        transformAlignment: Alignment.center,
        child: Icon(
          widget.icon,
          color: kGreenDark,
          size: 20,
        ),
      ),
    );
  }
}

// ============================================
// QUICK ACTION BUTTON
// ============================================
class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Duration delay;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _visible = false;
  bool _isPressed = false;
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
      duration: const Duration(milliseconds: 400),
      opacity: _visible ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _visible ? 0 : 20, 0),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _isPressed
                  ? widget.color.withOpacity(0.18)
                  : widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.color.withOpacity(_isPressed ? 0.4 : 0.15),
                width: 1.5,
              ),
            ),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            transformAlignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  widget.icon,
                  color: widget.color,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
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

// ============================================
// CONTACT CARD
// ============================================
class _ContactCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const _ContactCard({
    required this.data,
    required this.index,
    required this.onTap,
    required this.onCall,
    required this.onEmail,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _visible = false;
  bool _isPressed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: 100 * (widget.index + 1)), () {
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
    final name = widget.data['Name']?.toString() ?? 'Unnamed';
    final designation = widget.data['Designation']?.toString() ?? '';
    final department = widget.data['Department']?.toString() ?? '';
    final phone = widget.data['Contact_Number']?.toString() ?? '';
    final email = widget.data['Edu_Mail']?.toString() ?? '';
    final imageUrl = widget.data['Image']?.toString() ?? '';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _visible ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _visible ? 0 : 30, 0),
        margin: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isPressed
                    ? kGreenMain.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.1),
                width: _isPressed ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? kGreenMain.withOpacity(0.15)
                      : kGreenMain.withOpacity(0.05),
                  blurRadius: _isPressed ? 20 : 15,
                  offset: Offset(0, _isPressed ? 8 : 5),
                ),
              ],
            ),
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            transformAlignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: kGreenMain.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: kGreenMain.withOpacity(0.1),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      kGreenMain),
                                  value: loadingProgress
                                      .expectedTotalBytes !=
                                      null
                                      ? loadingProgress
                                      .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                          : _buildPlaceholder(),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (designation.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kGreenMain.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              designation,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kGreenDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (department.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  department,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Action Buttons
                  Column(
                    children: [
                      // Call Button
                      if (phone.isNotEmpty)
                        _ActionIconButton(
                          icon: Icons.phone_rounded,
                          color: kGreenMain,
                          onTap: widget.onCall,
                        ),

                      if (phone.isNotEmpty && email.isNotEmpty)
                        const SizedBox(height: 10),

                      // Email Button
                      if (email.isNotEmpty)
                        _ActionIconButton(
                          icon: Icons.email_rounded,
                          color: Colors.orange,
                          onTap: widget.onEmail,
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
      color: kGreenMain.withOpacity(0.12),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: kGreenMain,
          size: 32,
        ),
      ),
    );
  }
}

// ============================================
// ACTION ICON BUTTON
// ============================================
class _ActionIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<_ActionIconButton> {
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.color.withOpacity(0.25)
              : widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 0.5 : 0.2),
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        child: Icon(
          widget.icon,
          color: widget.color,
          size: 22,
        ),
      ),
    );
  }
}

// ============================================
// DETAIL ACTION BUTTON
// ============================================
class _DetailActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DetailActionButton> createState() => _DetailActionButtonState();
}

class _DetailActionButtonState extends State<_DetailActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color,
              widget.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_isPressed ? 0.5 : 0.35),
              blurRadius: _isPressed ? 18 : 12,
              offset: Offset(0, _isPressed ? 10 : 5),
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        transformAlignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.sublabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// COPY BUTTON
// ============================================
class _CopyButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CopyButton({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  bool _isPressed = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _copy();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _copied
              ? kGreenMain.withOpacity(0.15)
              : (_isPressed ? Colors.grey[200] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _copied
                ? kGreenMain.withOpacity(0.4)
                : (_isPressed ? Colors.grey[300]! : Colors.transparent),
            width: 1.5,
          ),
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _copied ? Icons.check_rounded : widget.icon,
                key: ValueKey(_copied),
                color: _copied ? kGreenMain : Colors.grey[600],
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _copied ? 'Copied!' : widget.label,
                key: ValueKey(_copied),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _copied ? kGreenMain : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}