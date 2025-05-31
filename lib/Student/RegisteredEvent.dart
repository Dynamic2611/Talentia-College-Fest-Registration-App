import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class RegisteredEvent extends StatefulWidget {
  const RegisteredEvent({super.key});

  @override
  State<RegisteredEvent> createState() => _RegisteredEventState();
}

class _RegisteredEventState extends State<RegisteredEvent> {
  List<Map<String, dynamic>> registeredEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRegisteredEvents();
  }

  Future<void> fetchRegisteredEvents() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isEmpty) {
        print("User not logged in");
        setState(() => isLoading = false);
        return;
      }

      // Fetch registrations for the logged-in user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('userID', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> tempEvents = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Fetch event details
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(data['eventID'])
            .get();

        if (eventDoc.exists) {
          Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
          tempEvents.add({
            'eventName': eventData['name'],
            'eventDate': eventData['eventDate'],
            'eventLocation': eventData['venue'],
            'eventID': data['eventID'],
            'qrCode': data['qrCode'], // Fetch QR Code directly
            'paymentStatus': data['paymentStatus'] ?? "Pending", // Fetch Payment Status
          });
        }
      }

      setState(() {
        registeredEvents = tempEvents;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching registered events: $e");
      setState(() => isLoading = false);
    }
  }

  void showQRCodeDialog(String qrCode) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Your QR Code",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    qrCode.isEmpty
                        ? const Text(
                            "QR Code not available",
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: PrettyQrView.data(
                              data: qrCode,
                              decoration: const PrettyQrDecoration(
                                image: PrettyQrDecorationImage(
                                  image: AssetImage("assets/talentia_logo.png"),
                                  scale: 0.15,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    const Text(
                      "Scan this QR code to verify registration",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : registeredEvents.isEmpty
              ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text(
                        "No registered events found",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
              )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView.builder(
                    itemCount: registeredEvents.length,
                    itemBuilder: (context, index) {
                      var event = registeredEvents[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent.withOpacity(0.1),
                              child: const Icon(Icons.event, color: Colors.blueAccent),
                            ),
                            title: Text(
                              event['eventName'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        event['eventDate'],
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                                      const SizedBox(width: 5),
                                      Text(
                                        event['eventLocation'],
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Payment Status: ${event['paymentStatus']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: event['paymentStatus'] == "Verified" ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () => showQRCodeDialog(event['qrCode'] ?? ""),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.qr_code, color: Colors.blueAccent, size: 26),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
