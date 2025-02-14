import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Admin_screen.dart';
import 'city_selection_screen.dart';
import 'likes_screen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _currentIndex = 2; // Set the initial index to 1 for LikesScreen

  final _formKey = GlobalKey<FormState>();
  final firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _name = '';
  String _email = '';
  String? _profileImageUrl;
  String _phoneNumber = '';
  File? _imageFile;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _isEditing = false;
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      setState(() {
        _email = currentUser!.email ?? 'No email available';
      });

      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', currentUser!.uid)
            .maybeSingle();

        if (response != null) {
          setState(() {
            _name = response['name'] ?? '';
            _phoneNumber = response['phone_number'] ?? '';
            _profileImageUrl = response['profile_image_url'];
            _notificationsEnabled = response['notifications_enabled'] ?? false;
            _darkModeEnabled = response['dark_mode_enabled'] ?? false;
            _nameController.text = _name;
            _phoneController.text = _phoneNumber;
          });
        } else {
          await _supabase.from('users').insert({
            'id': currentUser!.uid,
            'email': _email,
            'name': '',
            'phone_number': '',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          setState(() {
            _name = '';
            _phoneNumber = '';
            _profileImageUrl = null;
            _nameController.text = _name;
            _phoneController.text = _phoneNumber;
          });

          print(
              "New user created in Supabase with Firebase UID: ${currentUser!.uid}");
        }
      } catch (e) {
        print('Error loading/creating user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      print("Firebase UID: ${currentUser!.uid}");
      try {
        await _supabase.from('users').upsert({
          'id': currentUser!.uid,
          'email': _email,
          'name': _nameController.text,
          'phone_number': _phoneController.text,
          'notifications_enabled': _notificationsEnabled,
          'dark_mode_enabled': _darkModeEnabled,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentUser!.uid);

        setState(() {
          _name = _nameController.text;
          _phoneNumber = _phoneController.text;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploadingImage = true;
      });

      try {
        final bytes = await _imageFile!.readAsBytes();
        final fileExt = pickedFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${currentUser!.uid}/$fileName';

        await Supabase.instance.client.storage.from('profiles').uploadBinary(filePath, bytes);
        final imageUrl = _supabase.storage
            .from('profiles')
            .getPublicUrl(filePath);

        await _supabase.from('users').upsert({
          'id': currentUser!.uid,
          'email': _email,
          'profile_image_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentUser!.uid);

        setState(() {
          _profileImageUrl = imageUrl;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully!')),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' sorry ,Failed to upload image: $e')),
        );
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('User Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: _profileImageUrl != null
                                ? Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white)
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                  Icon(Icons.person,
                                      size: 60, color: Colors.white),
                            )
                                : Icon(Icons.person,
                                size: 60, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.brown),
                              onPressed:
                              _isUploadingImage ? null : _pickAndUploadImage,
                            ),
                          ),
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      _name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _email,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Kindly input your name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabled: _isEditing,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Kindly input your mobile number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabled: _isEditing,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    SwitchListTile(
                      title: Text('Enable Notifications'),
                      value: _notificationsEnabled,
                      onChanged: _isEditing
                          ? (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      }
                          : null,
                      activeColor: Colors.brown,
                    ),
                    SwitchListTile(
                      title: Text('Dark Mode'),
                      value: _darkModeEnabled,
                      onChanged: _isEditing
                          ? (bool value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      }
                          : null,
                      activeColor: Colors.brown,
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 16 ,color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
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
              );
              break;
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
}