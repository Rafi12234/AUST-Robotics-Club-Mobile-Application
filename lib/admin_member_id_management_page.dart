import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentRed = Color(0xFFEF4444);

// CSV Export Service
class CSVExportService {
  static Future<ExportResult> exportMembersToCSV({
    required List<Map<String, dynamic>> members,
    required BuildContext context,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _ExportLoadingDialog(),
      );

      List<List<dynamic>> csvData = [];
      csvData.add([
        'S/N',
        'Member Number',
        'Name',
        'Department',
        'AUST ID',
        'AUSTRC ID',
        'Institutional Mail'
      ]);

      int serialNumber = 1;
      for (var member in members) {
        csvData.add([
          serialNumber++,
          member['Member_Number'] ?? '',
          member['Name'] ?? '',
          member['Department'] ?? '',
          member['AUST_ID'] ?? '',
          member['AUSTRC_ID'] ?? '',
          member['Edu_Mail'] ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'AUSTRC_Members_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csv);

      if (!await file.exists()) {
        throw Exception('Failed to create file');
      }

      if (context.mounted) Navigator.pop(context);

      return ExportResult(
        success: true,
        filePath: filePath,
        fileName: fileName,
        memberCount: members.length,
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      return ExportResult(success: false, error: e.toString());
    }
  }

  static Future<ShareResult?> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'AUSTRC Members Export',
        text: 'Exported AUSTRC members data in CSV format',
      );
      return result;
    } catch (e) {
      return null;
    }
  }
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? memberCount;
  final String? error;

  ExportResult(
      {required this.success,
      this.filePath,
      this.fileName,
      this.memberCount,
      this.error});
}

