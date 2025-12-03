import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ============================================
// THEME COLORS
// ============================================
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentRed = Color(0xFFEF4444);
const kAccentBlue = Color(0xFF3B82F6);
const kAccentPurple = Color(0xFF6366F1);

// ============================================
// CSV EXPORT SERVICE - FIXED
// ============================================
class CSVExportService {
  static Future<ExportResult> exportMembersToCSV({
    required String semesterName,
    required List<Map<String, dynamic>> members,
    required BuildContext context,
  }) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _ExportLoadingDialog(),
      );

      // Create CSV data
      List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'S/N',
        'Name',
        'Department',
        'Edu Mail',
        'Personal Email',
        'Current Semester',
        'Semester',
        'Phone Number',
        'Payment By',
        'Transaction ID',
      ]);

      // Add member data rows
      int serialNumber = 1;
      for (var member in members) {
        csvData.add([
          serialNumber++,
          member['Name'] ?? '',
          member['Department'] ?? '',
          member['Edu_Mail'] ?? '',
          member['Personal_Email'] ?? '',
          member['Current_Semester'] ?? '',
          member['Semester'] ?? '',
          member['Phone_Number'] ?? '',
          member['Payment_By'] ?? '',
          member['Transaction_ID'] ?? '',
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Get application documents directory (works on both Android & iOS)
      final directory = await getApplicationDocumentsDirectory();

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedSemester =
      semesterName.replaceAll(RegExp(r'[^\w\s]'), '_').replaceAll(' ', '_');
      final fileName = '${sanitizedSemester}_Members_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csv);

      // Verify file exists
      if (!await file.exists()) {
        throw Exception('Failed to create file');
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      return ExportResult(
        success: true,
        filePath: filePath,
        fileName: fileName,
        memberCount: members.length,
      );
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
      }

      return ExportResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Share the exported file - FIXED VERSION
  static Future<ShareResult?> shareFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        debugPrint('File does not exist: $filePath');
        return null;
      }

      // Get file size for debugging
      final fileSize = await file.length();
      debugPrint('Sharing file: $filePath (Size: $fileSize bytes)');

      // Use ShareResult to get feedback
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Members Export',
        text: 'Exported members data in CSV format',
      );

      debugPrint('Share result: ${result.status}');
      return result;
    } catch (e) {
      debugPrint('Error sharing file: $e');
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

  ExportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.memberCount,
    this.error,
  });
}

// ============================================
// EXPORT LOADING DIALOG
// ============================================
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
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGreenLight.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: kGreenMain,
                    strokeWidth: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Exporting Data...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kGreenDark,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generating CSV file',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
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
// EXPORT SUCCESS DIALOG - FIXED
// ============================================
class ExportSuccessDialog extends StatefulWidget {
  final String filePath;
  final String fileName;
  final int memberCount;
  final String semesterName;

  const ExportSuccessDialog({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.memberCount,
    required this.semesterName,
  });

  @override
  State<ExportSuccessDialog> createState() => _ExportSuccessDialogState();
}

class _ExportSuccessDialogState extends State<ExportSuccessDialog> {
  bool _isSharing = false;

  Future<void> _handleShare() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // Don't close the dialog yet - let share complete first
      final result = await CSVExportService.shareFile(widget.filePath);

