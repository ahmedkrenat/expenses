import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/widgets/authentication_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase initialized');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: AuthGate(),
    );
  }
}


