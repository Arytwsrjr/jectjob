import 'package:flutter/material.dart';
//import 'package:planner/screens/home/coding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planner/screens/home/login.dart';

// แก้ path นี้ให้ตรงกับตำแหน่งไฟล์ home.dart ของคุณ
//import 'package:planner/screens/home/home.dart';
//import 'package:planner/screens/home/sum.dart';
//import 'package:planner/screens/home/focus.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Planner App',
      home: Login(),
    );
  }
}
