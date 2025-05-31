import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talentia/EventDetailsPage.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

class AllEventsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> downloadStudentDetails(String eventId, String eventName) async {
    final QuerySnapshot registrations = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .get();

    var excel = Excel.createExcel();
    var sheet = excel['Student Registrations'];

    // Adding Headers
    sheet.appendRow([
      TextCellValue("Student Name"),
      TextCellValue("Email"),
      TextCellValue("Phone")
    ]);

    // Adding Data
    for (var doc in registrations.docs) {
      var data = doc.data() as Map<String, dynamic>;
      sheet.appendRow([
        data['teamDetails'] ?? 'N/A',
        data['eventID'] ?? 'N/A',
        data['userID'] ?? 'N/A',
      ]);
    }

    // Saving File
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}/$eventName.xlsx";
    File file = File(path);
    await file.writeAsBytes(excel.encode()!);

    print("Excel file saved at: $path");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("All Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Events Available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
          }

          final events = snapshot.data!.docs;
          Map<String, List<QueryDocumentSnapshot>> categorizedEvents = {};

          for (var event in events) {
            var eventData = event.data() as Map<String, dynamic>;
            var category = eventData['category'] ?? 'Uncategorized';

            if (!categorizedEvents.containsKey(category)) {
              categorizedEvents[category] = [];
            }
            categorizedEvents[category]!.add(event);
          }

          return ListView(
            padding: EdgeInsets.all(10),
            children: categorizedEvents.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    title: Text(
                      entry.key,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    children: entry.value.map((event) {
                      var eventData = event.data() as Map<String, dynamic>;
                      var eventId = event.id;
                
                      return FutureBuilder<QuerySnapshot>(
                        future: _firestore.collection('registrations').where('eventId', isEqualTo: eventId).get(),
                        builder: (context, registrationSnapshot) {
                          if (registrationSnapshot.connectionState == ConnectionState.waiting) {
                            return _loadingCard(eventData);
                          }
                
                          var registrationId = registrationSnapshot.hasData && registrationSnapshot.data!.docs.isNotEmpty
                              ? registrationSnapshot.data!.docs.first.id
                              : null;
                
                          return _eventCard(eventData, eventId, registrationId, context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _loadingCard(Map<String, dynamic> eventData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _eventCard(Map<String, dynamic> eventData, String eventId, String? registrationId, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.deepOrangeAccent, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        title: Text(
          eventData['name'] ?? 'No Name',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Category: ${eventData['category'] ?? 'N/A'}",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(eventID: eventId, registrationID: registrationId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
