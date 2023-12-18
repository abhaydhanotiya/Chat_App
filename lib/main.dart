import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authenticate.dart';
import 'chat_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Chat',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // colorScheme:
        //     ColorScheme.dark(background: Color.fromRGBO(35, 34, 51, 1)),
      ),
      home: AuthenticationScreen(),
    );
  }
}
