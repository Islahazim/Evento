import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evento/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase here
  runApp(EventoApp());
}

class EventoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evento',
      home: LoginPage(),
    );
  }
}
