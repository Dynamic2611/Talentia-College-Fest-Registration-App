import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:talentia/Student/EventDetailsScreen.dart';

class CategoryEventsScreen extends StatelessWidget {
  final String category;
  CategoryEventsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$category Events", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.withOpacity(0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            }

            var events = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                var data = events[index].data() as Map<String, dynamic>;

                String title = data['name'] ?? 'No Title';
                String date = _formatDate(data['eventDate'] ?? 'No Date Available');
                String venue = data['venue'] ?? 'No Venue Available';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Hero(
                    tag: events[index].id,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 6,
                      color: Colors.white.withOpacity(0.9),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.event, color: Colors.white),
                        ),
                        title: Text(
                          title,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          "📅 $date\n📍 $venue",
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(
                                eventId: events[index].id,
                                eventData: data,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
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
