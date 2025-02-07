<<<<<<< HEAD
import 'package:cityguideapp/screens/attraction_detail_screen.dart';
import 'package:cityguideapp/screens/attraction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cityguideapp/screens/city_selection_screen.dart';
import 'package:cityguideapp/screens/auth_screen.dart';
import 'package:cityguideapp/main_layout.dart';
import 'package:cityguideapp/screens/attraction_detail_screen.dart' as detailScreen;
import 'package:cityguideapp/screens/attraction_list_screen.dart' as listScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
=======
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
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
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
<<<<<<< HEAD
      home: AuthScreen(),
      // The home property defines the initial screen

      routes: {
        '/main': (context) => MainLayout(),
        '/city_selection': (context) => CitySelectionScreen(),
        '/attraction_list': (context) => AttractionListScreen(
          cityId: '',
          cityName: '',
          cityLat: 0.0,  // Default latitude
          cityLng: 0.0,  // Default longitude
        ),
        '/attraction_detail': (context) =>
            AttractionDetailScreen(
              attractionId: ModalRoute
                  .of(context)!
                  .settings
                  .arguments as String,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/attraction_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                AttractionDetailScreen(
                  attractionId: args['attractionId'] as String,
                ),
          );
        }
        return null;
      },
    );
  }
}
=======
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
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
