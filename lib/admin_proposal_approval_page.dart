import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Theme colors
const kGreenDark = Color(0xFF0F3D2E);
const kGreenMain = Color(0xFF2D6A4F);
const kGreenLight = Color(0xFF52B788);
const kAccentGold = Color(0xFFFFB703);
const kAccentPurple = Color(0xFF6366F1);
const kAccentRed = Color(0xFFEF4444);
const kAccentBlue = Color(0xFF3B82F6);

// Gmail Compose Helper Function
Future<void> openGmailCompose({
  required String toEmail,
  required String subject,
  required String body,
  required BuildContext context,
}) async {
  try {
    // URL encode the parameters
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);

    // Create mailto URL (opens Gmail or default email app)
    final mailtoUrl = Uri.parse(
      'mailto:$toEmail?subject=$encodedSubject&body=$encodedBody'
    );

    print('📧 Attempting to open email app...');
    print('To: $toEmail');
    print('Subject: $subject');
    print('URL: $mailtoUrl');

    // Try to launch the URL
    final bool launched = await launchUrl(
      mailtoUrl,
      mode: LaunchMode.externalApplication,
    );

    if (launched) {
      print('✅ Email app opened successfully!');
    } else {
      print('❌ Failed to open email app');
      throw 'Could not open email app. Please check if you have Gmail installed.';
    }
  } catch (e) {
    print('❌ Error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email app: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class AdminProposalApprovalPage extends StatefulWidget {
  const AdminProposalApprovalPage({Key? key}) : super(key: key);

  @override
  State<AdminProposalApprovalPage> createState() => _AdminProposalApprovalPageState();
}

class _AdminProposalApprovalPageState extends State<AdminProposalApprovalPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
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

          // Proposals List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('All_Data')
                  .doc('Student_Proposal_for_R&P')
                  .collection('student_proposal_for_R&P')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kGreenMain),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: kAccentRed,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading proposals',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kGreenDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No proposals yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Proposals will appear here once submitted',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final proposals = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _ProposalCard(
                        proposal: proposals[index],
                        index: index,
                      );
                    },
                    childCount: proposals.length,
                  ),
                );
              },
            ),
          ),

          // Bottom Spacing
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
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kGreenDark,
              kGreenMain,
              kGreenLight,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
          title: FadeTransition(
            opacity: _headerFadeAnimation,
            child: const Text(
              'Proposal Approval',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatefulWidget {
  final QueryDocumentSnapshot proposal;
  final int index;

  const _ProposalCard({
    required this.proposal,
    required this.index,
  });

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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

  @override
  Widget build(BuildContext context) {
    final data = widget.proposal.data() as Map<String, dynamic>;
    final austrcId = widget.proposal.id;
    final proposalType = data['Proposal'] ?? 'N/A';
    final title = data['Title'] ?? 'No Title';
    final shortDescription = data['Short_Des'] ?? 'No description provided';
    final institutionalMail = data['Institutional_Mail'] ?? 'N/A';

    // Determine color based on proposal type
    Color cardAccent;
    IconData typeIcon;
    if (proposalType.toString().toLowerCase().contains('research')) {
      cardAccent = kAccentBlue;
      typeIcon = Icons.science_rounded;
    } else if (proposalType.toString().toLowerCase().contains('project')) {
      cardAccent = kAccentPurple;
      typeIcon = Icons.engineering_rounded;
    } else {
      cardAccent = kGreenMain;
      typeIcon = Icons.description_rounded;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cardAccent.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            // Type Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cardAccent,
                                    cardAccent.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: cardAccent.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                typeIcon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Title and Type
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: kGreenDark,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: cardAccent.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      proposalType,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: cardAccent,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Expand/Collapse Icon
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kGreenLight.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: kGreenMain,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.grey[300]!,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // AUSTRC ID
                        _buildInfoRow(
                          icon: Icons.badge_rounded,
                          label: 'AUSTRC ID',
                          value: austrcId,
                          color: kGreenMain,
                        ),

                        // Expandable Details
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Column(
                            children: [
                              const SizedBox(height: 16),

                              // Institutional Mail
                              _buildInfoRow(
                                icon: Icons.email_rounded,
                                label: 'Institutional Mail',
                                value: institutionalMail,
                                color: kAccentBlue,
                              ),
                              const SizedBox(height: 16),

                              // Description
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.description_rounded,
                                          color: kAccentPurple,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: kGreenDark,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      shortDescription,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),

                        // Action Buttons (Approve/Reject)
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                label: 'Approve',
                                icon: Icons.check_circle_rounded,
                                gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
                                onPressed: () => _handleApprove(
                                  context: context,
                                  proposalId: austrcId,
                                  title: title,
                                  recipientEmail: institutionalMail,
                                  data: data,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                label: 'Reject',
                                icon: Icons.cancel_rounded,
                                gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                onPressed: () => _handleReject(
                                  context: context,
                                  proposalId: austrcId,
                                  title: title,
                                  recipientEmail: institutionalMail,
                                  data: data,
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kGreenDark,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Handle Approve Action
  void _handleApprove({
    required BuildContext context,
    required String proposalId,
    required String title,
    required String recipientEmail,
    required Map<String, dynamic> data,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kGreenMain),
            ),
            const SizedBox(height: 20),
            Text(
              'Approving proposal...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kGreenDark,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Update proposal status in Firebase
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_Proposal_for_R&P')
          .collection('student_proposal_for_R&P')
          .doc(proposalId)
          .update({
        'Status': 'Approved',
        'Approved_At': FieldValue.serverTimestamp(),
      });

      // Close loading dialog
      Navigator.pop(context);

      // Prepare email content
      final studentName = data['Student_Name'] ?? 'Student';
      final emailSubject = '✅ Proposal Approved - $title';
      final emailBody = '''Dear $studentName,

Congratulations! Your research/project proposal has been APPROVED by the AUST Robotics Club administration.

Proposal Details:
• Title: $title
• AUSTRC ID: $proposalId

We are excited to see your project come to life. Our team will contact you soon with the next steps and resources available for your project.

If you have any questions, feel free to reach out to us.

Best regards,
AUST Robotics Club Team
Ahsanullah University of Science and Technology''';

      // Open Gmail compose
      await openGmailCompose(
        toEmail: recipientEmail,
        subject: emailSubject,
        body: emailBody,
        context: context,
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Proposal approved! Gmail opened to send notification.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error approving proposal: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: kAccentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Handle Reject Action
  void _handleReject({
    required BuildContext context,
    required String proposalId,
    required String title,
    required String recipientEmail,
    required Map<String, dynamic> data,
  }) async {
    // Show rejection reason dialog
    final TextEditingController reasonController = TextEditingController();

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cancel_rounded, color: kAccentRed, size: 28),
            const SizedBox(width: 12),
            Text(
              'Reject Proposal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kGreenDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide a reason for rejection (optional):',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kGreenMain, width: 2),
                ),
              ),
            ),
          ],
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
              backgroundColor: kAccentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldReject != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAccentRed),
            ),
            const SizedBox(height: 20),
            Text(
              'Rejecting proposal...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kGreenDark,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Get rejection reason
      final rejectionReason = reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim();

      // Update proposal status in Firebase
      await FirebaseFirestore.instance
          .collection('All_Data')
          .doc('Student_Proposal_for_R&P')
          .collection('student_proposal_for_R&P')
          .doc(proposalId)
          .update({
        'Status': 'Rejected',
        'Rejected_At': FieldValue.serverTimestamp(),
        if (rejectionReason != null) 'Rejection_Reason': rejectionReason,
      });

      // Close loading dialog
      Navigator.pop(context);

      // Prepare email content
      final studentName = data['Student_Name'] ?? 'Student';
      final emailSubject = '❌ Proposal Update - $title';
      final emailBody = '''Dear $studentName,

Thank you for submitting your research/project proposal. After careful review, we regret to inform you that your proposal has not been approved at this time.

Proposal Details:
• Title: $title
• AUSTRC ID: $proposalId${rejectionReason != null ? '\n• Reason: $rejectionReason' : ''}

We encourage you to refine your proposal and resubmit in the future. Our team is here to help you improve your submission.

If you have any questions or would like feedback, please don't hesitate to contact us.

Best regards,
AUST Robotics Club Team
Ahsanullah University of Science and Technology''';

      // Open Gmail compose
      await openGmailCompose(
        toEmail: recipientEmail,
        subject: emailSubject,
        body: emailBody,
        context: context,
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Proposal rejected! Gmail opened to send notification.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: kAccentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error rejecting proposal: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: kAccentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// Action Button Widget
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          _controller.reverse();
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          _controller.reverse();
          setState(() => _isPressed = false);
        },
        onTap: widget.onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(_isPressed ? 0.3 : 0.4),
                blurRadius: _isPressed ? 8 : 12,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
