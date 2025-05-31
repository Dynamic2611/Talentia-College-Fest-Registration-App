import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talentia/Admin/admin_page.dart';
import 'package:talentia/Student/NotificationTile.dart';
import 'package:talentia/Student/student_page.dart';
import 'package:talentia/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize(); // 🔥 Initialize notifications first
  
  final FirebaseAuth auth = FirebaseAuth.instance;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  final User? user = auth.currentUser;
  final String? loginType = prefs.getString('loginType');

  Widget startScreen;
  if (user != null && loginType != null) {
    startScreen = (loginType == 'admin') ? AdminHomePage() : TalentiaApp(name: prefs.getString('userName') ?? 'Student');
  } else {
    startScreen = TalentiaUI();
  }

  runApp(MyApp(startScreen: startScreen));
}


class MyApp extends StatelessWidget {
  final Widget startScreen;
  MyApp({required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: startScreen,
    );
  }
}
