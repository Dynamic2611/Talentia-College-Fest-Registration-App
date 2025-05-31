import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talentia/Student/EventRegistrationPage.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  EventDetailsScreen({required this.eventId, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text((eventData['name'] ?? "Event Details").toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎟 Event Information Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.category, "Category", eventData['category']),
                      _buildInfoRow(Icons.phone, "Contact", eventData['contactInfo']),
                      _buildInfoRow(Icons.calendar_today, "Date", _formatDate(eventData['eventDate'])),
                      _buildInfoRow(Icons.access_time, "Start Time", eventData['startTime']),
                      _buildInfoRow(Icons.location_on, "Venue", eventData['venue']),
                      _buildInfoRow(Icons.group, "Event Type", eventData['isGroupEvent']),
                      _buildInfoRow(Icons.people, "Max Participants", eventData['maxParticipants'].toString()),
                      _buildInfoRow(Icons.attach_money, "Registration Fee", "₹${eventData['registrationFee']}"),
                      const Divider(thickness: 1),
                      const SizedBox(height: 10),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                         eventData['description'],
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 📩 Register Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegistrationForm(eventID: eventId)),
                    );
                  },
                  icon: const Icon(Icons.event_available, color: Colors.white),
                  label: const Text("Register for Event", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Helper Widget for Displaying Row Data
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value ?? "N/A", style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
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
