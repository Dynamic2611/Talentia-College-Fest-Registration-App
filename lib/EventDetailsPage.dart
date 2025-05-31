import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:talentia/Admin/EventExcel.dart';

class EventDetailPage extends StatefulWidget {
  final String eventID;
  final String? registrationID;

  const EventDetailPage({Key? key, required this.eventID, this.registrationID}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  List<Map<String, dynamic>> participants = [];
  bool isLoading = true;
  String? eventName; // Holds the event name for AppBar

  @override
  void initState() {
    super.initState();
    fetchRegistrations();
  }

  Future<void> fetchRegistrations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('eventID', isEqualTo: widget.eventID)
          .get();

      List<Map<String, dynamic>> tempParticipants = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('participantDetails')) {
          tempParticipants.add({
            'type': 'Solo',
            'name': data['participantDetails']['name'] ?? 'Unknown',
            'studentID': data['participantDetails']['studentID'] ?? 'N/A',
            'class': data['participantDetails']['class'] ?? 'N/A',
          });
        } else if (data.containsKey('teamDetails')) {
          List<dynamic> members = data['teamDetails']['members'] ?? [];
          tempParticipants.add({
            'type': 'Team',
            'teamName': data['teamDetails']['teamName'] ?? 'Unnamed Team',
            'members': members.map((member) {
              return {
                'name': member['name'] ?? 'Unknown',
                'studentID': member['studentID'] ?? 'N/A',
                'class': member['class'] ?? 'N/A',
              };
            }).toList(),
          });
        }
      }

      setState(() {
        participants = tempParticipants;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching registrations: $e");
      setState(() => isLoading = false);
    }
  }

   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName?.toUpperCase() ?? "Event Details",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(widget.eventID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text("Event not found", style: GoogleFonts.poppins(fontSize: 16)),
            );
          }

          var event = snapshot.data!.data() as Map<String, dynamic>;

          // Update AppBar title dynamically when event data is fetched
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (eventName != event['name']) {
              setState(() {
                eventName = event['name'];
              });
            }
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Table(
                      border: TableBorder.all(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        _buildTableRow("Name", event['name'] ?? 'N/A'),
                        _buildTableRow("Venue", event['venue'] ?? 'N/A'),
                        _buildTableRow("Date", _formatDate(event['eventDate'])),
                        _buildTableRow("Start Time", event['startTime'] ?? 'N/A'),
                        _buildTableRow("Registration Fee", "₹${event['registrationFee']?.toString() ?? 'Free'}"),
                        _buildTableRow("Contact", event['contactInfo'] ?? 'Not available'),
                        _buildTableRow("Event Type", event['isGroupEvent'] ?? 'N/A'),
                        _buildTableRow("Description ", event['description']?.toString() ?? 'N/A'),
                        _buildTableRow("Max Participants", event['maxParticipants']?.toString() ?? 'N/A'),
                        _buildTableRow("Participants", participants.length.toString()),
                        _buildTableRow("Total Amount", "₹${event['totalAmount'].toStringAsFixed(2)}")

                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Registered Participants",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 300, // Set a fixed height to make it scrollable
                    child: _buildParticipantsList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Fetch event data again to pass here
          DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventID)
              .get();

          Map<String, dynamic> event = eventSnapshot.data() as Map<String, dynamic>;

          // Call the updated function
          await exportAndShareExcel(event, participants);
        },
        child: const Icon(Icons.share),
        backgroundColor: Colors.deepOrangeAccent,
      ),


    );
  }


  Widget _buildParticipantsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (participants.isEmpty) {
      return Center(
        child: Text("No participants registered yet.", style: GoogleFonts.poppins(fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        var participant = participants[index];

        if (participant['type'] == 'Solo') {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(participant['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${participant['studentID']}, Class: ${participant['class']}'),
              leading: const Icon(Icons.person, color: Colors.deepPurpleAccent),
            ),
          );
        } else {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              leading: const Icon(Icons.group, color: Colors.deepPurpleAccent),
              title: Text(participant['teamName'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              children: (participant['members'] as List).map((member) {
                return ListTile(
                  title: Text(member['name'], style: GoogleFonts.poppins()),
                  subtitle: Text('ID: ${member['studentID']}, Class: ${member['class']}'),
                  leading: const Icon(Icons.person, color: Colors.grey),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(timestamp));
    } catch (e) {
      return "Not specified"; // Handle cases where the timestamp is not in a valid format
    }
  }

  TableRow _buildTableRow(String label, String value, {bool isEvenRow = false}) {
  return TableRow(
    decoration: BoxDecoration(
      color: isEvenRow ? Colors.grey[200] : Colors.white, // Alternating row colors
      borderRadius: BorderRadius.circular(8), // Rounded borders
    ),
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5), // Subtle border
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5), // Subtle border
          ),
        ),
        child: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  );
}



}
