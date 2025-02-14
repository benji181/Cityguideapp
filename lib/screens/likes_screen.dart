import 'package:cityguideapp/screens/city_selection_screen.dart';
import 'package:cityguideapp/screens/search_screen.dart';
import 'package:cityguideapp/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class LikesScreen extends StatefulWidget {
  @override
  _LikesScreenState createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  int _currentIndex = 1; // Set the initial index to 1 for LikesScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Likes')),
      body: Center(
        child: Text('Likes Screen'),
      ),



      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
            // Navigate to Home/CitySelectionScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CitySelectionScreen()), // Replace with your Home/CitySelectionScreen widget
              );
              break;
            case 1:
            // Already on LikesScreen, no action needed
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
              break;
          }
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home_sharp),
            title: Text("Cities"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border_sharp),
            title: Text("Liked cities"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person_outline_outlined),
            title: Text("My Profile"),
            selectedColor: Colors.teal,
          ), SalomonBottomBarItem(
            icon: Icon(Icons.admin_panel_settings),
            title: Text("Admin-center"),
            selectedColor: Colors.red,
          ),
        ],
      ),
    );
  }
}