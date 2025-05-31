import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatelessWidget {
  final List<String> notifications = [
    "New event added: Art Fest!",
    "Reminder: Poetry Contest tomorrow!",
    "Workshop on Digital Painting this Friday!",
    "Live Q&A with experts happening now!",
    "Early bird registration closing soon!",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications & Updates',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black26,
        leading: Icon(Icons.notifications_active_rounded),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade300,
                          child: Icon(Icons.notifications, color: Colors.white),
                        ),
                        title: Text(
                          notifications[index],
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Tap for more details',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.black54),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Handle notification tap
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle send notification action
        },
        icon: Icon(Icons.send_rounded),
        label: Text('Send Notification'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
