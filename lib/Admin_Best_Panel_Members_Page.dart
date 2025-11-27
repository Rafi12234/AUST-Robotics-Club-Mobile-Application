import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentRed = Color(0xFFE63946);
const kAccentBlue = Color(0xFF3B82F6);
const kAccentPurple = Color(0xFF8B5CF6);
const kAccentOrange = Color(0xFFFF6B35);
const kAccentPink = Color(0xFFEC4899);
const kAccentTeal = Color(0xFF14B8A6);

// Team Configuration
class TeamConfig {
  final String name;
  final IconData icon;
  final Color color;

  const TeamConfig({
    required this.name,
    required this.icon,
    required this.color,
  });
}

final List<TeamConfig> kAllTeams = [
  TeamConfig(
    name: 'Event Management Team',
    icon: Icons.event_rounded,
    color: kAccentPurple,
  ),
  TeamConfig(
    name: 'Research and Development Team',
    icon: Icons.science_rounded,
    color: kAccentBlue,
  ),
  TeamConfig(
    name: 'Content Writing & Social Media Team',
    icon: Icons.edit_note_rounded,
    color: kAccentPink,
  ),
  TeamConfig(
    name: 'Graphics Design Team',
    icon: Icons.palette_rounded,
    color: kAccentOrange,
  ),
  TeamConfig(
    name: 'Administration Team',
    icon: Icons.admin_panel_settings_rounded,
    color: kAccentGold,
  ),
  TeamConfig(
    name: 'Public Relations Team',
    icon: Icons.campaign_rounded,
    color: kAccentTeal,
  ),
  TeamConfig(
    name: 'Web Development Team',
    icon: Icons.code_rounded,
    color: kGreenMain,
  ),
];

// ============================================
// MAIN PAGE
// ============================================
class AdminBestPanelMembersPage extends StatefulWidget {
  const AdminBestPanelMembersPage({Key? key}) : super(key: key);

  @override
  State<AdminBestPanelMembersPage> createState() =>
      _AdminBestPanelMembersPageState();
}

