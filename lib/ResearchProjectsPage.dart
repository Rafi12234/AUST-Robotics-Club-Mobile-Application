import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart'; // <-- for Clipboard
import 'dart:math' as math;

// Main Research Projects List Page
class ResearchProjectsPage extends StatefulWidget {
  const ResearchProjectsPage({Key? key}) : super(key: key);

  @override
  State<ResearchProjectsPage> createState() => _ResearchProjectsPageState();
}

class _ResearchProjectsPageState extends State<ResearchProjectsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _showProposalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProposalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // FAB to open the ProposalDialog
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProposalDialog(context),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Stack(
        children: [
          // Animated Background Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlesPainter(
                    animation: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Animated Header
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: const Color(0xFF1B5E20),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final expandedHeight = 220.0;
                    final collapsedHeight =
                        kToolbarHeight + MediaQuery.of(context).padding.top;
                    final currentHeight = constraints.maxHeight;
                    final collapseRatio = ((expandedHeight - currentHeight) /
                        (expandedHeight - collapsedHeight))
                        .clamp(0.0, 1.0);

                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D3B1F),
                            Color(0xFF1B5E20),
                            Color(0xFF2E7D32),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Animated DNA Helix Pattern
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _headerController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _DNAHelixPainter(
                                    animation: _headerController.value,
                                    opacity: 1 - collapseRatio,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Content
                          Positioned(
                            left: 24 + (48 * collapseRatio),
                            right: 24,
                            bottom: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (collapseRatio < 0.5) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.science,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Innovation Hub',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Text(
                                  'Research & Projects',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32 - (12 * collapseRatio),
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                if (collapseRatio < 0.5) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Explore groundbreaking innovations',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Projects List
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('All_Data')
                    .doc('Research_Projects')
                    .collection('research_projects')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
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
                            Icon(Icons.error_outline,
                                size: 70, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'Error loading projects',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.science_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Projects Yet',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back soon for amazing projects!',
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

                  final projects = snapshot.data!.docs;

                  return SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final project = projects[index];
                          final projectName = project.id;
                          final data = project.data() as Map<String, dynamic>?;

                          return TweenAnimationBuilder<double>(
                            duration:
                            Duration(milliseconds: 500 + (index * 100)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(-100 * (1 - value), 0),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildProjectCard(
                                context,
                                projectName,
                                data,
                                index,
                              ),
                            ),
                          );
                        },
                        childCount: projects.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
      BuildContext context,
      String projectName,
      Map<String, dynamic>? data,
      int index,
      ) {
    final colors = [
      [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      [const Color(0xFF00695C), const Color(0xFF00897B)],
      [const Color(0xFF1565C0), const Color(0xFF1976D2)],
      [const Color(0xFF6A1B9A), const Color(0xFF7B1FA2)],
    ];
    final gradient = colors[index % colors.length];

    // Cover image URL from project data
    final coverUrl = (data?['Cover_Picture'] ?? '').toString();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProjectDetailPage(
                  projectName: projectName,
                  projectData: data ?? {},
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var tween = Tween<double>(begin: 0.0, end: 1.0);
              var fadeAnimation = animation.drive(tween);

              var scaleTween = Tween<double>(begin: 0.9, end: 1.0);
              var scaleAnimation = animation.drive(scaleTween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[1].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Hexagon Pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _HexagonPatternPainter(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Cover image box (replaces bulb icon)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: coverUrl.isNotEmpty
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullScreenImagePage(imageUrl: coverUrl),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.photo_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          projectName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

// ==== Proposal Dialog (verification + submission) ====
class ProposalDialog extends StatefulWidget {
  const ProposalDialog({Key? key}) : super(key: key);

  @override
  State<ProposalDialog> createState() => _ProposalDialogState();
}

class _ProposalDialogState extends State<ProposalDialog> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _institutionalMailController = TextEditingController();

  bool _isVerified = false;
  bool _isVerifying = false;
  bool _isSubmitting = false;
  String _verifiedId = '';
  String _proposalType = 'Research';

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _institutionalMailController.dispose();
    super.dispose();
  }

  Future<void> _verifyId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your AUSTRC ID')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_AUSTRC_ID')
          .get();

      if (!doc.exists) {
        throw Exception('Student ID document not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      bool found = false;

      // Search through all Member_* fields
      for (var entry in data.entries) {
        if (entry.key.startsWith('Member_') && entry.value == id) {
          found = true;
          break;
        }
      }

      if (found) {
        setState(() {
          _isVerified = true;
          _verifiedId = id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid AUSTRC ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying ID: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _submitProposal() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final institutionalMail = _institutionalMailController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter project title')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter short description')),
      );
      return;
    }

    if (description.split(' ').length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description must be within 100 words')),
      );
      return;
    }

    if (institutionalMail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter institutional mail')),
      );
      return;
    }

    // Basic email validation
    if (!institutionalMail.contains('@') || !institutionalMail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_Proposal_for_R&P')
          .collection('student_proposal_for_R&P')
          .doc(_verifiedId)
          .set({
        'Proposal': _proposalType,
        'Title': title,
        'Short_Des': description,
        'Institutional_Mail': institutionalMail,
        'Timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting proposal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit Proposal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (!_isVerified) ...[
                // ID Verification Section
                const Text(
                  'Enter your AUSTRC ID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    hintText: 'e.g., AUSTRC001',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Verify ID',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Proposal Form Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'ID Verified: $_verifiedId',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Proposal Type
                const Text(
                  'Proposal Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Research'),
                        value: 'Research',
                        groupValue: _proposalType,
                        onChanged: (value) {
                          setState(() {
                            _proposalType = value!;
                          });
                        },
                        activeColor: const Color(0xFF2E7D32),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Project'),
                        value: 'Project',
                        groupValue: _proposalType,
                        onChanged: (value) {
                          setState(() {
                            _proposalType = value!;
                          });
                        },
                        activeColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter project/research title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Institutional Mail
                const Text(
                  'Institutional Mail',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _institutionalMailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your institutional email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Short Description (Max 100 words)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter a brief description...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProposal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Submit Proposal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== Project Detail Page =====================
class ProjectDetailPage extends StatefulWidget {
  final String projectName;
  final Map<String, dynamic> projectData;

  const ProjectDetailPage({
    Key? key,
    required this.projectName,
    required this.projectData,
  }) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  final Map<int, int> _sectionImageIndices = {};

  // Cache network image aspect ratios: url -> (width / height)
  final Map<String, double> _imageAspect = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Resolve and cache intrinsic aspect ratio for URL
  void _resolveImageAspect(String url) {
    if (url.isEmpty || _imageAspect.containsKey(url)) return;
    final img = Image.network(url);
    final ImageStream stream = img.image.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (h != 0) {
        if (mounted) {
          setState(() {
            _imageAspect[url] = w / h; // aspect = width / height
          });
        } else {
          _imageAspect[url] = w / h;
        }
      }
      stream.removeListener(listener!);
    }, onError: (error, stackTrace) {
      stream.removeListener(listener!);
    });
    stream.addListener(listener);
  }

  List<Map<String, dynamic>> _getOwners() {
    List<Map<String, dynamic>> owners = [];
    int ownerIndex = 1;
    while (true) {
      final nameKey = 'Owner_${ownerIndex}_Name';
      final designationKey = 'Owner_${ownerIndex}_Designation_Department';

      if (widget.projectData.containsKey(nameKey) &&
          widget.projectData[nameKey] != null) {
        owners.add({
          'name': widget.projectData[nameKey],
          'designation': widget.projectData[designationKey] ?? 'N/A',
        });
        ownerIndex++;
      } else {
        break;
      }
    }
    return owners;
  }

  List<Map<String, dynamic>> _getSections() {
    List<Map<String, dynamic>> sections = [];
    int sectionIndex = 1;
    while (true) {
      final nameKey = 'Section_${sectionIndex}_Name';
      final descriptionKey = 'Section_${sectionIndex}_Description';

      if (widget.projectData.containsKey(nameKey) &&
          widget.projectData[nameKey] != null) {
        // Get images for this section
        List<String> images = [];
        int imageIndex = 1;
        while (true) {
          final imageKey = 'Section_${sectionIndex}_Image_$imageIndex';
          if (widget.projectData.containsKey(imageKey) &&
              widget.projectData[imageKey] != null &&
              widget.projectData[imageKey].toString().isNotEmpty) {
            images.add(widget.projectData[imageKey]);
            imageIndex++;
          } else {
            break;
          }
        }

        sections.add({
          'name': widget.projectData[nameKey],
          'description': widget.projectData[descriptionKey] ?? '',
          'images': images,
        });
        sectionIndex++;
      } else {
        break;
      }
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final coverPhoto = widget.projectData['Cover_Picture'] ?? '';
    final title = widget.projectData['Title'] ?? widget.projectName;
    final subtitle = widget.projectData['Subtitle'] ?? '';
    final owners = _getOwners();
    final sections = _getSections();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Cover Photo Header
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverPhoto.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: coverPhoto,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          ),
                        ),
                        child: const Icon(
                          Icons.science,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        ),
                      ),
                      child: const Icon(
                        Icons.science,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                            height: 1.3,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Owners Section
                  if (owners.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Project Team',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...owners.asMap().entries.map((entry) {
                      final index = entry.key;
                      final owner = entry.value;
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(30 * (1 - value), 0),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                const Color(0xFF1B5E20).withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1B5E20),
                                      Color(0xFF43A047)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      owner['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      owner['designation'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Sections
                  ...sections.asMap().entries.map((entry) {
                    final sectionIndex = entry.key;
                    final section = entry.value;
                    final images = section['images'] as List<String>;
                    final description = (section['description'] as String?) ?? '';

                    return TweenAnimationBuilder<double>(
                      duration:
                      Duration(milliseconds: 800 + (sectionIndex * 150)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B5E20)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${sectionIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      section['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Section Images (original-size display)
                            if (images.isNotEmpty) ...[
                              const SizedBox(height: 16),

                              // Determine dynamic height from current image aspect ratio
                              Builder(
                                builder: (context) {
                                  final currentIdx =
                                      _sectionImageIndices[sectionIndex] ?? 0;
                                  final currentUrl =
                                  images[currentIdx].toString();
                                  _resolveImageAspect(currentUrl);

                                  final screenWidth =
                                      MediaQuery.of(context).size.width;
                                  final aspect = _imageAspect[currentUrl];
                                  final targetHeight =
                                  aspect != null ? (screenWidth / aspect) : 260.0;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    height: targetHeight,
                                    child: PageView.builder(
                                      controller:
                                      PageController(viewportFraction: 1),
                                      onPageChanged: (idx) {
                                        setState(() {
                                          _sectionImageIndices[sectionIndex] =
                                              idx;
                                        });
                                      },
                                      itemCount: images.length,
                                      itemBuilder: (context, imageIndex) {
                                        final url = images[imageIndex].toString();
                                        _resolveImageAspect(url);

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF1B5E20)
                                                    .withOpacity(0.2),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            FullScreenImagePage(
                                                                imageUrl: url),
                                                      ),
                                                    );
                                                  },
                                                  child: CachedNetworkImage(
                                                    imageUrl: url,
                                                    // contain = no cropping; respects natural aspect
                                                    fit: BoxFit.contain,
                                                    placeholder:
                                                        (context, url) =>
                                                        Container(
                                                          color: Colors.grey[200],
                                                          child: const Center(
                                                            child:
                                                            CircularProgressIndicator(
                                                              color:
                                                              Color(0xFF2E7D32),
                                                            ),
                                                          ),
                                                        ),
                                                    errorWidget: (context, url,
                                                        error) =>
                                                        Container(
                                                          color: Colors.grey[200],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            size: 60,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  ),
                                                ),

                                                // Image Counter
                                                Positioned(
                                                  bottom: 12,
                                                  right: 12,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                    ),
                                                    child: Text(
                                                      '${imageIndex + 1}/${images.length}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),
                              // Image Indicators
                              if (images.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    images.length,
                                        (idx) {
                                      final currentIndex =
                                          _sectionImageIndices[sectionIndex] ??
                                              0;
                                      final active = currentIndex == idx;
                                      return AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 300),
                                        width: active ? 30 : 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          gradient: active
                                              ? const LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20),
                                              Color(0xFF2E7D32),
                                            ],
                                          )
                                              : null,
                                          color: active
                                              ? null
                                              : Colors.grey[300],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],

                            // Section Description (with copy icon)
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  // Description card
                                  Container(
                                    // Add extra top-right padding so text doesn't hide under the icon
                                    padding: const EdgeInsets.fromLTRB(20, 20, 48, 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF2E7D32)
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                        height: 1.7,
                                        letterSpacing: 0.3,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),

                                  // Copy button at top-right
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        tooltip: 'Copy description',
                                        icon: const Icon(Icons.copy_rounded,
                                            size: 20, color: Color(0xFF2E7D32)),
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: description),
                                          );
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Description copied'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================ Full Screen Image (optional, on tap) =================
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== Custom Painters =====================
class _ParticlesPainter extends CustomPainter {
  final double animation;

  _ParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = (i * 73.5 + animation * size.width) % size.width;
      final y = (i * 47.3) % size.height;
      canvas.drawCircle(Offset(x, y), 3 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DNAHelixPainter extends CustomPainter {
  final double animation;
  final double opacity;

  _DNAHelixPainter({required this.animation, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double x = 0; x < size.width; x += 10) {
      final y1 = size.height * 0.5 +
          math.sin((x / 30) + animation * 2 * math.pi) * 30;
      final y2 = size.height * 0.5 -
          math.sin((x / 30) + animation * 2 * math.pi) * 30;

      canvas.drawCircle(Offset(x, y1), 2, paint);
      canvas.drawCircle(Offset(x, y2), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HexagonPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double y = -20; y < size.height + 20; y += 40) {
      for (double x = -20; x < size.width + 20; x += 35) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60) * math.pi / 180;
          final px = x + 15 * math.cos(angle);
          final py = y + 15 * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
