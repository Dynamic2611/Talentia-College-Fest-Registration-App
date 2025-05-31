import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String profilePhoto = "";
  String name = "";
  String email = "";
  String role = "";
  String studentId = "";
  File? _imageFile;
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user details from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            email = userDoc['email'] ?? "";
            name = userDoc['name'] ?? "";
            role = userDoc['role'] ?? "";
            studentId = userDoc['studentId'] ?? "";
            profilePhoto = userDoc['profilePhoto'] ?? "";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to update profile photo
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _imageFile = imageFile;
      });

      // Upload to Firebase Storage and update Firestore (Implement this)
    }
  }

  // Function to update name in Firestore
  Future<void> _editName() async {
    TextEditingController nameController = TextEditingController(text: name);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter new name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text;
                setState(() {
                  name = newName;
                });

                // Update name in Firestore
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({'name': newName});
                }

                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : profilePhoto.isNotEmpty
                                  ? NetworkImage(profilePhoto) as ImageProvider
                                  : AssetImage('assets/default_profile.png'),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name (Editable)
                  GestureDetector(
                    onTap: _editName,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.edit, size: 20, color: Colors.blue),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  // Email
                  _buildInfoCard(Icons.email, "Email", email),

                  // Role
                  _buildInfoCard(Icons.person, "Role", role),

                  // Student ID
                  _buildInfoCard(Icons.badge, "Student ID", studentId),
                ],
              ),
            ),
    );
  }

  // Widget for Profile Info Cards
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.black54)),
      ),
    );
  }
}