class _AdminBestPanelMembersPageState extends State<AdminBestPanelMembersPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _fabController;
  String? _selectedSemester;
  List<String> _availableSemesters = [];
  bool _isLoadingSemesters = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadAvailableSemesters();
  }

  Future<void> _loadAvailableSemesters() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .get();

      setState(() {
        _availableSemesters = snapshot.docs.map((doc) => doc.id).toList();
        _isLoadingSemesters = false;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _fabController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoadingSemesters = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading semesters: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _selectedSemester == null
                  ? _buildSemesterSelection()
                  : _buildTeamsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedSemester == null
          ? _AddSemesterFAB(
        controller: _fabController,
        onSemesterCreated: () {
          _loadAvailableSemesters();
        },
      )
          : _AddTeamMemberFAB(
        controller: _fabController,
        semester: _selectedSemester!,
        onMemberAdded: () {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildHeader() {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kGreenDark, kGreenMain, kGreenLight],
        ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    if (_selectedSemester != null) {
                      setState(() => _selectedSemester = null);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _headerController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Best Panel Members',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _selectedSemester == null
                              ? 'Manage best performers by semester'
                              : _selectedSemester!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedSemester != null) _buildTeamStatsBar(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTeamStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Best Panel Members')
            .collection('Semesters')
            .doc(_selectedSemester!)
            .collection('Informations')
            .snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;
          final remaining = kAllTeams.length - count;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                icon: Icons.check_circle_rounded,
                label: 'Added',
                value: count.toString(),
                color: Colors.greenAccent,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _StatItem(
                icon: Icons.pending_rounded,
                label: 'Remaining',
                value: remaining.toString(),
                color: Colors.orangeAccent,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _StatItem(
                icon: Icons.groups_rounded,
                label: 'Total Teams',
                value: kAllTeams.length.toString(),
                color: Colors.white,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSemesterSelection() {
    if (_isLoadingSemesters) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kGreenMain, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading semesters...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_availableSemesters.isEmpty) {
      return _BestPanelEmptyState(
        icon: Icons.emoji_events_rounded,
        title: 'No Semesters Yet',
        subtitle:
        'Create your first semester to start adding\nbest panel members',
        hint: 'Example: "Spring 2025" or "Fall 2024"',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kAccentGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: kAccentGold, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Select Semester',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kGreenDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kGreenLight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_availableSemesters.length} Total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kGreenMain,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._availableSemesters.asMap().entries.map((entry) {
          final index = entry.key;
          final semester = entry.value;
          return _BestPanelSemesterCard(
            semester: semester,
            index: index,
            onTap: () => setState(() => _selectedSemester = semester),
            onDelete: () => _deleteSemester(semester),
          );
        }).toList(),
        const SizedBox(height: 100),
      ],
    );
  }

  Future<void> _deleteSemester(String semester) async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: _BestPanelDeleteDialog(
              title: 'Delete Semester?',
              message: 'Are you sure you want to delete "$semester"?',
              warning:
              'This will delete all team member data for this semester permanently!',
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        final teamsSnapshot = await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Best Panel Members')
            .collection('Semesters')
            .doc(semester)
            .collection('Informations')
            .get();

        for (var doc in teamsSnapshot.docs) {
          await doc.reference.delete();
        }

        await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Best Panel Members')
            .collection('Semesters')
            .doc(semester)
            .delete();

        _loadAvailableSemesters();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('"$semester" deleted successfully'),
                ],
              ),
              backgroundColor: kGreenMain,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: kAccentRed,
            ),
          );
        }
      }
    }
  }

  Widget _buildTeamsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(_selectedSemester!)
          .collection('Informations')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: kGreenMain, strokeWidth: 3),
                SizedBox(height: 16),
                Text('Loading team members...',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Error loading data',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kAccentRed),
                ),
              ],
            ),
          );
        }

        final addedTeams = snapshot.data?.docs ?? [];

        if (addedTeams.isEmpty) {
          return _BestPanelEmptyState(
            icon: Icons.person_add_rounded,
            title: 'No Members Added',
            subtitle:
            'Start adding best panel members\nfor $_selectedSemester',
            hint: 'Tap the + button to add a team member',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addedTeams.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kAccentPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stars_rounded,
                          color: kAccentPurple, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Best Performers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kGreenDark,
                      ),
                    ),
                  ],
                ),
              );
            }

            final teamDoc = addedTeams[index - 1];
            final teamName = teamDoc.id;
            final data = teamDoc.data() as Map<String, dynamic>;

            return _TeamMemberCard(
              teamName: teamName,
              data: data,
              index: index - 1,
              semester: _selectedSemester!,
              onUpdate: () => setState(() {}),
            );
          },
        );
      },
    );
  }
}

// ============================================
// STAT ITEM
// ============================================
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================
// EMPTY STATE WIDGET (Renamed to avoid conflicts)
// ============================================
class _BestPanelEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String hint;

  const _BestPanelEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
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
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kGreenLight.withOpacity(0.15),
                      kAccentGold.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: kGreenMain),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kAccentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAccentGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: kAccentGold, size: 20),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
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

