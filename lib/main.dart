import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cityguideapp/screens/auth_screen.dart';
import 'package:cityguideapp/screens/city_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error during Firebase initialization: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/city_selection': (context) => CitySelectionScreen(),
      },
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'screens/auth_screen.dart';
// import 'screens/city_selection_screen.dart';
// import 'screens/attraction_list_screen.dart';
// import 'screens/attraction_detail_screen.dart';
// import 'screens/user_profile_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'City Guide',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: FutureBuilder(
//         future: _initialization,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             print('Error during Firebase initialization: ${snapshot.error}');
//             return Scaffold(
//               body: Center(
//                 child: Text('Failed to initialize Firebase: ${snapshot.error}'),
//               ),
//             );
//           }
//
//           if (snapshot.connectionState == ConnectionState.done) {
//             return AuthScreen();
//           }
//
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         },
//       ),
//       routes: {
//         '/city_selection': (context) => CitySelectionScreen(),
//         '/attraction_list': (context) => AttractionListScreen(),
//         '/attraction_detail': (context) => AttractionDetailScreen(),
//         '/user_profile': (context) => UserProfileScreen(),
//       },
//     );
//   }
// }
//