class _ExportLoadingDialog extends StatelessWidget {
  const _ExportLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: kGreenLight.withOpacity(0.15),
                    shape: BoxShape.circle),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kGreenMain),
                      strokeWidth: 3),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Exporting Members...',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kGreenDark)),
              const SizedBox(height: 8),
              Text('Preparing CSV file',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminMemberIdManagementPage extends StatefulWidget {
  const AdminMemberIdManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminMemberIdManagementPage> createState() =>
      _AdminMemberIdManagementPageState();
}

class _AdminMemberIdManagementPageState
    extends State<AdminMemberIdManagementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _exportToCSV(List<QueryDocumentSnapshot> memberDocs) async {
    try {
      final members = memberDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final memberNumber =
            int.tryParse(doc.id.replaceAll('Member_', '')) ?? 0;
        return {
          'Member_Number': memberNumber,
          'Name': data['Name'] ?? '',
          'Department': data['Department'] ?? '',
          'AUST_ID': data['AUST_ID'] ?? '',
          'AUSTRC_ID': data['AUSTRC_ID'] ?? '',
          'Edu_Mail': data['Edu_Mail'] ?? '',
        };
      }).toList();

      members.sort((a, b) =>
          (a['Member_Number'] as int).compareTo(b['Member_Number'] as int));

      final result = await CSVExportService.exportMembersToCSV(
          members: members, context: context);

      if (result.success && mounted) {
        _showExportSuccessDialog(result);
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Export failed: ${result.error}'),
              backgroundColor: kAccentRed,
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Export failed: $e'),
              backgroundColor: kAccentRed,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showExportSuccessDialog(ExportResult result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ExportSuccessDialog(
        filePath: result.filePath!,
        fileName: result.fileName!,
        memberCount: result.memberCount!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(),

          // Member List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Data')
                .doc('Student_AUSTRC_ID')
                .collection('Members')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kGreenMain),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: kAccentRed),
                    ),
                  ),
                );
              }

              final memberDocs = snapshot.data?.docs ?? [];
              memberDocs.sort((a, b) {
                final numA = int.tryParse(a.id.replaceAll('Member_', '')) ?? 0;
                final numB = int.tryParse(b.id.replaceAll('Member_', '')) ?? 0;
                return numB
                    .compareTo(numA); // Descending order - latest member first
              });

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Add New Member button at the top (index 0)
                      if (index == 0) {
                        return _AddNewMemberCard(
                          memberCount: memberDocs.length,
                          onAdded: () {},
                        );
                      }

                      // Member cards start from index 1, so use index - 1 for memberDocs
                      final memberDoc = memberDocs[index - 1];
                      final memberNumber = int.tryParse(
                              memberDoc.id.replaceAll('Member_', '')) ??
                          0;
                      final memberData =
                          memberDoc.data() as Map<String, dynamic>;

                      return _MemberCard(
                        memberNumber: memberNumber,
                        austId: memberData['AUST_ID'] ?? '',
                        austrcId: memberData['AUSTRC_ID'] ?? '',
                        eduMail: memberData['Edu_Mail'] ?? '',
                        name: memberData['Name'] ?? '',
                        department: memberData['Department'] ?? '',
                        memberDocId: memberDoc.id,
                        index: index -
                            1, // Adjusted for Add New Member button at top
                      );
                    },
                    childCount: memberDocs.length + 1,
                  ),
                ),
              );
            },
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: kGreenDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Enhanced Export to CSV Button
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('All_Data')
              .doc('Student_AUSTRC_ID')
              .collection('Members')
              .snapshots(),
          builder: (context, snapshot) {
            final hasMembers =
                snapshot.hasData && snapshot.data!.docs.isNotEmpty;
            final memberCount = snapshot.data?.docs.length ?? 0;

            return Padding(
              padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
              child: _EnhancedExportButton(
                onPressed:
                    hasMembers ? () => _exportToCSV(snapshot.data!.docs) : null,
                memberCount: memberCount,
              ),
            );
          },
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGreenDark, kGreenMain, kGreenLight],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
          title: FadeTransition(
            opacity: _headerController,
            child: const Text(
              'Member ID Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          background: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: AnimatedBuilder(
                  animation: _headerController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _headerController.value * math.pi * 2,
                      child: Icon(
                        Icons.badge_outlined,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
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

class _MemberCard extends StatefulWidget {
  final int memberNumber;
  final String austId;
  final String austrcId;
  final String eduMail;
  final String name;
  final String department;
  final String memberDocId;
  final int index;

  const _MemberCard({
    required this.memberNumber,
    required this.austId,
    required this.austrcId,
    required this.eduMail,
    required this.name,
    required this.department,
    required this.memberDocId,
    required this.index,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
          milliseconds:
              150 + (widget.index * 20).clamp(0, 100)), // Faster animation
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: (10 * widget.index).clamp(0, 100)),
        () {
      // Faster staggered animation
      if (mounted) _controller.forward();
    });
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
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kGreenMain.withOpacity(_isHovered ? 0.25 : 0.15),
                        blurRadius: _isHovered ? 20 : 15,
                        offset: Offset(0, _isHovered ? 8 : 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showEditDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // ...existing icon code...
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [kGreenMain, kGreenLight],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: kGreenMain.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.badge_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Member Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Member ${widget.memberNumber}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: kGreenDark,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      if (widget.name.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '• ${widget.name}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  kGreenMain.withOpacity(0.8),
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kGreenLight.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kGreenLight.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AUST ID: ${widget.austId}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: kGreenDark.withOpacity(0.8),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'AUSTRC ID: ${widget.austrcId}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: kGreenDark.withOpacity(0.8),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        if (widget.department.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            'Dept: ${widget.department}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  kGreenDark.withOpacity(0.8),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Buttons
                            Row(
                              children: [
                                _ActionButton(
                                  icon: Icons.edit_rounded,
                                  color: kGreenMain,
                                  onTap: () => _showEditDialog(context),
                                ),
                                const SizedBox(width: 8),
                                _ActionButton(
                                  icon: Icons.delete_rounded,
                                  color: kAccentRed,
                                  onTap: () => _showDeleteDialog(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final austIdController = TextEditingController(text: widget.austId);
    final austrcIdController = TextEditingController(text: widget.austrcId);
    final eduMailController = TextEditingController(text: widget.eduMail);
    final nameController = TextEditingController(text: widget.name);
    final departmentController = TextEditingController(text: widget.department);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFB)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ...existing header...
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kGreenMain, kGreenLight],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kGreenMain.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Edit Member Info',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kGreenDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member ${widget.memberNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kGreenDark.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    'AUST ID',
                    austIdController,
                    Icons.badge_outlined,
                    'Enter AUST ID',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'AUSTRC ID',
                    austrcIdController,
                    Icons.badge_outlined,
                    'Enter AUSTRC ID',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Institutional Mail',
                    eduMailController,
                    Icons.email_outlined,
                    'Enter institutional email',
                    isEmail: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Name',
                    nameController,
                    Icons.person_outline,
                    'Enter member name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Department',
                    departmentController,
                    Icons.school_outlined,
                    'Enter department (e.g., CSE, EEE)',
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: kGreenMain.withOpacity(0.3),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: kGreenMain,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newAustId = austIdController.text.trim();
                            final newAustrcId = austrcIdController.text.trim();
                            final newEduMail = eduMailController.text.trim();
                            final newName = nameController.text.trim();
                            final newDepartment =
                                departmentController.text.trim();

                            if (newAustId.isEmpty ||
                                newAustrcId.isEmpty ||
                                newEduMail.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'AUST ID, AUSTRC ID, and Email are required'),
                                  backgroundColor: kAccentRed,
                                ),
                              );
                              return;
                            }

                            try {
                              await FirebaseFirestore.instance
                                  .collection('All_Data')
                                  .doc('Student_AUSTRC_ID')
                                  .collection('Members')
                                  .doc(widget.memberDocId)
                                  .update({
                                'AUST_ID': newAustId,
                                'AUSTRC_ID': newAustrcId,
                                'Edu_Mail': newEduMail,
                                'Name': newName,
                                'Department': newDepartment,
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Member ${widget.memberNumber} updated!',
                                    ),
                                    backgroundColor: kGreenMain,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: kAccentRed,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreenMain,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFB)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: kAccentRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kAccentRed.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delete Member?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: kGreenDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete Member ${widget.memberNumber}?\nThis action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kGreenDark.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: kGreenMain.withOpacity(0.3),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: kGreenMain,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('All_Data')
                                .doc('Student_AUSTRC_ID')
                                .collection('Members')
                                .doc(widget.memberDocId)
                                .delete();

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Member ${widget.memberNumber} deleted!',
                                  ),
                                  backgroundColor: kAccentRed,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: kAccentRed,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kGreenDark.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kGreenMain.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kGreenDark,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: kGreenMain),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 20),
        ),
      ),
    );
  }
}