// ============================================
// SEMESTER CARD (Renamed to avoid conflicts)
// ============================================
class _BestPanelSemesterCard extends StatefulWidget {
  final String semester;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BestPanelSemesterCard({
    required this.semester,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_BestPanelSemesterCard> createState() => _BestPanelSemesterCardState();
}

class _BestPanelSemesterCardState extends State<_BestPanelSemesterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getSemesterIcon(String semester) {
    final s = semester.toLowerCase();
    if (s.contains('spring')) return Icons.eco_rounded;
    if (s.contains('fall')) return Icons.park_rounded;
    return Icons.calendar_month_rounded;
  }

  Color _getSemesterColor(String semester) {
    final s = semester.toLowerCase();
    if (s.contains('spring')) return const Color(0xFF10B981);
    if (s.contains('fall')) return kAccentOrange;
    return kAccentPurple;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSemesterColor(widget.semester);

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
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
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(_getSemesterIcon(widget.semester),
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.semester,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: kGreenDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FutureBuilder<int>(
                            future: _getTeamCount(),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              final remaining = kAllTeams.length - count;
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: count > 0
                                          ? kGreenLight.withOpacity(0.15)
                                          : Colors.grey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$count/${kAllTeams.length} teams',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                        count > 0 ? kGreenMain : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (remaining > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '$remaining remaining',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.grey[400], size: 22),
                      tooltip: 'Delete',
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int> _getTeamCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(widget.semester)
          .collection('Informations')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

// ============================================
// TEAM MEMBER CARD
// ============================================
class _TeamMemberCard extends StatefulWidget {
  final String teamName;
  final Map<String, dynamic> data;
  final int index;
  final String semester;
  final VoidCallback onUpdate;

  const _TeamMemberCard({
    required this.teamName,
    required this.data,
    required this.index,
    required this.semester,
    required this.onUpdate,
  });

  @override
  State<_TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<_TeamMemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TeamConfig _getTeamConfig() {
    return kAllTeams.firstWhere(
          (t) => t.name == widget.teamName,
      orElse: () => TeamConfig(
        name: widget.teamName,
        icon: Icons.group_rounded,
        color: kGreenMain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = _getTeamConfig();
    final name = widget.data['Name'] ?? 'Not Set';
    final department = widget.data['Department'] ?? 'Not Set';
    final image = widget.data['Image'] ?? '';

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: team.color.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: team.color.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [team.color, team.color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: team.color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: image.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(team.icon,
                                      color: Colors.white, size: 32),
                            )
                                : Icon(team.icon, color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: team.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(team.icon,
                                        color: team.color, size: 12),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.teamName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: team.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: kGreenDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.school_rounded,
                                      size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      department,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: team.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.keyboard_arrow_down_rounded,
                                color: team.color, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedContent(team),
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

  Widget _buildExpandedContent(TeamConfig team) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Divider(color: team.color.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _BestPanelActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: kAccentBlue,
                  onTap: () => _editMember(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BestPanelActionButton(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  color: kAccentRed,
                  onTap: () => _deleteMember(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editMember() async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: _BestPanelEditMemberDialog(
              semester: widget.semester,
              teamName: widget.teamName,
              currentData: widget.data,
            ),
          ),
        );
      },
    );

    if (result == true) {
      widget.onUpdate();
    }
  }

  Future<void> _deleteMember() async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: _BestPanelDeleteDialog(
              title: 'Delete Member?',
              message:
              'Remove ${widget.data['Name'] ?? 'this member'} from ${widget.teamName}?',
              warning: 'This action cannot be undone.',
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Best Panel Members')
            .collection('Semesters')
            .doc(widget.semester)
            .collection('Informations')
            .doc(widget.teamName)
            .delete();

        widget.onUpdate();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Member deleted successfully'),
                ],
              ),
              backgroundColor: kGreenMain,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: kAccentRed,
            ),
          );
        }
      }
    }
  }
}

// ============================================
// ACTION BUTTON (Renamed to avoid conflicts)
// ============================================
class _BestPanelActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BestPanelActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
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
// ADD SEMESTER FAB (Fixed - Using AnimatedBuilder correctly)
// ============================================
class _AddSemesterFAB extends StatefulWidget {
  final AnimationController controller;
  final VoidCallback onSemesterCreated;

  const _AddSemesterFAB({
    required this.controller,
    required this.onSemesterCreated,
  });

  @override
  State<_AddSemesterFAB> createState() => _AddSemesterFABState();
}

class _AddSemesterFABState extends State<_AddSemesterFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.elasticOut),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(0.3 + (_pulseController.value * 0.2)),
                  blurRadius: 16 + (_pulseController.value * 8),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSemesterDialog(context),
          backgroundColor: kGreenMain,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24,color: Colors.white,),
          label: const Text(
            'Add Semester',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSemesterDialog(BuildContext context) async {
    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: _BestPanelCreateSemesterDialog(),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _createSemester(result);
      widget.onSemesterCreated();
    }
  }

  Future<void> _createSemester(String semesterName) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(semesterName)
          .get();

      if (doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('"$semesterName" already exists!'),
                ],
              ),
              backgroundColor: kAccentGold,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(semesterName)
          .set({
        'Created_At': FieldValue.serverTimestamp(),
        'Semester_Name': semesterName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('"$semesterName" created successfully!'),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }
}

// ============================================
// ADD TEAM MEMBER FAB (Fixed)
// ============================================
class _AddTeamMemberFAB extends StatefulWidget {
  final AnimationController controller;
  final String semester;
  final VoidCallback onMemberAdded;

  const _AddTeamMemberFAB({
    required this.controller,
    required this.semester,
    required this.onMemberAdded,
  });

  @override
  State<_AddTeamMemberFAB> createState() => _AddTeamMemberFABState();
}

