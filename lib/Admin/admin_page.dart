import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talentia/Admin/AllEventsPage.dart';
import 'package:talentia/Admin/Manage_Event_Page.dart';
import 'package:talentia/notify/Notifications.dart';
import 'package:talentia/Admin/QRScanner.dart';
import 'package:talentia/Admin/UpcomingEvents.dart';
import 'package:talentia/EventDetailsPage.dart';

class AdminHomePage extends StatefulWidget {
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AdminHomePageContent(),
    Qrscannerpage(),
    EventManagementPage(),
  ];

  final List<String> _titles = [
    'Welcome, Admin 👋',
    'QR Scanner',
    'Event Management',
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.qr_code_scanner_rounded,
    Icons.event_rounded,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = screenHeight * 0.035; // Dynamic icon size

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.yellow, size: 30),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.yellow, size: 30),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
        ],
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.deepOrangeAccent,
        buttonBackgroundColor: Colors.orangeAccent,
        height: screenHeight * 0.07, // Adjust height dynamically
        animationDuration: Duration(milliseconds: 300),
        index: _selectedIndex,
        items: List.generate(
          _icons.length,
          (index) => Icon(_icons[index], size: iconSize, color: Colors.white),
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}


class AdminHomePageContent extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getEventsStream() {
    return _firestore.collection('events').snapshots();
  }

  Stream<int> getParticipantCount() {
    return _firestore.collection('registrations').snapshots().map((snapshot) {
      return snapshot.docs.isNotEmpty ? snapshot.docs.length : 0;
    });
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: getEventsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                }

                final events = snapshot.data!.docs;
                final totalEvents = events.length;
                final upcomingEvents = events.where((event) {
                  var dateValue = event['eventDate'];
                  DateTime eventDate;

                  if (dateValue is Timestamp) {
                    eventDate = dateValue.toDate();
                  } else if (dateValue is String) {
                    eventDate = DateTime.tryParse(dateValue) ?? DateTime.now();
                  } else {
                    return false;
                  }

                  return eventDate.isAfter(DateTime.now());
                }).length;

                final completedEvents = totalEvents - upcomingEvents;

                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllEventsPage()),
                        );
                      },
                      child: StatCard(
                        title: 'Total Events',
                        value: '$totalEvents',
                        color: Colors.orange,
                        icon: Icons.event_rounded,
                      ),
                    ),


                    StreamBuilder<int>(
                      stream: getParticipantCount(),
                      builder: (context, participantSnapshot) {
                        return StatCard(
                          title: 'Participants',
                          value: participantSnapshot.hasData
                              ? '${participantSnapshot.data}'
                              : '0',
                          color: Colors.green,
                          icon: Icons.people_rounded,
                        );
                      },
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Upcomingevents(showUpcoming: true),
                          ),
                        );
                      },
                      child: StatCard(
                        title: 'Upcoming Events',
                        value: '$upcomingEvents',
                        color: Colors.blue,
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Upcomingevents(showUpcoming: false),
                          ),
                        );
                      },
                      child: StatCard(
                        title: 'Completed Events',
                        value: '$completedEvents',
                        color: Colors.purple,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),

                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Text('Recent Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: getEventsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return Center(child: Text('Error fetching activities'));
                }

                final activities = snapshot.data!.docs.where((event) {
                  var dateValue = event['eventDate'];
                  DateTime? eventDate;

                  if (dateValue is Timestamp) {
                    eventDate = dateValue.toDate();
                  } else if (dateValue is String) {
                    eventDate = DateTime.tryParse(dateValue);
                  }

                  if (eventDate == null) return false; // Handle invalid data

                  DateTime now = DateTime.now();
                  return eventDate.year == now.year &&
                      eventDate.month == now.month &&
                      eventDate.day == now.day;
                }).toList();

                if (activities.isEmpty) {
                  return Center(child: Text('No events scheduled for today.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final event = activities[index].data() as Map<String, dynamic>;
                    final eventId = activities[index].id;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailPage(eventID: '$eventId',),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.timeline, color: Colors.blueAccent),
                          title: Text(event['name'] ?? 'Unnamed Event'),
                          subtitle: Text('Category: ${event['category'] ?? 'N/A'}'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                radius: 26,
                child: Icon(icon, size: 25, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