class _AddNewMemberCard extends StatefulWidget {
  final int memberCount;
  final VoidCallback onAdded;

  const _AddNewMemberCard({
    required this.memberCount,
    required this.onAdded,
  });

  @override
  State<_AddNewMemberCard> createState() => _AddNewMemberCardState();
}

class _AddNewMemberCardState extends State<_AddNewMemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isHovered = false;

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kGreenMain.withOpacity(0.1),
                  kGreenLight.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: kGreenMain.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain.withOpacity(_isHovered ? 0.2 : 0.1),
                  blurRadius: _isHovered ? 20 : 15,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showAddDialog(context),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  kGreenMain.withOpacity(
                                      0.8 + _pulseController.value * 0.2),
                                  kGreenLight.withOpacity(
                                      0.8 + _pulseController.value * 0.2),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kGreenMain.withOpacity(
                                      0.3 + _pulseController.value * 0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Member',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: kGreenDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to add a new AUSTRC member',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kGreenMain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final austIdController = TextEditingController();
    final austrcIdController = TextEditingController();
    final eduMailController = TextEditingController();
    final nameController = TextEditingController();
    final departmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFB)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kGreenMain, kGreenLight],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kGreenMain.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Add New Member',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kGreenDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member ${widget.memberCount + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kGreenDark.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAddTextField(
                    'AUST ID',
                    austIdController,
                    Icons.badge_outlined,
                    'Enter AUST ID',
                  ),
                  const SizedBox(height: 16),
                  _buildAddTextField(
                    'AUSTRC ID',
                    austrcIdController,
                    Icons.badge_outlined,
                    'Enter AUSTRC ID',
                  ),
                  const SizedBox(height: 16),
                  _buildAddTextField(
                    'Institutional Mail',
                    eduMailController,
                    Icons.email_outlined,
                    'Enter institutional email',
                    isEmail: true,
                  ),
                  const SizedBox(height: 16),
                  _buildAddTextField(
                    'Name',
                    nameController,
                    Icons.person_outline,
                    'Enter member name',
                  ),
                  const SizedBox(height: 16),
                  _buildAddTextField(
                    'Department',
                    departmentController,
                    Icons.school_outlined,
                    'Enter department (e.g., CSE, EEE)',
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: kGreenMain.withOpacity(0.3),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: kGreenMain,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newAustId = austIdController.text.trim();
                            final newAustrcId = austrcIdController.text.trim();
                            final newEduMail = eduMailController.text.trim();
                            final newName = nameController.text.trim();
                            final newDepartment =
                                departmentController.text.trim();

                            if (newAustId.isEmpty ||
                                newAustrcId.isEmpty ||
                                newEduMail.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'AUST ID, AUSTRC ID, and Email are required'),
                                  backgroundColor: kAccentRed,
                                ),
                              );
                              return;
                            }

                            try {
                              final nextMemberNumber = widget.memberCount + 1;
                              await FirebaseFirestore.instance
                                  .collection('All_Data')
                                  .doc('Student_AUSTRC_ID')
                                  .collection('Members')
                                  .doc('Member_$nextMemberNumber')
                                  .set({
                                'AUST_ID': newAustId,
                                'AUSTRC_ID': newAustrcId,
                                'Edu_Mail': newEduMail,
                                'Name': newName,
                                'Department': newDepartment,
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Member $nextMemberNumber added!'),
                                    backgroundColor: kGreenMain,
                                  ),
                                );
                              }
                              widget.onAdded();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: kAccentRed,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreenMain,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

  Widget _buildAddTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kGreenDark.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kGreenMain.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            autofocus: label == 'AUST ID',
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kGreenDark,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: kGreenMain),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced Export Button Widget
class _EnhancedExportButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final int memberCount;

  const _EnhancedExportButton({
    required this.onPressed,
    required this.memberCount,
  });

  @override
  State<_EnhancedExportButton> createState() => _EnhancedExportButtonState();
}

