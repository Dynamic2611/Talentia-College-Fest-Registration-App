import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talentia/Database_option/Curd_operations.dart';

class RegistrationDetailsPage extends StatefulWidget {
  final String regID;

  const RegistrationDetailsPage({super.key, required this.regID});

  @override
  State<RegistrationDetailsPage> createState() => _RegistrationDetailsPageState();
}

class _RegistrationDetailsPageState extends State<RegistrationDetailsPage> {
  final FirebaseService _firebaseService = FirebaseService(); 
  Map<String, dynamic>? registrationData;
  Map<String, dynamic>? eventData;
  bool isLoading = true;
  double fees=0;
  int memberCount=1;
  double total=0;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
  try {
    // Fetch registration details
    DocumentSnapshot<Map<String, dynamic>> regSnapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .doc(widget.regID)
        .get();

    if (!regSnapshot.exists) {
      _showError("Registration not found!");
      return;
    }

    Map<String, dynamic>? regData = regSnapshot.data();
    if (regData == null || !regData.containsKey('eventID')) {
      _showError("Invalid registration data.");
      return;
    }

    // Fetch event details
    DocumentSnapshot<Map<String, dynamic>> eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(regData['eventID'])
        .get();

    if (!eventSnapshot.exists) {
      _showError("Event details not found!");
      return;
    }

    bool isSolo = eventSnapshot.data()?['isGroupEvent'] == 'Solo';
    double eventFees = (eventSnapshot.data()?['registrationFee'] ?? 0).toDouble();
    int members = isSolo ? 1 : (regData['teamDetails']?['members']?.length ?? 1);
    double totalFees = eventFees * members;

    if (mounted) {
      setState(() {
        registrationData = regData;
        eventData = eventSnapshot.data();
        fees = eventFees;
        memberCount = members;
        total = totalFees;
        isLoading = false;
      });
    }
  } catch (e) {
    _showError("Error fetching details: $e");
  }
}


  Future<void> _updatePaymentStatus(double amt) async {
    try {
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc(widget.regID)
          .update({'paymentStatus': 'Verified'});

      if (mounted) {
        setState(() {
          registrationData?['paymentStatus'] = 'Verified';
        });
      }
      await _firebaseService.updateEventTotalAmount(registrationData?['eventID'], amt);
      _showSuccess("Payment Verified Successfully!");
    } catch (e) {
      _showError("Error updating payment status: $e");
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event & Registration Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : registrationData == null || eventData == null
              ? const Center(child: Text("No details found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventDetails(),
                      const SizedBox(height: 20),
                      _buildRegistrationDetails(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEventDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eventData?['name'] ?? 'N/A', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category, "Category: ${eventData?['category'] ?? 'N/A'}"),
            _buildInfoRow(Icons.location_on, "Venue: ${eventData?['venue'] ?? 'N/A'}"),
            _buildInfoRow(Icons.people, "Max Participants: ${eventData?['maxParticipants'] ?? 'N/A'}"),
            _buildInfoRow(Icons.event, "Date: ${eventData?['eventDate'] ?? 'N/A'}"),
            _buildInfoRow(Icons.access_time, "Start Time: ${eventData?['startTime'] ?? 'N/A'}"),
            _buildInfoRow(Icons.attach_money, "Registration Fee: ₹${eventData?['registrationFee'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            const Text("Description:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(eventData?['description'] ?? 'No description available.', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationDetails() {
    bool isSolo = (eventData?['isGroupEvent'] ?? 'Group') == 'Solo';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Registration Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Reg ID: ${widget.regID}"),
            Text(
              "Payment Status: ${registrationData?['paymentStatus'] ?? 'Pending'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (registrationData?['paymentStatus'] == 'Verified') ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            // Solo Event - Show participant details
            if (isSolo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Participant Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Name: ${registrationData?['participantDetails']?['name'] ?? 'N/A'}"),
                  Text("Email: ${registrationData?['participantDetails']?['class'] ?? 'N/A'}"),
                  Text("Phone: ${registrationData?['participantDetails']?['studentID'] ?? 'N/A'}"),
                ],
              ),

            // Group/Duet Event - Show team details
            if (!isSolo)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Team Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Team Name: ${registrationData?['teamDetails']?['teamName'] ?? 'N/A'}"),
                const SizedBox(height: 8),
                const Text("Members:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),

                Table(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(2), // Student ID
                    1: FlexColumnWidth(3), // Name
                    2: FlexColumnWidth(2), // Class
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Student ID", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Class", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Table Rows
                    ...?registrationData?['teamDetails']?['members']?.map<TableRow>((member) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(member['studentID'].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(member['name'].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(member['class'].toString()),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: Column(
        children: [
          if (registrationData?['paymentStatus'] != 'Verified')
            ElevatedButton.icon(
              onPressed: () => _updatePaymentStatus(total),
              icon: const Icon(Icons.check_circle),
              label: const Text("Verify Payment"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          Text(
            'Total: ₹$total',
            style: TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (registrationData?['paymentStatus'] == 'Verified')
            Text("Verfied !",
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          
        ],
      ),
    );
  }
}
