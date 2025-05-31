import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talentia/Admin/admin_page.dart';
import 'package:talentia/Student/student_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _loginType;

  final RegExp studentEmailRegex =
      RegExp(r'^[a-z]+\.[a-z]+\.[0-9]+@ves\.ac\.in$');
  final RegExp adminEmailRegex = RegExp(r'^[a-z]+\.[a-z]+@ves\.ac\.in$');

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleAuth =
            await account.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final email = user.email;

          if (!email!.endsWith('@ves.ac.in')) {
            _showErrorDialog('Only emails with @ves.ac.in domain are allowed.');
            await _googleSignIn.signOut();
            return;
          }

          final SharedPreferences prefs = await SharedPreferences.getInstance();

          // Extract student ID from email
          RegExp studentIdRegex = RegExp(r'\d{7}');
          String? studentId = studentIdRegex.stringMatch(email);

          // Save FCM token
          String fcmToken = await _getFCMToken();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': user.displayName,
            'email': user.email,
            'profilePhoto': user.photoURL,
            'studentId': studentId ?? 'N/A',
            'role': _loginType,
            'uid': user.uid,
            'fcmToken': fcmToken,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          if (_loginType == 'admin' && adminEmailRegex.hasMatch(email)) {
            await prefs.setString('loginType', 'admin');
            _navigateToAdminDashboard();
          } else if (_loginType == 'student' &&
              studentEmailRegex.hasMatch(email)) {
            await prefs.setString('loginType', 'student');
            _navigateToStudentDashboard(user.displayName ?? 'Student');
          } else {
            _showErrorDialog('Invalid email format for the selected role.');
          }
        }
      }
    } catch (error) {
      _showErrorDialog('Sign-In Failed: ${error.toString()}');
    }
  }

  Future<String> _getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return await messaging.getToken() ?? '';
  }

  void _navigateToAdminDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminHomePage()),
    );
  }

  void _navigateToStudentDashboard(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalentiaApp(name: name),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur
          Image.asset(
            "assets/collage.jpg",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Apply a dark gradient overlay on top of the image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.7, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        height: screenHeight * 0.18,
                        width: screenHeight * 0.18,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 190, 134, 134).withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset('assets/talentia_logo.png'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  "TALENTIA",
                  style: TextStyle(
                    fontSize: screenWidth * 0.10,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 3.0,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 15),
                _buildLoginButton(
                  label: 'Login as Admin',
                  icon: Icons.admin_panel_settings,
                  gradientColors: [Colors.orange[800]!, Colors.orange[300]!],
                  onPressed: () {
                    // Set the login type to admin and handle sign-in
                    // setState(() {
                    //   _loginType = 'admin';
                    // });
                    // _handleGoogleSignIn();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminHomePage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildLoginButton(
                  label: 'Login as Student',
                  icon: Icons.school,
                  gradientColors: [Colors.blue[600]!, Colors.blue[300]!],
                  onPressed: () {
                    // Set the login type to student and handle sign-in
                    setState(() {
                      _loginType = 'student';
                    });
                    _handleGoogleSignIn();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