class _EnhancedExportButtonState extends State<_EnhancedExportButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && isEnabled ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                        colors: _isHovered
                            ? [kGreenLight, kGreenMain]
                            : [kGreenMain, kGreenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEnabled ? null : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isEnabled && _isHovered
                    ? [
                        BoxShadow(
                          color: kGreenMain.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 1,
                        ),
                      ]
                    : isEnabled
                        ? [
                            BoxShadow(
                              color: kGreenMain.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                border: Border.all(
                  color: isEnabled
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isEnabled ? _scaleAnimation.value : 1.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse effect
                            if (isEnabled)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                        _pulseAnimation.value * 0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                            // Main icon
                            Icon(
                              Icons.file_download_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  // Text
                  Text(
                    'Export as CSV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Export Success Dialog
class _ExportSuccessDialog extends StatefulWidget {
  final String filePath;
  final String fileName;
  final int memberCount;

  const _ExportSuccessDialog({
    required this.filePath,
    required this.fileName,
    required this.memberCount,
  });

  @override
  State<_ExportSuccessDialog> createState() => _ExportSuccessDialogState();
}

class _ExportSuccessDialogState extends State<_ExportSuccessDialog> {
  bool _isSharing = false;

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final result = await CSVExportService.shareFile(widget.filePath);
      if (mounted) {
        setState(() => _isSharing = false);
        if (result != null) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSharing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing: $e'), backgroundColor: kAccentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        kGreenMain.withOpacity(0.15),
                        kGreenLight.withOpacity(0.15)
                      ]),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                          gradient:
                              LinearGradient(colors: [kGreenMain, kGreenLight]),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 40),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Export Successful!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kGreenDark)),
            const SizedBox(height: 8),
            Text('${widget.memberCount} members exported',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGreenLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGreenLight.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: kGreenMain.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.description_rounded,
                        color: kGreenMain, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.fileName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kGreenDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('CSV File • Ready to share',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGreenDark,
                      side: BorderSide(
                          color: kGreenMain.withOpacity(0.3), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _handleShare,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white)))
                        : const Icon(Icons.share_rounded, size: 20),
                    label: Text(_isSharing ? 'Sharing...' : 'Share File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
