import 'package:cityguideapp/screens/attraction_detail_screen.dart';
import 'package:cityguideapp/screens/attraction_list_screen.dart';
import 'package:cityguideapp/screens/city_selection_screen.dart';
import 'package:cityguideapp/screens/auth_screen.dart';
import 'package:cityguideapp/main_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cityguideapp/models/attraction.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kjfevhsjzotqifbzdhws.supabase.co',
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqZmV2aHNqem90cWlmYnpkaHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0NzkxODIsImV4cCI6MjA1NTA1NTE4Mn0.2c4vBwuBTikFcOATxoq1elJixuDnqXweMo8uF7QdPdc", // Replace with your actual anon key
  );

  await Firebase.initializeApp();
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  // );
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
        home: AuthScreen(),
        routes: {
          '/main': (context) => MainLayout(),
          '/city_selection': (context) => CitySelectionScreen(),
          '/attraction_list': (context) => AttractionListScreen(
            cityId: '',
            cityName: '',
            cityLat: 0.0,  // Default latitude
            cityLng: 0.0,  // Default longitude
          ),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/attraction_detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AttractionDetailScreen(
                attraction: args['attraction'] as Attraction,
                currentPosition: args['currentPosition'] as Position?,
              ),
            );
          }
          return null;
        }
    );
  }
}


// import 'package:cityguideapp/screens/attraction_detail_screen.dart';
// import 'package:cityguideapp/screens/attraction_list_screen.dart';
// import 'package:cityguideapp/screens/city_selection_screen.dart';
// import 'package:cityguideapp/screens/auth_screen.dart';
// import 'package:cityguideapp/main_layout.dart';
// //import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:cityguideapp/models/attraction.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Back4App
//   // final keyApplicationId = 'bhfGmys6xELtISMYTO9LDVjsrsmz5iNCiCcQrTzU';
//   // final keyClientKey = 'ArN1xCVaY5ry2oRjd0WYGOoIlean5R8VaiGKpsyU';
//   // final keyParseServerUrl = 'https://backend.back4app.com';
//   //
//   // await Parse().initialize(
//   //   keyApplicationId,
//   //   keyParseServerUrl,
//   //   clientKey: keyClientKey,
//   //   debug: true,
//   //   autoSendSessionId: true,
//   // );
//
//   //await Firebase.initializeApp();
//
//   runApp(MyApp());
// }
//
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'City Guide',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: AuthScreen(),
//         routes: {
//           '/main': (context) => MainLayout(),
//           '/city_selection': (context) => CitySelectionScreen(),
//           '/attraction_list': (context) => AttractionListScreen(
//             cityId: '',
//             cityName: '',
//             cityLat: 0.0,  // Default latitude
//             cityLng: 0.0,  // Default longitude
//           ),
//         },
//         onGenerateRoute: (settings) {
//           if (settings.name == '/attraction_detail') {
//             final args = settings.arguments as Map<String, dynamic>;
//             return MaterialPageRoute(
//               builder: (context) => AttractionDetailScreen(
//                 attraction: args['attraction'] as Attraction,
//                 currentPosition: args['currentPosition'] as Position?,
//               ),
//             );
//           }
//           return null;
//         }
//     );
//   }
// }


































//  import 'package:cityguideapp/screens/attraction_detail_screen.dart';
// import 'package:cityguideapp/screens/attraction_list_screen.dart';
// import 'package:cityguideapp/screens/city_selection_screen.dart';
// import 'package:cityguideapp/screens/auth_screen.dart';
// import 'package:cityguideapp/main_layout.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:cityguideapp/models/attraction.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // await FirebaseAppCheck.instance.activate(
//   //   androidProvider: AndroidProvider.debug,
//   // );
//   runApp(MyApp());
// }
//
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'City Guide',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: AuthScreen(),
//         routes: {
//           '/main': (context) => MainLayout(),
//           '/city_selection': (context) => CitySelectionScreen(),
//           '/attraction_list': (context) => AttractionListScreen(
//             cityId: '',
//             cityName: '',
//             cityLat: 0.0,  // Default latitude
//             cityLng: 0.0,  // Default longitude
//           ),
//         },
//         onGenerateRoute: (settings) {
//           if (settings.name == '/attraction_detail') {
//             final args = settings.arguments as Map<String, dynamic>;
//             return MaterialPageRoute(
//               builder: (context) => AttractionDetailScreen(
//                 attraction: args['attraction'] as Attraction,
//                 currentPosition: args['currentPosition'] as Position?,
//               ),
//             );
//           }
//           return null;
//         }
//     );
//   }
// }
//
//
// // import 'package:cityguideapp/screens/attraction_detail_screen.dart';
// // import 'package:cityguideapp/screens/attraction_list_screen.dart';
// // import 'package:cityguideapp/screens/city_selection_screen.dart';
// // import 'package:cityguideapp/screens/auth_screen.dart';
// // import 'package:cityguideapp/main_layout.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:cityguideapp/models/attraction.dart';
// //
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // Initialize Back4App
// //   // final keyApplicationId = 'bhfGmys6xELtISMYTO9LDVjsrsmz5iNCiCcQrTzU';
// //   // final keyClientKey = 'ArN1xCVaY5ry2oRjd0WYGOoIlean5R8VaiGKpsyU';
// //   // final keyParseServerUrl = 'https://backend.back4app.com';
// //   //
// //   // await Parse().initialize(
// //   //   keyApplicationId,
// //   //   keyParseServerUrl,
// //   //   clientKey: keyClientKey,
// //   //   debug: true,
// //   //   autoSendSessionId: true,
// //   // );
// //
// //   await Firebase.initializeApp();
// //
// //   runApp(MyApp());
// // }
// //
// //
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //         title: 'City Guide',
// //         theme: ThemeData(
// //           primarySwatch: Colors.blue,
// //           visualDensity: VisualDensity.adaptivePlatformDensity,
// //         ),
// //         home: AuthScreen(),
// //         routes: {
// //           '/main': (context) => MainLayout(),
// //           '/city_selection': (context) => CitySelectionScreen(),
// //           '/attraction_list': (context) => AttractionListScreen(
// //             cityId: '',
// //             cityName: '',
// //             cityLat: 0.0,  // Default latitude
// //             cityLng: 0.0,  // Default longitude
// //           ),
// //         },
// //         onGenerateRoute: (settings) {
// //           if (settings.name == '/attraction_detail') {
// //             final args = settings.arguments as Map<String, dynamic>;
// //             return MaterialPageRoute(
// //               builder: (context) => AttractionDetailScreen(
// //                 attraction: args['attraction'] as Attraction,
// //                 currentPosition: args['currentPosition'] as Position?,
// //               ),
// //             );
// //           }
// //           return null;
// //         }
// //     );
// //   }
// // }