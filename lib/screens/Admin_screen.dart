import 'package:cityguideapp/screens/attraction_list_screen.dart';
import 'package:cityguideapp/screens/likes_screen.dart';
import 'package:cityguideapp/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'city_selection_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 3; // Set the initial index to 1 for LikesScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildAttractionManagement(),
          Divider(), // Adding a divider for better separation
          _buildReviewManagement(),
          Divider(),
          _buildNotificationManagement(),
        ],
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LikesScreen()),
              );              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
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

  Widget _buildAttractionManagement() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Add New Attraction'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => AttractionListScreen(cityId: '', cityName: '', cityLat: 0.0, cityLng: 0.0),
              ));
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Existing Attractions'),
            onTap: () {
              // TODO: Implement edit attractions
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewManagement() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.comment),
            title: Text('Pending Reviews'),
            trailing: Badge(
              label: Text('5'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.report),
            title: Text('Reported Reviews'),
            trailing: Badge(
              label: Text('2'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationManagement() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.notification_add),
            title: Text('Send New Notification'),
            onTap: () {
              // TODO: Implement send notification
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.history),
            title: Text('Notification History'),
            onTap: () {
              // TODO: Implement notification history
            },
          ),
        ),
      ],
    );
  }
}