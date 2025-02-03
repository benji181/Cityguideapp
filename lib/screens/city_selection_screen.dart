import 'package:flutter/material.dart';

class City {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  City({required this.id, required this.name, required this.description, required this.imageUrl});
}

class CitySelectionScreen extends StatelessWidget {
  final List<City> cities = [
    City(id: '1', name: 'New York', description: 'The Big Apple', imageUrl: 'assets/nyc.jpeg'),
    City(id: '2', name: 'London', description: 'The British Capital', imageUrl: 'assets/london.jpeg'),
    City(id: '3', name: 'Tokyo', description: 'The Land of the Rising Sun', imageUrl: 'assets/tokyo.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a City'),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.asset(
                cities[index].imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);  // Show an error icon if image fails to load
                },
              ),
              title: Text(cities[index].name),
              subtitle: Text(cities[index].description),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/attraction_list',
                  arguments: cities[index].id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