class _AddTeamMemberFABState extends State<_AddTeamMemberFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.elasticOut),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kAccentPurple.withOpacity(0.3 + (_pulseController.value * 0.2)),
                  blurRadius: 16 + (_pulseController.value * 8),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          onPressed: () => _showAddMemberDialog(context),
          backgroundColor: kAccentPurple,
          elevation: 0,
          icon: const Icon(Icons.person_add_rounded, size: 24),
          label: const Text(
            'Add Member',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: _BestPanelAddMemberDialog(semester: widget.semester),
          ),
        );
      },
    );

    if (result == true) {
      widget.onMemberAdded();
    }
  }
}

// ============================================
// CREATE SEMESTER DIALOG (Renamed)
// ============================================
class _BestPanelCreateSemesterDialog extends StatefulWidget {
  @override
  State<_BestPanelCreateSemesterDialog> createState() =>
      _BestPanelCreateSemesterDialogState();
}

class _BestPanelCreateSemesterDialogState
    extends State<_BestPanelCreateSemesterDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedPreset;
  bool _isValid = false;

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Spring', 'icon': Icons.eco_rounded, 'color': const Color(0xFF10B981)},
    {'name': 'Fall', 'icon': Icons.park_rounded, 'color': const Color(0xFFFF6B35)},
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _isValid = _controller.text.trim().isNotEmpty);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _selectPreset(String presetName) {
    final currentYear = DateTime.now().year;
    setState(() {
      _selectedPreset = presetName;
      _controller.text = '$presetName $currentYear';
      _isValid = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kGreenMain, kGreenLight],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Semester',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: kGreenDark,
                            ),
                          ),
                          Text(
                            'For best panel members',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Quick Select',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _presets.map((preset) {
                    final isSelected = _selectedPreset == preset['name'];
                    final color = preset['color'] as Color;
                    return InkWell(
                      onTap: () => _selectPreset(preset['name']),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(preset['icon'] as IconData,
                                size: 20,
                                color: isSelected ? color : Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              preset['name'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? color : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Custom Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kGreenDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Spring 2025',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                    const Icon(Icons.edit_calendar_rounded, color: kGreenMain),
                    suffixIcon: _isValid
                        ? const Icon(Icons.check_circle_rounded, color: kGreenMain)
                        : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: kGreenMain, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600])),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isValid
                            ? () => Navigator.pop(context, _controller.text.trim())
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreenMain,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: _isValid ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Create',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
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
// ADD MEMBER DIALOG (Renamed)
// ============================================
class _BestPanelAddMemberDialog extends StatefulWidget {
  final String semester;

  const _BestPanelAddMemberDialog({required this.semester});

  @override
  State<_BestPanelAddMemberDialog> createState() =>
      _BestPanelAddMemberDialogState();
}

class _BestPanelAddMemberDialogState extends State<_BestPanelAddMemberDialog> {
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  String? _selectedTeam;
  String? _imageUrl;
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSaving = false;
  List<String> _addedTeams = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAddedTeams();
  }

  Future<void> _loadAddedTeams() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(widget.semester)
          .collection('Informations')
          .get();

      setState(() {
        _addedTeams = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      debugPrint('Error loading teams: $e');
    }
  }

  List<TeamConfig> get _availableTeams {
    return kAllTeams.where((team) => !_addedTeams.contains(team.name)).toList();
  }

  bool get _isValid {
    return _selectedTeam != null &&
        _nameController.text.trim().isNotEmpty &&
        _departmentController.text.trim().isNotEmpty;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
      });

      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'best_panel_members'),
      );

      setState(() {
        _imageUrl = response.secureUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }

  Future<void> _saveMember() async {
    if (!_isValid) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(widget.semester)
          .collection('Informations')
          .doc(_selectedTeam!)
          .set({
        'Name': _nameController.text.trim(),
        'Department': _departmentController.text.trim(),
        'Image': _imageUrl ?? '',
        'Added_At': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${_nameController.text} added successfully!'),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeamConfig = _selectedTeam != null
        ? kAllTeams.firstWhere((t) => t.name == _selectedTeam,
        orElse: () =>
            TeamConfig(name: '', icon: Icons.group, color: kGreenMain))
        : null;

    return Center(
        child: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                // Header
                Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAccentPurple, kAccentPurple.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Best Panel Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            widget.semester,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                      const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Team Selection
                    const Text(
                    'Select Team',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kGreenDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_availableTeams.isEmpty)
              Container(
              padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kAccentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border:
            Border.all(color: kAccentGold.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: kAccentGold),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All teams have been filled for this semester!',
                  style: TextStyle(
                    color: kGreenDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        )
        else
        Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
    color: _selectedTeam != null
    ? selectedTeamConfig!.color
        : Colors.grey[300]!,
    width: _selectedTeam != null ? 2 : 1,
    ),
    ),
    child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
    value: _selectedTeam,
    isExpanded: true,
    hint: const Text('Choose a team'),
    icon: Icon(Icons.arrow_drop_down_rounded,
    color:
    selectedTeamConfig?.color ?? Colors.grey),
    items: _availableTeams.map((team) {
    return DropdownMenuItem<String>(
    value: team.name,
    child: Row(
    children: [
    Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: team.color.withOpacity(0.15),
    borderRadius:
    BorderRadius.circular(10),
    ),
    child: Icon(team.icon,
    color: team.color, size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Text(
    team.name,
    style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    ),
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    );
    }).toList(),
    onChanged: (value) {
    setState(() => _selectedTeam = value);
    },
    ),
    ),
    ),
    const SizedBox(height: 24),

    // Image Upload
    const Text(
    'Profile Photo',
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: kGreenDark,
    ),
    ),
    const SizedBox(height: 12),
    GestureDetector(
    onTap: _isUploading ? null : _pickImage,
    child: Container(
    height: 150,
    width: double.infinity,
    decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: _imageUrl != null
    ? kGreenMain
        : Colors.grey[300]!,
    width: _imageUrl != null ? 2 : 1,
    ),
    ),
    child: _isUploading
    ? Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    const CircularProgressIndicator(
    color: kGreenMain),
    const SizedBox(height: 12),
    Text('Uploading...',
    style:
    TextStyle(color: Colors.grey[600])),
    ],
    )
        : _selectedImage != null
    ? ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Stack(
    fit: StackFit.expand,
    children: [
    Image.file(_selectedImage!,
    fit: BoxFit.cover),
    Positioned(
    top: 8,
    right: 8,
    child: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: [
    BoxShadow(
    color: Colors.black
        .withOpacity(0.2),
    blurRadius: 8,
    ),
    ],
    ),
    child: const Icon(
    Icons.check_circle_rounded,
    color: kGreenMain,
    size: 20),
    ),
    ),
    ],
    ),
    )
        : Column(
    mainAxisAlignment:
    MainAxisAlignment.center,
    children: [
    Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color:
    kGreenLight.withOpacity(0.15),
    shape: BoxShape.circle,
    ),
    child: const Icon(
    Icons
        .add_photo_alternate_rounded,
    color: kGreenMain,
    size: 32),
    ),
    const SizedBox(height: 12),
    Text(
    'Tap to upload photo',
    style: TextStyle(
    color: Colors.grey[600],
    fontWeight: FontWeight.w500,
    ),
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 24),

    // Name Input
    const Text(
    'Member Name',
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: kGreenDark,
    ),
    ),
    const SizedBox(height: 12),
    TextField(
    controller: _nameController,
    textCapitalization: TextCapitalization.words,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
    hintText: 'Enter full name',
    prefixIcon:
    const Icon(Icons.person_rounded, color: kGreenMain),
    filled: true,
    fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
        const BorderSide(color: kGreenMain, width: 2),
      ),
    ),
    ),
                      const SizedBox(height: 20),

                      // Department Input
                      const Text(
                        'Department',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kGreenDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _departmentController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'e.g., Computer Science & Engineering',
                          prefixIcon:
                          const Icon(Icons.school_rounded, color: kGreenMain),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                            const BorderSide(color: kGreenMain, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed:
                              _isSaving ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                              (_isValid && !_isSaving) ? _saveMember : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccentPurple,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                elevation: _isValid ? 4 : 0,
                                shadowColor: kAccentPurple.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add Member',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
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
                    ],
                ),
              ),
          ),
        ),
    );
  }
}

