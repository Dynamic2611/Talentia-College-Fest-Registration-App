import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talentia/Student/CategoryEventsScreen.dart';
import 'package:talentia/Student/EventDetailsScreen.dart';
import 'package:talentia/Student/EventRegistrationPage.dart';
import 'package:talentia/Student/Profile.dart';
import 'package:talentia/Student/RegisteredEvent.dart';
import 'package:talentia/login_page.dart';

class TalentiaApp extends StatefulWidget {
  final String name;
  TalentiaApp({required this.name});

  @override
  State<TalentiaApp> createState() => _TalentiaAppState();
}

class _TalentiaAppState extends State<TalentiaApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TalentiaHomePage(studentName: widget.name),
    );
  }
}

class TalentiaHomePage extends StatefulWidget {
  final String studentName;

  TalentiaHomePage({required this.studentName});

  @override
  State<TalentiaHomePage> createState() => _TalentiaHomePageState();
}

class _TalentiaHomePageState extends State<TalentiaHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    RegisteredEvent(),
    Profile(),
  ];

  int currentYear = DateTime.now().year;

  late List<Map<String, String>> _appBarTitles;

  @override
  void initState() {
    super.initState();
    _appBarTitles = [
      {"title": "Welcome,", "subtitle": "Explore Talentia Fest $currentYear"},
      {"title": "Registered Events", "subtitle": "Your event history"},
      {"title": "Profile", "subtitle": "Manage your profile"},
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> logoutUser() async {
    bool confirmLogout = await _showLogoutConfirmation();
    if (confirmLogout) {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('loginType');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text("Are you sure you want to logout?", style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Logout", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _appBarTitles[_currentIndex]["title"] == "Welcome,"
                  ? "${_appBarTitles[_currentIndex]["title"]} ${widget.studentName}"
                  : _appBarTitles[_currentIndex]["title"]!,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              _appBarTitles[_currentIndex]["subtitle"]!,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: logoutUser,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, 
        color: Colors.blueAccent,
        buttonBackgroundColor: Colors.deepOrangeAccent,
        animationDuration: Duration(milliseconds: 300),
        height: screenHeight * 0.08,
        index: _currentIndex,
        onTap: _onItemTapped,
        items: [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.event, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> featureDetails() async {
  try {
    final details = await FirebaseFirestore.instance.collection('events').get();
    List<Map<String, dynamic>> eventDetailsList = [];

    for (var doc in details.docs) {
      Map<String, dynamic> eventData = doc.data();
      
      // Add the document ID to the event data
      eventData['id'] = doc.id;

      // Ensure that 'isGroupEvent' exists and has a valid value
      String isGroupEvent = eventData['isGroupEvent'] ?? 'solo';  // Default to 'solo' if null
      eventData['isGroupEvent'] = isGroupEvent;

      // Add any additional processing or conditions based on the 'isGroupEvent' value
      if (isGroupEvent == 'solo') {
        // Handle solo event logic
      } else if (isGroupEvent == 'duet') {
        // Handle duet event logic
      } else if (isGroupEvent == 'group') {
        // Handle group event logic
      } else {
        // Handle invalid or missing event type
        print('Invalid event type: $isGroupEvent');
      }

      eventDetailsList.add(eventData);
    }

    return eventDetailsList;
  } catch (e) {
    print("Error fetching event details: $e");
    return [];
  }
}





  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: featureDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching event details'));
        }
        final eventDetails = snapshot.data ?? [];
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Event Categories Grid
                Text(
                  "Event Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 230,
                  child: GridView.builder(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 9.0,
                      mainAxisSpacing: 9.0,
                      childAspectRatio: 1.5,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final categories = [
                        {
                          "title": "Fine Arts",
                          "icon": Icons.palette,
                          "color": Colors.pinkAccent,
                          "screen": CategoryEventsScreen(category: 'Fine Arts'),
                        },
                        {
                          "title": "Literary Arts",
                          "icon": Icons.book,
                          "color": Colors.blueAccent,
                          "screen": CategoryEventsScreen(category: 'Literary Arts'),
                        },
                        {
                          "title": "Performing Arts",
                          "icon": Icons.theater_comedy,
                          "color": Colors.green,
                          "screen": CategoryEventsScreen(category: 'Performing Arts'),
                        },
                        {
                          "title": "Peludes Events",
                          "icon": Icons.calculate_outlined,
                          "color": Colors.orangeAccent,
                          "screen": CategoryEventsScreen(category: 'Peludes Events'),
                        },
                      ];

                      final category = categories[index];
                      return _buildModernCategoryCard(
                        context,
                        category["title"] as String,
                        category["icon"] as IconData,
                        category["color"] as Color,
                        category["screen"] as Widget,
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Featured Events Carousel
                Text(
                  "Featured Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                CarouselSlider(
                  items: eventDetails.map((event) {
                    return _buildFeaturedEventCard(
                      context,
                      event['name'] ?? 'Event Title',
                      _formatDate(event['eventDate'] ?? 'Event Date'),
                      event['venue'] ?? 'Event venue',
                      event['id'] ?? 'Event ID',
                      event,
                      event['registrationFee'] ?? '0',
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 220,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.easeInOut,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(seconds: 3),
                  ),
                ),
                SizedBox(height: 10),

                // Recent Updates Section
                Text(
                  "Recent Updates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildNotificationTile("New Event: Quiz Contest", "Dec 12, 2024", Icons.quiz),
                    _buildNotificationTile("Registration Deadline Extended", "Dec 10, 2024", Icons.date_range),
                    TextButton(
                      onPressed: () {
                        // Navigate to All Notifications
                      },
                      child: Text("View All"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCategoryCard(
      BuildContext context, String title, IconData icon, Color color, Widget nextScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedEventCard(BuildContext context, String title, String date, String venue, String id,Map<String, dynamic> eventData,double fee) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(eventId: id,eventData: eventData),
        ),
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Registration Fee
                Spacer(),
                Text(
                  "₹$fee",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
    
            // Event Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                SizedBox(width: 5),
                Text(
                  date,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 12),
    
            // Event Description
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.white70),
                SizedBox(width: 5),
                Text(
                  venue,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),
    
            // Register Button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationForm(eventID: id),
                    ),
                  );
                },
                icon: Icon(Icons.event, size: 18),
                label: Text('Register Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildNotificationTile(String title, String date, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(date),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(timestamp));
    } catch (e) {
      return "Not specified"; 
    }
  }
}
