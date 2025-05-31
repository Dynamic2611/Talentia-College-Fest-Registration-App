import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class RegistrationForm extends StatefulWidget {
  final String eventID;

  const RegistrationForm({Key? key, required this.eventID}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  
  List<Map<String, String>> teamMembers = [];
  bool isTeamEvent = false;
  bool isDuetEvent = false;
  bool isSoloEvent = false;
  int minTeamSize = 1;
  int maxTeamSize = 1;
  bool isLoading = false;
  bool isLoadingEvent = true;
  bool isRegistrationSuccess = false;
  String userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventID)
          .get();

      if (eventSnapshot.exists) {
        setState(() {
          String eventType = eventSnapshot['isGroupEvent'] ?? 'Solo';
          isSoloEvent = eventType == 'Solo';
          isDuetEvent = eventType == 'Duet';
          isTeamEvent = eventType == 'Group';
          maxTeamSize = isDuetEvent ? 2 : (isTeamEvent ? 10 : 1);
          minTeamSize = isTeamEvent ? 6 : 1;
          isLoadingEvent = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingEvent = false;
      });
      print("Error fetching event details: $e");
    }
  }

  void addTeamMember() {
    if (teamMembers.length < maxTeamSize - 1) {
      setState(() {
        teamMembers.add({'name': '', 'studentID': '', 'class': ''});
      });
    }
  }

  void removeTeamMember(int index) {
    setState(() {
      teamMembers.removeAt(index);
    });
  }

  Future<void> submitRegistration() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => isLoading = true);

  try {
    // Check if the user has already registered for this event
    QuerySnapshot existingRegistrations = await FirebaseFirestore.instance
        .collection('registrations')
        .where('eventID', isEqualTo: widget.eventID)
        .where('userID', isEqualTo: userID)
        .get();

    if (existingRegistrations.docs.isNotEmpty) {
      // User has already registered for this event
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already registered for this event.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Proceed with registration if no duplicate is found
    String registrationID = FirebaseFirestore.instance.collection('registrations').doc().id;
    String generatedQRData = registrationID;

    Map<String, dynamic> registrationData = {
      'eventID': widget.eventID,
      'userID': userID,
      'timestamp': FieldValue.serverTimestamp(),
      'qrCode': generatedQRData,
      'paymentStatus': false,
    };

    if (isSoloEvent) {
      registrationData['participantDetails'] = {
        'name': _nameController.text,
        'studentID': _studentIDController.text,
        'class': _classController.text,
      };
    } else {
      registrationData['teamDetails'] = {
        'teamName': _teamNameController.text,
        'members': teamMembers,
      };
    }

    await FirebaseFirestore.instance.collection('registrations').doc(registrationID).set(registrationData);

    _nameController.clear();
    _studentIDController.clear();
    _classController.clear();
    _teamNameController.clear();
    teamMembers.clear();

    setState(() {
      isRegistrationSuccess = true;
      isLoading = false;
    });

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  } catch (e) {
    setState(() => isLoading = false);
    print("Error registering: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration failed. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text(
          'Register for Event',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: isLoadingEvent
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : isRegistrationSuccess
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/success.json', width: 300, height: 400),
                      SizedBox(height: 20),
                      Text(
                        'Registration Successful!',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSoloEvent) _buildSoloEventFields(),
                        if (isTeamEvent || isDuetEvent) _buildTeamEventFields(),
                        SizedBox(height: 25),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                              elevation: 3,
                            ),
                            onPressed: isLoading ? null : submitRegistration,
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Register', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSoloEventFields() {
    return Column(
      children: [
        _buildInputField(controller: _nameController, label: 'Name', icon: Icons.person),
        _buildInputField(controller: _studentIDController, label: 'Student ID', icon: Icons.badge),
        _buildInputField(controller: _classController, label: 'Class', icon: Icons.class_),
      ],
    );
  }

  Widget _buildTeamEventFields() {
    return Column(
      children: [
        _buildInputField(controller: _teamNameController, label: 'Team Name', icon: Icons.group),
        SizedBox(height: 16),
        Column(
          children: teamMembers.asMap().entries.map((entry) {
            int index = entry.key;
            return _buildTeamMemberCard(index);
          }).toList(),
        ),
        if (teamMembers.length < maxTeamSize - 1)
          TextButton.icon(
            onPressed: addTeamMember,
            icon: Icon(Icons.add, color: Colors.deepPurple),
            label: Text('Add Member', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  Widget _buildTeamMemberCard(int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            _buildInputField(
              label: 'Member ${index + 1} Name',
              icon: Icons.person,
              onChanged: (val) => teamMembers[index]['name'] = val,
            ),
            _buildInputField(
              label: 'Student ID',
              icon: Icons.badge,
              onChanged: (val) => teamMembers[index]['studentID'] = val,
            ),
            _buildInputField(
              label: 'Class',
              icon: Icons.class_,
              onChanged: (val) => teamMembers[index]['class'] = val,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => removeTeamMember(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, IconData? icon, TextEditingController? controller, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (val) => val!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}