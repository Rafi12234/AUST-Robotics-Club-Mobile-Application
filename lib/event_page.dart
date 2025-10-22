import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Main Events Page
class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Club Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover our exciting events and activities',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
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
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
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
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final data = event.data() as Map<String, dynamic>;
              final eventName = data['Event_Name'] ?? 'Untitled Event';
              final coverPicture = data['Cover_Picture'] ?? '';

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
                      borderRadius: BorderRadius.circular(16),
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
                            child: coverPicture.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: coverPicture,
                              fit: BoxFit.cover,
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
                                    child: const Icon(
                                      Icons.event,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                                : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.event,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // Event Name
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(12),
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
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B5E20),
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
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
        slivers: [
          // Curved App Bar with Cover Image
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
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
                        child: const Icon(
                          Icons.event,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.event,
                        size: 80,
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
                    bottom: 60,
                    left: 16,
                    right: 16,
                    child: Text(
                      eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 4,
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
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            introduction,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                      indent: 20,
                      endIndent: 20,
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
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Headline Title
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1B5E20),
                                          Color(0xFF2E7D32)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Images Carousel
                            if (images.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 250,
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
                                        width:
                                        MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1B5E20)
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(16),
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
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
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
                              const SizedBox(height: 12),
                              // Carousel Indicators
                              if (images.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: images.asMap().entries.map((entry) {
                                    final currentIndex =
                                        _carouselIndices[headlineNumber] ?? 0;
                                    return Container(
                                      width: currentIndex == entry.key ? 24 : 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
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
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 15,
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
                              const SizedBox(height: 24),
                              Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                                indent: 20,
                                endIndent: 20,
                              ),
                            ],
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