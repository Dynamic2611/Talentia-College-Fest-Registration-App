import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talentia/Admin/EventFormPage.dart';
import 'package:talentia/Database_option/Curd_operations.dart';

class EventManagementPage extends StatefulWidget {
  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingEffect(); // Shimmer effect while loading
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: BouncingScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrangeAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventFormPage()),
          );
        },
        icon: Icon(Icons.add, size: 28),
        label: Text("Add Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Shimmer loading effect
  Widget _buildLoadingEffect() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  /// Widget to display when no events are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 10),
          Text(
            'No events available.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Builds an event card with a modern glassmorphism effect
  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
          width: 1,
        ),
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.event, color: Colors.deepOrangeAccent, size: 40),
        title: Text(
          event['name'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Category: ${event['category']}',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 4),
            Text(
              'Venue: ${event['venue']}',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _deleteEvent(event['id']),
        ),
        onTap: () async {
          DocumentSnapshot eventSnapshot =
              await FirebaseFirestore.instance.collection('events').doc(event['id']).get();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventFormPage(eventData: eventSnapshot),
            ),
          );
        },
      ),
    );
  }

  /// Deletes an event with confirmation dialog
  void _deleteEvent(String eventId) async {
  bool confirmDelete = await _showDeleteConfirmationDialog();
  if (!confirmDelete) return;

  try {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    
    // Reference to the registrations collection
    CollectionReference registrationsRef = FirebaseFirestore.instance.collection('registrations');

    // Query registrations linked to the event
    QuerySnapshot registrationsSnapshot = await registrationsRef.where('eventId', isEqualTo: eventId).get();

    // Add all registrations to batch delete
    for (QueryDocumentSnapshot doc in registrationsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the event itself
    batch.delete(FirebaseFirestore.instance.collection('events').doc(eventId));

    // Commit batch operation
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event and registrations deleted successfully"), backgroundColor: Colors.redAccent),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error deleting event: $error"), backgroundColor: Colors.red),
    );
  }
}


  /// Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete Event"),
            content: Text("Are you sure you want to delete this event?"),
            actions: [
              TextButton(
                child: Text("Cancel", style: TextStyle(color: Colors.black54)),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text("Delete", style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
