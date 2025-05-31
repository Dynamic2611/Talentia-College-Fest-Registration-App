import 'dart:async';
import 'package:flutter/material.dart';
import 'package:talentia/login_page.dart';

class TalentiaUI extends StatefulWidget {
  @override
  _TalentiaUIState createState() => _TalentiaUIState();
}

class _TalentiaUIState extends State<TalentiaUI> {
  final PageController _pageController = PageController(initialPage: 1000);
  int _currentPage = 1000;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();

    // Listen to page changes and update _currentPage
    _pageController.addListener(() {
      if (_pageController.page?.toInt() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page?.toInt() ?? _currentPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size dynamically
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // Top section with the main image
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Main image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(70),
                  ),
                  child: Image.asset(
                    "assets/college.jpg", // Replace with your asset path
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Transparent "Talentia" text with border
                Positioned(
                  top: screenHeight * 0.35, // Dynamic positioning
                  left: 20,
                  child: Text(
                    "TALENTIA",
                    style: TextStyle(
                      fontSize: screenWidth * 0.15, // Responsive font size
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(2, 5),
                        ),
                      ],
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: screenHeight * 0.4, // Dynamic height
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(230, 22, 54, 22),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final pageIndex = index % 3;
                        return _buildPageContent(
                          title: pageIndex == 0
                              ? "Discover Events"
                              : pageIndex == 1
                                  ? "Showcase Your Talent"
                                  : "Register Seamlessly",
                          description: pageIndex == 0
                              ? "Explore a variety of exciting events happening near you."
                              : pageIndex == 1
                                  ? "Participate and showcase your unique skills to the world."
                                  : "Easy registration and quick updates about your participation.",
                          image: pageIndex == 0
                              ? Icons.event_available_outlined
                              : pageIndex == 1
                                  ? Icons.star_border
                                  : Icons.check_circle_outline,
                        );
                      },
                    ),
                  ),
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => buildDot(isActive: _currentPage % 3 == index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Get Started button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                elevation: 5,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google logo
                  Image.asset(
                    'assets/talentia_logo.png', // Replace with your asset path
                    height: screenWidth * 0.12, // Adjust the size based on screen width
                    width: screenWidth * 0.12, // Adjust the size based on screen width
                  ),
                  SizedBox(width: 15), // Space between the logo and the text
                  Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page content builder
  Widget _buildPageContent({
    required String title,
    required String description,
    required IconData image,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            image,
            size: 80,
            color: Colors.deepPurpleAccent,
          ),
          SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Dot indicator builder
  Widget buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: isActive ? 20 : 10,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[300]!],
              ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}
