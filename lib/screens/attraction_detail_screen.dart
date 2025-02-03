import 'package:flutter/material.dart';

class AttractionDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String attractionId = ModalRoute.of(context)!.settings.arguments as String;
    // In a real app, you would fetch the attraction details based on the ID
    final attraction = {
      'id': '1',
      'name': 'Central Park',
      'description': 'An urban oasis in the heart of New York City.',
      'image': 'https://example.com/centralpark.jpg',
      'rating': 4.5,
      'address': 'Central Park, New York, NY',
      'openingHours': '6:00 AM - 1:00 AM',
      'website': 'https://www.centralparknyc.org/',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(attraction['name'] as String),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              attraction['image'] as String,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attraction['name'] as String,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(attraction['description'] as String),
                  SizedBox(height: 16),
                  Text('Rating: ${attraction['rating']}'),
                  Text('Address: ${attraction['address']}'),
                  Text('Opening Hours: ${attraction['openingHours']}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement directions
                      print('Implement directions');
                    },
                    child: Text('Get Directions'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement website opening
                      print('Implement website opening');
                    },
                    child: Text('Visit Website'),
                  ),
                ],
              ),
            ),
            // TODO: Add a map component here
            // TODO: Add a reviews section here
          ],
        ),
      ),
    );
  }
}

