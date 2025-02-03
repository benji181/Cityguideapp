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