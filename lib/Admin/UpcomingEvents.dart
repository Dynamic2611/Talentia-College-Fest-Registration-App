import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Upcomingevents extends StatelessWidget {
  final bool showUpcoming;

  Upcomingevents({required this.showUpcoming});

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getFilteredEvents() {
    return FirebaseFirestore.instance.collection('events').snapshots().map(
      (snapshot) {
        return snapshot.docs.where((event) {
          var dateValue = event['eventDate'];
          DateTime eventDate;

          if (dateValue is Timestamp) {
            eventDate = dateValue.toDate();
          } else if (dateValue is String) {
            eventDate = DateTime.tryParse(dateValue) ?? DateTime.now();
          } else {
            return false;
          }

          return showUpcoming ? eventDate.isAfter(DateTime.now()) : eventDate.isBefore(DateTime.now());
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(showUpcoming ? "Upcoming Events" : "Completed Events"),
      backgroundColor: Colors.deepOrangeAccent,),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: getFilteredEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(child: Text('No events found'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data();
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded edges
                ),
                elevation: 4, // Soft shadow
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding around card
                child: ListTile(
                  contentPadding: EdgeInsets.all(16), // Spacing inside card
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 255, 211, 198), // Subtle background color
                    child: Icon(Icons.event, color: Colors.deepOrangeAccent), // Icon
                  ),
                  title: Text(
                    event['name'] ?? 'Unnamed Event',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Category: ${event['category'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  // Navigation hint
                ),
              );

            },
          );
        },
      ),
    );
  }
}