// ============================================
// EDIT MEMBER DIALOG (Renamed)
// ============================================
class _BestPanelEditMemberDialog extends StatefulWidget {
  final String semester;
  final String teamName;
  final Map<String, dynamic> currentData;

  const _BestPanelEditMemberDialog({
    required this.semester,
    required this.teamName,
    required this.currentData,
  });

  @override
  State<_BestPanelEditMemberDialog> createState() =>
      _BestPanelEditMemberDialogState();
}

class _BestPanelEditMemberDialogState extends State<_BestPanelEditMemberDialog> {
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  String? _imageUrl;
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSaving = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentData['Name'] ?? '');
    _departmentController =
        TextEditingController(text: widget.currentData['Department'] ?? '');
    _imageUrl = widget.currentData['Image'];
  }

  bool get _isValid {
    return _nameController.text.trim().isNotEmpty &&
        _departmentController.text.trim().isNotEmpty;
  }

  TeamConfig get _teamConfig {
    return kAllTeams.firstWhere(
          (t) => t.name == widget.teamName,
      orElse: () => TeamConfig(
        name: widget.teamName,
        icon: Icons.group_rounded,
        color: kGreenMain,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
      });

      final cloudinary = CloudinaryPublic('dxyhzgrul', 'austrc-club');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'best_panel_members'),
      );

      setState(() {
        _imageUrl = response.secureUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Image?'),
        content: const Text('Are you sure you want to remove the profile image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _imageUrl = null;
        _selectedImage = null;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_isValid) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Best Panel Members')
          .collection('Semesters')
          .doc(widget.semester)
          .collection('Informations')
          .doc(widget.teamName)
          .update({
        'Name': _nameController.text.trim(),
        'Department': _departmentController.text.trim(),
        'Image': _imageUrl ?? '',
        'Updated_At': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Member updated successfully!'),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = _teamConfig;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [team.color, team.color.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(team.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.teamName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                        const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      const Text(
                        'Profile Photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kGreenDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Current/Selected Image
                          GestureDetector(
                            onTap: _isUploading ? null : _pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _imageUrl != null
                                      ? team.color
                                      : Colors.grey[300]!,
                                  width: _imageUrl != null ? 2 : 1,
                                ),
                              ),
                              child: _isUploading
                                  ? const Center(
                                child: CircularProgressIndicator(
                                  color: kGreenMain,
                                  strokeWidth: 2,
                                ),
                              )
                                  : _selectedImage != null
                                  ? ClipRRect(
                                borderRadius:
                                BorderRadius.circular(18),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : _imageUrl != null &&
                                  _imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                borderRadius:
                                BorderRadius.circular(18),
                                child: CachedNetworkImage(
                                  imageUrl: _imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                  const Center(
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget:
                                      (context, url, error) =>
                                      Icon(
                                        team.icon,
                                        color: team.color,
                                        size: 40,
                                      ),
                                ),
                              )
                                  : Icon(
                                Icons.add_photo_alternate_rounded,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Image Actions
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BestPanelImageActionButton(
                                  icon: Icons.upload_rounded,
                                  label: 'Upload New',
                                  color: team.color,
                                  onTap: _isUploading ? null : _pickImage,
                                ),
                                const SizedBox(height: 8),
                                if (_imageUrl != null && _imageUrl!.isNotEmpty)
                                  _BestPanelImageActionButton(
                                    icon: Icons.delete_outline_rounded,
                                    label: 'Remove',
                                    color: kAccentRed,
                                    onTap: _isUploading ? null : _removeImage,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Name Input
                      const Text(
                        'Member Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kGreenDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Enter full name',
                          prefixIcon:
                          Icon(Icons.person_rounded, color: team.color),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: team.color, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Department Input
                      const Text(
                        'Department',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kGreenDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _departmentController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'e.g., Computer Science & Engineering',
                          prefixIcon:
                          Icon(Icons.school_rounded, color: team.color),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: team.color, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                              (_isValid && !_isSaving) ? _saveChanges : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: team.color,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                elevation: _isValid ? 4 : 0,
                                shadowColor: team.color.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// IMAGE ACTION BUTTON (Renamed)
// ============================================
class _BestPanelImageActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _BestPanelImageActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
// DELETE CONFIRMATION DIALOG (Renamed)
// ============================================
class _BestPanelDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String warning;

  const _BestPanelDeleteDialog({
    required this.title,
    required this.message,
    required this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kAccentRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: kAccentRed,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kGreenDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Warning Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kAccentRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kAccentRed.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: kAccentRed, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }
}