      if (mounted) {
        setState(() => _isSharing = false);

        // Only close dialog after share sheet is dismissed
        if (result != null) {
          // Small delay to ensure share sheet is fully dismissed
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSharing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: kAccentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
            children: [
              // Success Icon
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
                        gradient: LinearGradient(
                          colors: [
                            kGreenMain.withOpacity(0.15),
                            kGreenLight.withOpacity(0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kGreenMain, kGreenLight],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Export Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kGreenDark,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '${widget.memberCount} members exported from ${widget.semesterName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // File Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAccentBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kAccentBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kAccentBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: kAccentBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fileName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kGreenDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CSV File Ready',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSharing ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSharing ? null : _handleShare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenMain,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: kGreenMain.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: kGreenMain.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSharing
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Share / Save',
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

// ============================================
// ADMIN MEMBERSHIP MANAGEMENT PAGE
// ============================================
class AdminMembershipManagementPage extends StatefulWidget {
  const AdminMembershipManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminMembershipManagementPage> createState() =>
      _AdminMembershipManagementPageState();
}

class _AdminMembershipManagementPageState
    extends State<AdminMembershipManagementPage> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _FormControlSection(
              contentController: _contentController,
            ),
          ),
          SliverToBoxAdapter(
            child: _ViewApplicantsButton(
              contentController: _contentController,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
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
          titlePadding: const EdgeInsets.only(left: 60, bottom: 16, right: 16),
          title: FadeTransition(
            opacity: _headerController,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Club Recruitment Control',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
// FORM CONTROL SECTION
// ============================================
class _FormControlSection extends StatefulWidget {
  final AnimationController contentController;

  const _FormControlSection({required this.contentController});

  @override
  State<_FormControlSection> createState() => _FormControlSectionState();
}

class _FormControlSectionState extends State<_FormControlSection> {
  final DocumentReference _formSettingsDoc = FirebaseFirestore.instance
      .collection('New_Member_Recruitment')
      .doc('Form ON_OFF and Payment Number');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _formSettingsDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: kGreenMain),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final isFormEnabled = data['Access'] == true;
        final bkashNumber = data['Bkash'] ?? '';
        final nagadNumber = data['Nagad'] ?? '';
        final message = data['Message'] ?? '';

        return FadeTransition(
          opacity: widget.contentController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: widget.contentController,
              curve: Curves.easeOutCubic,
            )),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [kGreenMain, kGreenLight],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recruitment Controls',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kGreenDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FormStatusCard(
                    isEnabled: isFormEnabled,
                    onToggle: (value) => _updateFormAccess(value),
                  ),
                  const SizedBox(height: 16),
                  _PaymentNumbersCard(
                    bkashNumber: bkashNumber,
                    nagadNumber: nagadNumber,
                    onBkashUpdate: (value) => _updateField('Bkash', value),
                    onNagadUpdate: (value) => _updateField('Nagad', value),
                  ),
                  const SizedBox(height: 16),
                  _OfflineMessageCard(
                    message: message,
                    onUpdate: (value) => _updateField('Message', value),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateFormAccess(bool value) async {
    try {
      await _formSettingsDoc.update({'Access': value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  value
                      ? 'Recruitment Form Enabled!'
                      : 'Recruitment Form Disabled!',
                ),
              ],
            ),
            backgroundColor: value ? kGreenMain : kAccentRed,
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
            content: Text('Error updating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateField(String field, String value) async {
    try {
      await _formSettingsDoc.update({field: value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('$field updated successfully!'),
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
            content: Text('Error updating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================
// VIEW APPLICANTS BUTTON SECTION
// ============================================
class _ViewApplicantsButton extends StatefulWidget {
  final AnimationController contentController;

  const _ViewApplicantsButton({required this.contentController});

  @override
  State<_ViewApplicantsButton> createState() => _ViewApplicantsButtonState();
}

class _ViewApplicantsButtonState extends State<_ViewApplicantsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.contentController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: widget.contentController,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [kAccentPurple, kAccentBlue],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Applicants Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kGreenDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AdminMembershipApplicantsPage(),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.02 : 1.0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0C1C0C),
                          Color(0xFF1A3A1A),
                          Color(0xFF234D23),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All Applicants',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Review and manage applications',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
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
// FORM STATUS CARD
// ============================================
class _FormStatusCard extends StatefulWidget {
  final bool isEnabled;
  final Function(bool) onToggle;

  const _FormStatusCard({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  State<_FormStatusCard> createState() => _FormStatusCardState();
}

class _FormStatusCardState extends State<_FormStatusCard>
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isEnabled
              ? [kGreenDark, kGreenMain]
              : [const Color(0xFF374151), const Color(0xFF4B5563)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
            (widget.isEnabled ? kGreenMain : Colors.grey).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: widget.isEnabled
                          ? [
                        BoxShadow(
                          color: kAccentGold
                              .withOpacity(0.5 * _pulseController.value),
                          blurRadius: 20 * _pulseController.value,
                          spreadRadius: 5 * _pulseController.value,
                        ),
                      ]
                          : null,
                    ),
                    child: Icon(
                      widget.isEnabled
                          ? Icons.how_to_reg_rounded
                          : Icons.person_off_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recruitment Status',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: widget.isEnabled ? kAccentGold : kAccentRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (widget.isEnabled
                                    ? kAccentGold
                                    : kAccentRed)
                                    .withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isEnabled ? 'FORM ACTIVE' : 'FORM INACTIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _AnimatedToggleSwitch(
            isEnabled: widget.isEnabled,
            onToggle: widget.onToggle,
          ),
        ],
      ),
    );
  }
}

// ============================================
// ANIMATED TOGGLE SWITCH
// ============================================
class _AnimatedToggleSwitch extends StatefulWidget {
  final bool isEnabled;
  final Function(bool) onToggle;

  const _AnimatedToggleSwitch({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  State<_AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<_AnimatedToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isToggling = false;
  double _dragPosition = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.isEnabled ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(_AnimatedToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled && !_isDragging) {
      if (widget.isEnabled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isToggling) return;
    _toggleState(!widget.isEnabled);
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragPosition = _controller.value;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double containerWidth) {
    if (_isToggling) return;
    setState(() {
      _dragPosition += details.primaryDelta! / containerWidth;
      _dragPosition = _dragPosition.clamp(0.0, 1.0);
      _controller.value = _dragPosition;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    final velocity = details.primaryVelocity ?? 0;
    final shouldEnable =
    velocity > 0 ? _dragPosition > 0.3 : _dragPosition > 0.7;
    _toggleState(shouldEnable);
  }

  Future<void> _toggleState(bool newState) async {
    if (_isToggling || newState == widget.isEnabled) {
      if (widget.isEnabled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      return;
    }

    setState(() => _isToggling = true);

    if (newState) {
      await _controller.forward();
    } else {
      await _controller.reverse();
    }

    widget.onToggle(newState);

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final thumbWidth = containerWidth / 2 - 16;

        return GestureDetector(
          onTap: _handleTap,
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, containerWidth),
          onHorizontalDragEnd: _handleDragEnd,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final isEnabled = _controller.value > 0.5;

              return Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: isEnabled ? 0.4 : 0.9,
                                duration: const Duration(milliseconds: 200),
                                child: const Text(
                                  'DISABLE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: isEnabled ? 0.9 : 0.4,
                                duration: const Duration(milliseconds: 200),
                                child: const Text(
                                  'ENABLE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 8 +
                          (_controller.value *
                              (containerWidth - thumbWidth - 16)),
                      top: 8,
                      bottom: 8,
                      child: AnimatedContainer(
                        duration: _isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: thumbWidth,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isEnabled
                                ? [kAccentGold, const Color(0xFFFF9500)]
                                : [
                              const Color(0xFF9CA3AF),
                              const Color(0xFF6B7280)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                              color: (isEnabled ? kAccentGold : Colors.grey)
                                  .withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isToggling
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEnabled
                                    ? Icons.power_settings_new_rounded
                                    : Icons.power_off_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEnabled ? 'ON' : 'OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================
// PAYMENT NUMBERS CARD
// ============================================
class _PaymentNumbersCard extends StatelessWidget {
  final String bkashNumber;
  final String nagadNumber;
  final Function(String) onBkashUpdate;
  final Function(String) onNagadUpdate;

  const _PaymentNumbersCard({
    required this.bkashNumber,
    required this.nagadNumber,
    required this.onBkashUpdate,
    required this.onNagadUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kGreenMain.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kAccentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: kAccentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Numbers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kGreenDark,
                      ),
                    ),
                    Text(
                      'Mobile banking numbers for applicants',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PaymentNumberField(
            label: 'Bkash',
            value: bkashNumber,
            color: const Color(0xFFE2136E),
            icon: Icons.phone_android_rounded,
            onUpdate: onBkashUpdate,
          ),
          const SizedBox(height: 16),
          _PaymentNumberField(
            label: 'Nagad',
            value: nagadNumber,
            color: const Color(0xFFFF6B00),
            icon: Icons.phone_android_rounded,
            onUpdate: onNagadUpdate,
          ),
        ],
      ),
    );
  }
}

class _PaymentNumberField extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final Function(String) onUpdate;

  const _PaymentNumberField({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.onUpdate,
  });

  @override
  State<_PaymentNumberField> createState() => _PaymentNumberFieldState();
}

class _PaymentNumberFieldState extends State<_PaymentNumberField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_PaymentNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing ? widget.color : widget.color.withOpacity(0.2),
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
                TextField(
                  controller: _controller,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check_circle, color: kGreenMain),
              onPressed: () {
                widget.onUpdate(_controller.text.trim());
                setState(() => _isEditing = false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: kAccentRed),
              onPressed: () {
                _controller.text = widget.value;
                setState(() => _isEditing = false);
              },
            ),
          ] else
            IconButton(
              icon: Icon(Icons.edit_rounded, color: widget.color),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
    );
  }
}

// ============================================
// OFFLINE MESSAGE CARD
// ============================================
class _OfflineMessageCard extends StatefulWidget {
  final String message;
  final Function(String) onUpdate;

  const _OfflineMessageCard({
    required this.message,
    required this.onUpdate,
  });

  @override
  State<_OfflineMessageCard> createState() => _OfflineMessageCardState();
}

class _OfflineMessageCardState extends State<_OfflineMessageCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message);
  }

  @override
  void didUpdateWidget(_OfflineMessageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message && !_isEditing) {
      _controller.text = widget.message;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kGreenMain.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kAccentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.message_rounded,
                  color: kAccentRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kGreenDark,
                      ),
                    ),
                    Text(
                      'Shown when recruitment is disabled',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEditing
                    ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle,
                          color: kGreenMain),
                      onPressed: () {
                        widget.onUpdate(_controller.text.trim());
                        setState(() => _isEditing = false);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: kAccentRed),
                      onPressed: () {
                        _controller.text = widget.message;
                        setState(() => _isEditing = false);
                      },
                    ),
                  ],
                )
                    : IconButton(
                  icon:
                  const Icon(Icons.edit_rounded, color: kGreenMain),
                  onPressed: () => setState(() => _isEditing = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
              _isEditing ? Colors.grey[50] : kAccentRed.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isEditing ? kGreenMain : kAccentRed.withOpacity(0.2),
                width: _isEditing ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              enabled: _isEditing,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14,
                color: _isEditing ? kGreenDark : Colors.grey[700],
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Enter message to show when form is disabled...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// ADMIN MEMBERSHIP APPLICANTS PAGE
// ============================================
class AdminMembershipApplicantsPage extends StatefulWidget {
  const AdminMembershipApplicantsPage({Key? key}) : super(key: key);

  @override
  State<AdminMembershipApplicantsPage> createState() =>
      _AdminMembershipApplicantsPageState();
}

class _AdminMembershipApplicantsPageState
    extends State<AdminMembershipApplicantsPage> with TickerProviderStateMixin {
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
          .collection('New_Members_Informations')
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
                  : _buildMembersList(),
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
          : _BackToSemestersFAB(
        controller: _fabController,
        onTap: () {
          setState(() => _selectedSemester = null);
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
                          'Registered Members',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _selectedSemester == null
                              ? 'Select a semester to view members'
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
                if (_selectedSemester != null)
                  _ExportButton(semesterName: _selectedSemester!),
              ],
            ),
          ),
          if (_selectedSemester != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('New_Members_Informations')
                    .doc(_selectedSemester!)
                    .collection('Members')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$count Member${count != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
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
                    color: kGreenLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today_rounded,
                      size: 80, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Semesters Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kGreenDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to create your first semester',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Select Semester',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
            const Spacer(),
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
        const SizedBox(height: 16),
        ..._availableSemesters.asMap().entries.map((entry) {
          final index = entry.key;
          final semester = entry.value;
          return _SemesterTile(
            semester: semester,
            index: index,
            onTap: () => setState(() => _selectedSemester = semester),
            onDelete: () => _deleteSemester(semester),
            onExport: () => _exportSemesterData(semester),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  Future<void> _exportSemesterData(String semester) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(semester)
          .collection('Members')
          .orderBy('Member_Number', descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('No members found in $semester'),
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

      final members = snapshot.docs.map((doc) => doc.data()).toList();

      final result = await CSVExportService.exportMembersToCSV(
        semesterName: semester,
        members: members,
        context: context,
      );

      if (result.success && mounted) {
        _showExportSuccessDialog(result, semester);
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${result.error}'),
            backgroundColor: kAccentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: kAccentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showExportSuccessDialog(ExportResult result, String semester) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExportSuccessDialog(
        filePath: result.filePath!,
        fileName: result.fileName!,
        memberCount: result.memberCount!,
        semesterName: semester,
      ),
    );
  }

  Future<void> _deleteSemester(String semester) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteSemesterDialog(semester: semester),
    );

    if (confirm == true) {
      try {
        // Delete all members in the subcollection first
        final membersSnapshot = await FirebaseFirestore.instance
            .collection('New_Members_Informations')
            .doc(semester)
            .collection('Members')
            .get();

        for (var doc in membersSnapshot.docs) {
          await doc.reference.delete();
        }

        // Then delete the semester document
        await FirebaseFirestore.instance
            .collection('New_Members_Informations')
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
                  Text('$semester deleted successfully'),
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
              content: Text('Error deleting semester: $e'),
              backgroundColor: kAccentRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildMembersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(_selectedSemester!)
          .collection('Members')
          .orderBy('Member_Number', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: kGreenMain, strokeWidth: 3),
                SizedBox(height: 16),
                Text('Loading members...',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading members',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kAccentRed),
                  ),
                ],
              ),
            ),
          );
        }

        final members = snapshot.data?.docs ?? [];

        if (members.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kGreenLight.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_search_rounded,
                        size: 64, color: kGreenMain),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Members for $_selectedSemester',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kGreenDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registered members will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final data = members[index].data() as Map<String, dynamic>;
            data['documentId'] = members[index].id;
            return _MemberCard(data: data, index: index);
          },
        );
      },
    );
  }
}

// ============================================
// EXPORT BUTTON (Header)
// ============================================
class _ExportButton extends StatefulWidget {
  final String semesterName;

  const _ExportButton({required this.semesterName});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);
    _controller.repeat();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(widget.semesterName)
          .collection('Members')
          .orderBy('Member_Number', descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('No members found in ${widget.semesterName}'),
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

      final members = snapshot.docs.map((doc) => doc.data()).toList();

      final result = await CSVExportService.exportMembersToCSV(
        semesterName: widget.semesterName,
        members: members,
        context: context,
      );

      if (result.success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => ExportSuccessDialog(
            filePath: result.filePath!,
            fileName: result.fileName!,
            memberCount: result.memberCount!,
            semesterName: widget.semesterName,
          ),
        );
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${result.error}'),
            backgroundColor: kAccentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: kAccentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleExport,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExporting)
                RotationTransition(
                  turns: _controller,
                  child: const Icon(
                    Icons.sync_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                )
              else
                const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              const SizedBox(width: 6),
              Text(
                _isExporting ? 'Exporting...' : 'Export CSV',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
// ADD SEMESTER FAB
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
        CurvedAnimation(
          parent: widget.controller,
          curve: Curves.elasticOut,
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kGreenMain
                      .withOpacity(0.3 + (_pulseController.value * 0.2)),
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
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Add Semester',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSemesterDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _AddSemesterDialog(),
    );

    if (result != null && result.isNotEmpty) {
      await _createSemester(result);
      widget.onSemesterCreated();
    }
  }

  Future<void> _createSemester(String semesterName) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
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
          .collection('New_Members_Informations')
          .doc(semesterName)
          .set({
        'Created_At': FieldValue.serverTimestamp(),
        'Semester_Name': semesterName,
        'Total_Members': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"$semesterName" created successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: kGreenMain,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating semester: $e'),
            backgroundColor: kAccentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================
// ADD SEMESTER DIALOG
// ============================================
class _AddSemesterDialog extends StatefulWidget {
  const _AddSemesterDialog();

  @override
  State<_AddSemesterDialog> createState() => _AddSemesterDialogState();
}

class _AddSemesterDialogState extends State<_AddSemesterDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedPreset;
  bool _isValid = false;

  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Spring',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF10B981)
    },
    {
      'name': 'Fall',
      'icon': Icons.park_rounded,
      'color': const Color(0xFFFF6B35)
    },
    {
      'name': 'Summer',
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFBBF24)
    },
    {'name': 'Winter', 'icon': Icons.ac_unit_rounded, 'color': kAccentBlue},
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kGreenMain, kGreenLight],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create New Semester',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kGreenDark,
                          ),
                        ),
                        Text(
                          'Add a semester for member registration',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Select Presets
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
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  final isSelected = _selectedPreset == preset['name'];
                  return InkWell(
                    onTap: () => _selectPreset(preset['name']),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (preset['color'] as Color).withOpacity(0.15)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? preset['color'] as Color
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            preset['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? preset['color'] as Color
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            preset['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? preset['color'] as Color
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),

              // Custom Input
              const Text(
                'Custom Semester Name',
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
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.edit_calendar_rounded,
                    color: kGreenMain,
                  ),
                  suffixIcon: _isValid
                      ? const Icon(
                    Icons.check_circle_rounded,
                    color: kGreenMain,
                  )
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                onSubmitted: (value) {
                  if (_isValid) {
                    Navigator.pop(context, _controller.text.trim());
                  }
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isValid
                          ? () =>
                          Navigator.pop(context, _controller.text.trim())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenMain,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: _isValid ? 4 : 0,
                        shadowColor: kGreenMain.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: _isValid ? Colors.white : Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Create Semester',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _isValid ? Colors.white : Colors.grey[500],
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

// ============================================
// BACK TO SEMESTERS FAB
// ============================================
class _BackToSemestersFAB extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onTap;

  const _BackToSemestersFAB({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      ),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        backgroundColor: kAccentPurple,
        elevation: 8,
        icon: const Icon(Icons.list_rounded, size: 22),
        label: const Text(
          'All Semesters',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ============================================
// DELETE SEMESTER DIALOG
// ============================================
class _DeleteSemesterDialog extends StatelessWidget {
  final String semester;

  const _DeleteSemesterDialog({required this.semester});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccentRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: kAccentRed,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Delete Semester?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kGreenDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Are you sure you want to delete "$semester"?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccentRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAccentRed.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: kAccentRed, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This will delete all member data permanently!',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// SEMESTER TILE
// ============================================
class _SemesterTile extends StatefulWidget {
  final String semester;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _SemesterTile({
    required this.semester,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onExport,
  });

  @override
  State<_SemesterTile> createState() => _SemesterTileState();
}

class _SemesterTileState extends State<_SemesterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExporting = false;

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

  IconData _getSemesterIcon(String semester) {
    final s = semester.toLowerCase();
    if (s.contains('spring')) return Icons.eco_rounded;
    if (s.contains('fall')) return Icons.park_rounded;
    if (s.contains('summer')) return Icons.wb_sunny_rounded;
    if (s.contains('winter')) return Icons.ac_unit_rounded;
    return Icons.calendar_month_rounded;
  }

  Color _getSemesterColor(String semester) {
    final s = semester.toLowerCase();
    if (s.contains('spring')) return const Color(0xFF10B981);
    if (s.contains('fall')) return const Color(0xFFFF6B35);
    if (s.contains('summer')) return const Color(0xFFFBBF24);
    if (s.contains('winter')) return kAccentBlue;
    return kAccentPurple;
  }

  void _handleExport() {
    setState(() => _isExporting = true);
    widget.onExport();
    // Reset after some time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    });
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
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(_getSemesterIcon(widget.semester),
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.semester,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kGreenDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<int>(
                                future: _getMemberCount(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data ?? 0;
                                  return Text(
                                    '$count registered member${count != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: color, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons Row
                    Row(
                      children: [
                        // Export Button
                        Expanded(
                          child: _SemesterActionButton(
                            icon: _isExporting
                                ? Icons.hourglass_top_rounded
                                : Icons.download_rounded,
                            label: _isExporting ? 'Exporting...' : 'Export CSV',
                            color: kAccentBlue,
                            isLoading: _isExporting,
                            onTap: _isExporting ? () {} : _handleExport,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        Expanded(
                          child: _SemesterActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            color: kAccentRed,
                            onTap: widget.onDelete,
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
    );
  }

  Future<int> _getMemberCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('New_Members_Informations')
          .doc(widget.semester)
          .collection('Members')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

// ============================================
// SEMESTER ACTION BUTTON
// ============================================
class _SemesterActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _SemesterActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(isLoading ? 0.05 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isLoading ? 0.2 : 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(isLoading ? 0.6 : 1.0),
                  ),
                  overflow: TextOverflow.ellipsis,
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
// MEMBER CARD
// ============================================
class _MemberCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;

  const _MemberCard({required this.data, required this.index});

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
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
    final name = widget.data['Name'] ?? 'Unknown';
    final department = widget.data['Department'] ?? 'N/A';
    final semester = widget.data['Semester'] ?? '';
    final documentId = widget.data['documentId'] ?? '';

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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGreenMain.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kGreenMain, kGreenLight],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kGreenDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (documentId.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kAccentGold.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: kAccentGold, width: 1),
                                      ),
                                      child: Text(
                                        documentId,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: kAccentGold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Flexible(
                                    child: Text(
                                      department,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (semester.isNotEmpty) ...[
                                    const Text(' • ',
                                        style: TextStyle(color: Colors.grey)),
                                    Text(
                                      'Sem $semester',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kGreenMain,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kGreenLight.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: kGreenMain, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedContent(),
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

  Widget _buildExpandedContent() {
    final eduMail = widget.data['Edu_Mail'] ?? '';
    final personalEmail = widget.data['Personal_Email'] ?? '';
    final phone = widget.data['Phone_Number'] ?? '';
    final currentSemester = widget.data['Current_Semester'] ?? '';
    final paymentBy = widget.data['Payment_By'] ?? '';
    final transactionId = widget.data['Transaction_ID'] ?? '';
    final imageDriveLink = widget.data['Image_Drive_Link'] ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (currentSemester.isNotEmpty)
            _InfoItem(
              icon: Icons.event_rounded,
              label: 'Registered For',
              value: currentSemester,
              color: kAccentPurple,
            ),
          if (eduMail.isNotEmpty)
            _InfoItem(
              icon: Icons.email_rounded,
              label: 'Edu Email',
              value: eduMail,
              color: kAccentBlue,
              canCopy: true,
            ),
          if (personalEmail.isNotEmpty)
            _InfoItem(
              icon: Icons.alternate_email_rounded,
              label: 'Personal Email',
              value: personalEmail,
              color: Colors.purple,
              canCopy: true,
            ),
          if (phone.isNotEmpty)
            _InfoItem(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: phone,
              color: kGreenMain,
              canCopy: true,
            ),
          if (paymentBy.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _InfoItem(
              icon: Icons.payment_rounded,
              label: 'Payment',
              value: paymentBy,
              color: paymentBy.toLowerCase() == 'bkash'
                  ? const Color(0xFFE2136E)
                  : const Color(0xFFFF6B00),
            ),
          ],
          if (transactionId.isNotEmpty)
            _InfoItem(
              icon: Icons.receipt_long_rounded,
              label: 'Transaction ID',
              value: transactionId,
              color: kAccentGold,
              canCopy: true,
              isHighlighted: true,
            ),
          if (imageDriveLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ImageLinkWidget(link: imageDriveLink),
          ],
        ],
      ),
    );
  }
}

// ============================================
// INFO ITEM
// ============================================
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool canCopy;
  final bool isHighlighted;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.canCopy = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    isHighlighted ? FontWeight.w700 : FontWeight.w600,
                    color: isHighlighted ? color : kGreenDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: Icon(Icons.copy_rounded, color: color, size: 16),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied!'),
                    backgroundColor: kGreenMain,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ============================================
// IMAGE LINK WIDGET
// ============================================
class _ImageLinkWidget extends StatelessWidget {
  final String link;

  const _ImageLinkWidget({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kAccentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kAccentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_rounded,
                    color: kAccentBlue, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Profile Image',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  link,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: Icons.copy_rounded,
                color: kAccentBlue,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Link copied!'),
                      backgroundColor: kGreenMain,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              _IconBtn(
                icon: Icons.open_in_new_rounded,
                color: Colors.purple,
                onTap: () async {
                  final uri = Uri.parse(link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Could not open link'),
                          backgroundColor: kAccentRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// ICON BUTTON
// ============================================
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }
}