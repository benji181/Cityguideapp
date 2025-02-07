import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:cityguideapp/screens/likes_screen.dart';
import 'package:cityguideapp/screens/user_profile_screen.dart';
import 'package:cityguideapp/screens/attraction_list_screen.dart';
=======
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0

class City {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
<<<<<<< HEAD
  final double lat;
  final double lng;

  City({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.lat,
    required this.lng,
  });
}

class CitySelectionScreen extends StatefulWidget {
  @override
  _CitySelectionScreenState createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  int _currentIndex = 0;
  List<City> cities = [
    City(
        id: '1',
        name: 'Lagos',
        description: 'Eko-akete',
        imageUrl: 'assets/lagos.jpg',
        lat: 6.5244,
        lng: 3.3792
    ),
    City(
        id: '2',
        name: 'London',
        description: 'The British Capital',
        imageUrl: 'assets/london.jpeg',
        lat: 51.5074,
        lng: -0.1278
    ),
    City(
        id: '3',
        name: 'Tokyo',
        description: 'The Land of the Rising Sun',
        imageUrl: 'assets/tokyo.jpeg',
        lat: 35.6762,
        lng: 139.6503
    ),
    City(
        id: '4',
        name: 'Paris',
        description: 'The City of Light',
        imageUrl: 'assets/paris.jpg',
        lat: 48.8566,
        lng: 2.3522
    ),
    City(
        id: '5',
        name: 'Berlin',
        description: 'The Capital of Germany',
        imageUrl: 'assets/berlin.jpg',
        lat: 52.5200,
        lng: 13.4050
    ),
    City(
        id: '6',
        name: 'Sydney',
        description: 'The Harbour City',
        imageUrl: 'assets/sydney.jpg',
        lat: -33.8688,
        lng: 151.2093
    ),
    City(
        id: '7',
        name: 'Mumbai',
        description: 'The City of Dreams',
        imageUrl: 'assets/mumbai.jpg',
        lat: 19.0760,
        lng: 72.8777
    ),
    City(
        id: '8',
        name: 'Cairo',
        description: 'The City of a Thousand Minarets',
        imageUrl: 'assets/cairo.jpg',
        lat: 30.0444,
        lng: 31.2357
    ),
    City(
        id: '9',
        name: 'Rome',
        description: 'The Eternal City',
        imageUrl: 'assets/rome.jpg',
        lat: 41.9028,
        lng: 12.4964
    ),
    City(
        id: '10',
        name: 'Moscow',
        description: 'The Heart of Russia',
        imageUrl: 'assets/moscow.jpg',
        lat: 55.7558,
        lng: 37.6173
    ),
    City(
        id: '11',
        name: 'Rio de Janeiro',
        description: 'The Marvelous City',
        imageUrl: 'assets/rio.jpg',
        lat: -22.9068,
        lng: -43.1729
    ),
    City(
        id: '12',
        name: 'Barcelona',
        description: 'The Catalonia Capital',
        imageUrl: 'assets/barcelona.jpg',
        lat: 41.3851,
        lng: 2.1734
    ),
    City(
        id: '13',
        name: 'Singapore',
        description: 'The Lion City',
        imageUrl: 'assets/singapore.jpg',
        lat: 1.3521,
        lng: 103.8198
    ),
    City(
        id: '14',
        name: 'Seoul',
        description: 'The Capital of South Korea',
        imageUrl: 'assets/seoul.jpg',
        lat: 37.5665,
        lng: 126.9780
    ),
    City(
        id: '15',
        name: 'Bangkok',
        description: 'The City of Angels',
        imageUrl: 'assets/bangkok.jpg',
        lat: 13.7563,
        lng: 100.5018
    ),
    City(
        id: '16',
        name: 'Dubai',
        description: 'The City of Gold',
        imageUrl: 'assets/dubai.jpg',
        lat: 25.2048,
        lng: 55.2708
    ),
    City(
        id: '17',
        name: 'New York',
        description: 'The Big Apple',
        imageUrl: 'assets/nyc.jpeg',
        lat: 40.7128,
        lng: -74.0060
    ),
=======

  City({required this.id, required this.name, required this.description, required this.imageUrl});
}

class CitySelectionScreen extends StatelessWidget {
  final List<City> cities = [
    City(id: '1', name: 'New York', description: 'The Big Apple', imageUrl: 'assets/nyc.jpeg'),
    City(id: '2', name: 'London', description: 'The British Capital', imageUrl: 'assets/london.jpeg'),
    City(id: '3', name: 'Tokyo', description: 'The Land of the Rising Sun', imageUrl: 'assets/tokyo.jpeg'),
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: Colors.brown,
        title: Text(
          'Select a City',
          textAlign: TextAlign.end,
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 2
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_sharp, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CitySearchDelegate(cities),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttractionListScreen(
                    cityId: cities[index].id,
                    cityName: cities[index].name,
                    cityLat: cities[index].lat,
                    cityLng: cities[index].lng,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        cities[index].imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.error, color: Colors.red));
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cities[index].name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          cities[index].description,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
=======
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
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
            ),
          );
        },
      ),
<<<<<<< HEAD
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
            // Already on Home/CitySelectionScreen
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => LikesScreen()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen()));
              break;
          }
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.brown,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("Likes"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class CitySearchDelegate extends SearchDelegate<City> {
  final List<City> cities;

  CitySearchDelegate(this.cities);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, City(
          id: '',
          name: '',
          description: '',
          imageUrl: '',
          lat: 0,
          lng: 0,
        ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? cities
        : cities.where((city) => city.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].name),
          subtitle: Text(suggestionList[index].description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttractionListScreen(
                  cityId: suggestionList[index].id,
                  cityName: suggestionList[index].name,
                  cityLat: suggestionList[index].lat,
                  cityLng: suggestionList[index].lng,
                ),
              ),
            );
          },
        );
      },
=======
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
    );
  }
}

