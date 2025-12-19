import 'package:flutter/material.dart';
import 'size_config.dart';
import 'member_recruitment_page.dart';
import 'sub_executive_recruitment_page.dart';

class MemberRecruitmentSelectionPage extends StatefulWidget {
  const MemberRecruitmentSelectionPage({Key? key}) : super(key: key);

  @override
  State<MemberRecruitmentSelectionPage> createState() =>
      _MemberRecruitmentSelectionPageState();
}

class _MemberRecruitmentSelectionPageState
    extends State<MemberRecruitmentSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _navigateToForm(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Curved App Bar
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.22,
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.016),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: SizeConfig.screenWidth * 0.045),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                  left: SizeConfig.screenWidth * 0.08,
                  bottom: SizeConfig.screenHeight * 0.013),
              title: Text(
                'Join Our Team',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B5E20),
                      Color(0xFF2E7D32),
                      Color(0xFF43A047),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -SizeConfig.screenWidth * 0.1,
                      top: SizeConfig.screenHeight * 0.02,
                      child: Icon(
                        Icons.people_alt_rounded,
                        size: SizeConfig.screenWidth * 0.45,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: SizeConfig.screenWidth * 0.089,
                      bottom: SizeConfig.screenHeight * 0.05,
                      child: Text(
                        'Choose Your Path',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: SizeConfig.screenWidth * 0.038,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.02),

                    // Welcome Text
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1B5E20).withOpacity(0.1),
                              const Color(0xFF43A047).withOpacity(0.05),
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.waving_hand_rounded,
                              size: SizeConfig.screenWidth * 0.1,
                              color: const Color(0xFF2E7D32),
                            ),
                            SizedBox(height: SizeConfig.screenHeight * 0.015),
                            Text(
                              'Welcome to AUST Robotics Club!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            SizedBox(height: SizeConfig.screenHeight * 0.01),
                            Text(
                              'Select the type of membership you want to apply for',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.04),

                    // General Member Card
                    _buildRecruitmentCard(
                      delay: 0,
                      title: 'General Member',
                      subtitle: 'Join as a regular club member',
                      description:
                      'Become part of our community, participate in events, workshops, and competitions. Perfect for students who want to explore robotics.',
                      icon: Icons.group_add_rounded,
                      gradientColors: [
                        const Color(0xFF1B5E20),
                        const Color(0xFF2E7D32),
                      ],
                      features: [
                        'Access to workshops & events',
                        'Networking opportunities',
                        'Project collaborations',
                        'Club merchandise discounts',
                      ],
                      onTap: () =>
                          _navigateToForm(const MemberRecruitmentPage()),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.025),

                    // Sub Executive Card
                    _buildRecruitmentCard(
                      delay: 200,
                      title: 'Sub Executive',
                      subtitle: 'Join our leadership panel',
                      description:
                      'Take a leadership role and help manage club operations. Ideal for motivated individuals who want to develop organizational skills.',
                      icon: Icons.admin_panel_settings_rounded,
                      gradientColors: [
                        const Color(0xFF6A1B9A),
                        const Color(0xFF8E24AA),
                      ],
                      features: [
                        'Leadership experience',
                        'Department specialization',
                        'Event management roles',
                        'Certificate of recognition',
                      ],
                      onTap: () =>
                          _navigateToForm(const SubExecutiveRecruitmentPage()),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.03),

                    // Info Note
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(
                                0, SizeConfig.screenHeight * 0.02 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                          BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                          border: Border.all(
                            color: Colors.blue[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blue[700],
                              size: SizeConfig.screenWidth * 0.06,
                            ),
                            SizedBox(width: SizeConfig.screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                'You can apply for both positions if you meet the requirements. Sub Executives must also be General Members.',
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.032,
                                  color: Colors.blue[800],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard({
    required int delay,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(SizeConfig.screenWidth * 0.1 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.2),
                blurRadius: SizeConfig.screenWidth * 0.04,
                offset: Offset(0, SizeConfig.screenHeight * 0.01),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.045),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SizeConfig.screenWidth * 0.05),
                    topRight: Radius.circular(SizeConfig.screenWidth * 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeConfig.screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                        BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: SizeConfig.screenWidth * 0.08,
                      ),
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: SizeConfig.screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.005),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: SizeConfig.screenWidth * 0.033,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: SizeConfig.screenWidth * 0.05,
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.034,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.02),
                    Wrap(
                      spacing: SizeConfig.screenWidth * 0.02,
                      runSpacing: SizeConfig.screenHeight * 0.01,
                      children: features.map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.screenWidth * 0.025,
                            vertical: SizeConfig.screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: gradientColors[0].withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                            border: Border.all(
                              color: gradientColors[0].withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: SizeConfig.screenWidth * 0.035,
                                color: gradientColors[0],
                              ),
                              SizedBox(width: SizeConfig.screenWidth * 0.015),
                              Text(
                                feature,
                                style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.028,
                                  color: gradientColors[0],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.02),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.screenHeight * 0.015,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius:
                        BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Apply Now',
                            style: TextStyle(
                              fontSize: SizeConfig.screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: SizeConfig.screenWidth * 0.02),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: SizeConfig.screenWidth * 0.045,
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
      ),
    );
  }
}