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
    var status = await Permission.location.status;

    if (!status.isGranted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Permission Required'),
          content: Text('This app needs location access to show nearby attractions. Please grant location permission.'),
          actions: [
            TextButton(
              child: Text('Settings'),
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text('Request Permission'),
              onPressed: () async {
                Navigator.pop(context);
                final result = await Permission.location.request();
                if (result.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location permission granted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location permission denied')),
                  );
                }
              },
            ),
          ],
        ),
      );
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