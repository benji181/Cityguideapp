import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionExample extends StatefulWidget {
  @override
  _LocationPermissionExampleState createState() =>
      _LocationPermissionExampleState();
}

class _LocationPermissionExampleState
    extends State<LocationPermissionExample> {

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    // Check if location permission is granted
    var status = await Permission.location.status;

    if (!status.isGranted) {
      // If permission is not granted, request permission
      if (await Permission.location.request().isGranted) {
        // Permission granted
        print('Location permission granted');
      } else {
        // Permission denied
        print('Location permission denied');
      }
    } else {
      // Permission already granted
      print('Location permission already granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Permission Example'),
      ),
      body: Center(
        child: Text('Check your location permissions.'),
      ),
    );
  }
}