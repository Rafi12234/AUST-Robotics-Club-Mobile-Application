import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'size_config.dart';

// Main Events Page

const kGreenDark = Color(0xFF0B6B3A);
const kGreenMain = Color(0xFF16A34A);
const kGreenDeep = Color(0xFF0F3D2E);
const kGreenAccent = Color(0xFF1A5C43);
const kGreenLight = Color(0xFFB8E6D5);
const kOnPrimary = Colors.white;

class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(SizeConfig.screenWidth * 0.25),
        child: AppBar(
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.02),
                    Text(
                      'Club Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.008),
                    Text(
                      'Discover our exciting events and activities',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: SizeConfig.screenWidth * 0.035,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Event_Page')
            .collection('All_Events_of_RC')
            .orderBy('Order', descending: false) // Sort by Order field ascending (1, 2, 3...)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: SizeConfig.screenWidth * 0.15,
                    color: Colors.red,
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: SizeConfig.screenWidth * 0.035,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: SizeConfig.screenWidth * 0.2,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  Text(
                    'No events available',
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.045,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Get events and sort them properly by Order field
          final events = snapshot.data!.docs.toList();

          // Sort events by Order field (handling both int and String types)
          events.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            // Helper function to get Order as int
            int getOrder(dynamic orderValue) {
              if (orderValue == null) return 999;
              if (orderValue is int) return orderValue;
              if (orderValue is String) {
                return int.tryParse(orderValue) ?? 999;
              }
              return 999;
            }

            final orderA = getOrder(dataA['Order']);
            final orderB = getOrder(dataB['Order']);

            return orderA.compareTo(orderB);
          });

          // Debug: Print order of events AFTER sorting
          print('=== Events after sorting ===');
          for (var i = 0; i < events.length; i++) {
            final data = events[i].data() as Map<String, dynamic>;
            print('Position $i: ${data['Event_Name']} - Order: ${data['Order']}');
          }

          return GridView.builder(
            padding: EdgeInsets.all(SizeConfig.screenWidth * 0.04),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: SizeConfig.screenWidth * 0.04,
              mainAxisSpacing: SizeConfig.screenWidth * 0.04,
              childAspectRatio: 0.75,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final data = event.data() as Map<String, dynamic>;
              final eventName = data['Event_Name'] ?? 'Untitled Event';
              final coverPicture = data['Cover_Picture'] ?? '';
              final order = data['Order'] ?? 999;

              return Hero(
                tag: 'event_${event.id}',
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            EventDetailPage(
                              eventId: event.id,
                              eventData: data,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutCubic;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.grey[100]!,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Event Cover Image
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                // Cover Image
                                coverPicture.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: coverPicture,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.event,
                                          size: SizeConfig.screenWidth * 0.12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                                    : Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.event,
                                    size: SizeConfig.screenWidth * 0.12,
                                    color: Colors.grey,
                                  ),
                                ),
                                // Order Number Badge
                                Positioned(
                                  top: SizeConfig.screenWidth * 0.02,
                                  right: SizeConfig.screenWidth * 0.02,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.screenWidth * 0.02,
                                      vertical: SizeConfig.screenHeight * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                                      ),
                                      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: SizeConfig.screenWidth * 0.01,
                                          offset: Offset(0, SizeConfig.screenHeight * 0.002),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '#$order',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: SizeConfig.screenWidth * 0.03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Event Name
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.all(SizeConfig.screenWidth * 0.03),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1B5E20).withOpacity(0.05),
                                    const Color(0xFF2E7D32).withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    eventName,
                                    style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1B5E20),
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Event Detail Page
class EventDetailPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventDetailPage({
    Key? key,
    required this.eventId,
    required this.eventData,
  }) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Map<int, int> _carouselIndices = {};

  // Scroll controller for app bar title animation
  late ScrollController _scrollController;
  double _scrollOffset = 0;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final threshold = SizeConfig.screenHeight * 0.2; // When to show title

    setState(() {
      _scrollOffset = offset;
      _showAppBarTitle = offset > threshold;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<String> _getImagesForHeadline(int headlineNumber) {
    List<String> images = [];
    int imageIndex = 1;
    while (true) {
      final key = 'Headline_${headlineNumber}_Image_$imageIndex';
      if (widget.eventData.containsKey(key) &&
          widget.eventData[key] != null &&
          widget.eventData[key].toString().isNotEmpty) {
        images.add(widget.eventData[key]);
        imageIndex++;
      } else {
        break;
      }
    }
    return images;
  }

  List<Map<String, dynamic>> _getAllHeadlines() {
    List<Map<String, dynamic>> headlines = [];
    int headlineNumber = 1;
    while (true) {
      final headlineKey = 'Headline_$headlineNumber';
      final descriptionKey = 'Headline_${headlineNumber}_description';

      if (widget.eventData.containsKey(headlineKey) &&
          widget.eventData[headlineKey] != null) {
        headlines.add({
          'number': headlineNumber,
          'title': widget.eventData[headlineKey],
          'description': widget.eventData[descriptionKey] ?? '',
          'images': _getImagesForHeadline(headlineNumber),
        });
        headlineNumber++;
      } else {
        break;
      }
    }
    return headlines;
  }

  @override
  Widget build(BuildContext context) {
    final eventName = widget.eventData['Event_Name'] ?? 'Untitled Event';
    final coverPicture = widget.eventData['Cover_Picture'] ?? '';
    final introduction = widget.eventData['Introduction'] ?? '';
    final headlines = _getAllHeadlines();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Curved App Bar with Cover Image
          SliverAppBar(
            expandedHeight: SizeConfig.screenHeight * 0.3,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.02),
              child: Container(
                padding: EdgeInsets.all(SizeConfig.screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: kGreenMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.02),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConfig.screenWidth * 0.05),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // Animated title in app bar
            title: AnimatedOpacity(
              opacity: _showAppBarTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: _showAppBarTitle ? Offset.zero : const Offset(0, 0.5),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Text(
                  eventName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Hero(
                    tag: 'event_${widget.eventId}',
                    child: coverPicture.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: coverPicture,
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
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.event,
                          size: SizeConfig.screenWidth * 0.2,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.event,
                        size: SizeConfig.screenWidth * 0.2,
                        color: Colors.grey,
                      ),
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
                  // Event Name at Bottom
                  Positioned(
                    bottom: SizeConfig.screenHeight * 0.025,
                    left: SizeConfig.screenWidth * 0.04,
                    right: SizeConfig.screenWidth * 0.04,
                    child: Text(
                      eventName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, SizeConfig.screenHeight * 0.002),
                            blurRadius: SizeConfig.screenWidth * 0.01,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction Section
                  if (introduction.isNotEmpty) ...[
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.screenWidth * 0.03,
                              vertical: SizeConfig.screenHeight * 0.008,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                              ),
                              borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.05),
                            ),
                            child: Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.015),
                          Text(
                            introduction,
                            style: TextStyle(
                              fontSize: SizeConfig.screenWidth * 0.04,
                              color: Colors.grey[800],
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                      indent: SizeConfig.screenWidth * 0.05,
                      endIndent: SizeConfig.screenWidth * 0.05,
                    ),
                  ],

                  // Headlines Sections
                  ...headlines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final headline = entry.value;
                    final headlineNumber = headline['number'] as int;
                    final title = headline['title'] as String;
                    final description = headline['description'] as String;
                    final images = headline['images'] as List<String>;

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, SizeConfig.screenHeight * 0.025 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: SizeConfig.screenHeight * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Headline Title
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                              child: Row(
                                children: [
                                  Container(
                                    width: SizeConfig.screenWidth * 0.01,
                                    height: SizeConfig.screenHeight * 0.03,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1B5E20),
                                          Color(0xFF2E7D32)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(SizeConfig.screenWidth * 0.005),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: SizeConfig.screenWidth * 0.03),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: SizeConfig.screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Images Carousel
                            if (images.isNotEmpty) ...[
                              SizedBox(height: SizeConfig.screenHeight * 0.02),
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: SizeConfig.screenHeight * 0.3,
                                  viewportFraction: 0.85,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: images.length > 1,
                                  autoPlay: images.length > 1,
                                  autoPlayInterval:
                                  const Duration(seconds: 4),
                                  autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _carouselIndices[headlineNumber] = index;
                                    });
                                  },
                                ),
                                items: images.map((imageUrl) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: SizeConfig.screenWidth * 0.012),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1B5E20)
                                                  .withOpacity(0.3),
                                              blurRadius: SizeConfig.screenWidth * 0.03,
                                              offset: Offset(0, SizeConfig.screenHeight * 0.007),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(SizeConfig.screenWidth * 0.04),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child:
                                                    CircularProgressIndicator(
                                                      color: Color(0xFF2E7D32),
                                                    ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                Container(
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: SizeConfig.screenWidth * 0.15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: SizeConfig.screenHeight * 0.015),
                              // Carousel Indicators
                              if (images.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: images.asMap().entries.map((entry) {
                                    final currentIndex =
                                        _carouselIndices[headlineNumber] ?? 0;
                                    return Container(
                                      width: currentIndex == entry.key
                                          ? SizeConfig.screenWidth * 0.06
                                          : SizeConfig.screenWidth * 0.02,
                                      height: SizeConfig.screenWidth * 0.02,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: SizeConfig.screenWidth * 0.01),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.01),
                                        color: currentIndex == entry.key
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey[400],
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],

                            // Description
                            if (description.isNotEmpty) ...[
                              SizedBox(height: SizeConfig.screenHeight * 0.02),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                                child: Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: SizeConfig.screenWidth * 0.038,
                                    color: Colors.grey[800],
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],

                            // Divider
                            if (index < headlines.length - 1) ...[
                              SizedBox(height: SizeConfig.screenHeight * 0.03),
                              Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                                indent: SizeConfig.screenWidth * 0.05,
                                endIndent: SizeConfig.screenWidth * 0.05,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: SizeConfig.screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}