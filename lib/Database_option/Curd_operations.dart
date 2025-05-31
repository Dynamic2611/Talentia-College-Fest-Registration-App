import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------
  // Event CRUD Operations
  // ------------------------------

  /// Create a new event
  Future<void> addEvent({
  required String name,
  required String description,
  required String category,
  required String venue,
  required DateTime eventDate,
  required TimeOfDay startTime,
  required double registrationFee,
  required String contactInfo,
  required String isGroupEvent,
  required int maxParticipants,
}) async {
  try {
    DateTime eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      startTime.hour,
      startTime.minute,
    );

    await _firestore.collection('events').add({
      'name': name,
      'description': description,
      'category': category,
      'venue': venue,
      'eventDate': Timestamp.fromDate(eventDateTime),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'registrationFee': registrationFee,
      'contactInfo': contactInfo,
      'isGroupEvent': isGroupEvent,
      'maxParticipants': maxParticipants,
      'createdAt': FieldValue.serverTimestamp(),
      'totalAmount':0
    });
  } catch (e) {
    print('Error adding event: $e');
    throw e;
  }
}


  /// Get all events
  Stream<List<Map<String, dynamic>>> getEvents() {
    return _firestore.collection('events').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList(),
        );
  }

  /// Update an event
  Future<void> updateEvent({
    required String eventId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      if (updatedData.containsKey('eventDate')) {
        updatedData['eventDate'] = Timestamp.fromDate(updatedData['eventDate']);
      }
      await _firestore.collection('events').doc(eventId).update(updatedData);

    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  /// Delete an event and its registrations
  Future<void> deleteEvent(String eventId) async {
  try {
    WriteBatch batch = _firestore.batch();

    final registrations = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .get();

    for (var doc in registrations.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection('events').doc(eventId));

    await batch.commit();
  } catch (e) {
    print('Error deleting event: $e');
    throw e;
  }
}


  // ------------------------------
  // Registration & Check-in
  // ------------------------------

  /// Register a participant under an event
  Future<void> registerParticipant({
    required String eventId,
    required String participantName,
    required String email,
    required String qrCode,
    List<String>? teamMembers,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .add({
        'name': participantName,
        'email': email,
        'qrCode': qrCode,
        'teamMembers': teamMembers ?? [],
        'registeredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error registering participant: $e');
      throw e;
    }
  }

  /// Get registered participants for an event
  Stream<List<Map<String, dynamic>>> getParticipants(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }

  /// Verify QR code
  Future<Map<String, dynamic>?> verifyQRCode(String qrCode, String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .where('qrCode', isEqualTo: qrCode)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // QR code not found
      }

      final participantData = querySnapshot.docs.first.data();
      return {
        'id': querySnapshot.docs.first.id,
        ...participantData,
      };
    } catch (e) {
      print('Error verifying QR code: $e');
      throw e;
    }
  }

  /// Mark participant as checked in
  Future<void> checkInParticipant(String eventId, String participantId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(participantId)
          .update({
        'status': 'Checked In',
        'checkedInAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error checking in participant: $e');
      throw e;
    }
  }




  Stream<List<Map<String, dynamic>>> getRegisteredStudents(String eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? 'No email provided',
          };
        }).toList();
      });
}



Future<void> updateEventTotalAmount(String eventId, double newAmount) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentReference eventRef = firestore.collection('events').doc(eventId);
    DocumentSnapshot eventDoc = await eventRef.get();

    double currentTotal = 0; // Default if totalAmount doesn't exist

    if (eventDoc.exists && eventDoc.data() != null) {
      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
      currentTotal = (eventData['totalAmount'] ?? 0).toDouble();
    }

    double updatedTotal = currentTotal + newAmount;

    await eventRef.set({'totalAmount': updatedTotal}, SetOptions(merge: true));

    print("Total amount updated successfully for event: $eventId");
  } catch (e) {
    print('Error updating total amount: $e');
    throw e;
  }
}





 
}
