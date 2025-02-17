import 'package:cityguideapp/screens/EditAttractionsScreen.dart';
import 'package:cityguideapp/screens/attraction_list_screen.dart';
import 'package:cityguideapp/screens/likes_screen.dart';
import 'package:cityguideapp/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:firebase_auth/firebase_auth.dart'; //Import Firebase Auth

import 'city_selection_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 3;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  void _showAddAttractionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Attraction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addNewAttraction();
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewAttraction() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Validate input data
      if (_nameController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _categoryController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await Supabase.instance.client
          .from('attractions')
          .insert({
        'name': _nameController.text,
        'address': _addressController.text,
        'category': _categoryController.text,
        'created_by': user.uid,
      });

      // Hide loading indicator and clear fields
      Navigator.of(context).pop();
      _nameController.clear();
      _addressController.clear();
      _categoryController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attraction added successfully!')),
      );
    } catch (e) {
      // Hide loading indicator if it's still showing
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding attraction: ${e.toString()}')),
        );
      }
    }
  }

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
              _showAddAttractionDialog();
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Existing Attractions'),
            onTap: () {
             Navigator.push(
             context,
               MaterialPageRoute(builder: (context) => EditAttractionsScreen()),
                );
            }
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