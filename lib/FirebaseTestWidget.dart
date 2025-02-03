import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseTestWidget extends StatefulWidget {
  @override
  _FirebaseTestWidgetState createState() => _FirebaseTestWidgetState();
}

class _FirebaseTestWidgetState extends State<FirebaseTestWidget> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error during Firebase initialization: ${snapshot.error}');
          return Text('Failed to initialize Firebase: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Text('Firebase initialized successfully');
        }

        return CircularProgressIndicator();
      },
    );
  }
}

