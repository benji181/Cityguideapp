<<<<<<< HEAD
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
=======
import 'package:flutter/material.dart';
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0

class Attraction {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String imageUrl;
<<<<<<< HEAD
  final double lat;
  final double lng;
  final String description;
  final String contactInfo;
  final String openingHours;
  final String address;
  final String website;

  Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.description,
    required this.contactInfo,
    required this.openingHours,
    required this.address,
    required this.website,
  });

  factory Attraction.fromHereAPI(Map<String, dynamic> json) {
    final position = json['position'];
    return Attraction(
      id: json['id'] ?? '',
      name: json['title'] ?? 'Unknown',
      category: json['categories']?.first?['name'] ?? 'Other',
      rating: json['averageRating']?.toDouble() ?? 0.0,
      imageUrl: json['photos']?.isNotEmpty == true
          ? json['photos'][0]['url']
          : 'https://via.placeholder.com/150?text=${Uri.encodeComponent(json['title'] ?? 'Unknown')}',
      lat: position['lat']?.toDouble() ?? 0.0,
      lng: position['lng']?.toDouble() ?? 0.0,
      description: json['editorial']?['shortDescription'] ?? 'No description available',
      contactInfo: json['contacts']?.first?['phone']?.first?['value'] ?? 'No contact information available',
      openingHours: _formatOpeningHours(json['openingHours']),
      address: json['address']['label'] ?? 'Address not available',
      website: json['contacts']?.first?['www']?.first?['value'] ?? '',
    );
  }

  static String _formatOpeningHours(dynamic hours) {
    if (hours == null) return 'Opening hours not available';
    try {
      final text = hours['text'] ?? hours['structured']?.map((h) =>
      '${h['day']}: ${h['start']}-${h['end']}')
          .join('\n');
      return text ?? 'Opening hours not available';
    } catch (e) {
      return 'Opening hours not available';
    }
  }
}

class AttractionListScreen extends StatefulWidget {
  final String cityId;
  final String cityName;
  final double cityLat;
  final double cityLng;

  AttractionListScreen({
    required this.cityId,
    required this.cityName,
    required this.cityLat,
    required this.cityLng,
  });

=======

  Attraction({required this.id, required this.name, required this.category, required this.rating, required this.imageUrl});
}

class AttractionListScreen extends StatefulWidget {
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
  @override
  _AttractionListScreenState createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
<<<<<<< HEAD
  List<Attraction> _attractions = [];
  String _selectedCategory = 'All';
  Position? _currentPosition;
  MapController _mapController = MapController();
  bool _isLoading = true;
  List<Attraction> _filteredAttractions = [];
  double _zoomLevel = 13.0;
  final String _apiKey = 'gywUzR7OETC2wSWi7bj8xZy4J4pkDIAmeaK8Xp0_UCs'; // Replace with your HERE API key

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchAttractions();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _fetchAttractions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = [
        'restaurant',
        'hotel',
        'sights-museums',
        'leisure-outdoor',
        'shopping',
        'transport',
      ];

      final attractions = <Attraction>[];

      for (final category in categories) {
        final url = Uri.parse(
            'https://discover.search.hereapi.com/v1/discover'
                '?apiKey=$_apiKey'
                '&q=$category'
                '&in=circle:${widget.cityLat},${widget.cityLng};r=5000'
                '&limit=20'
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['items'] as List;

          attractions.addAll(
              items.map((item) => Attraction.fromHereAPI(item)).toList());
        } else {
          throw Exception('Failed to load attractions');
        }
      }

      setState(() {
        _attractions = attractions;
        _filteredAttractions = attractions;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching attractions: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attractions: $e')),
      );
    }
  }

  void _filterAttractions(String query) {
    setState(() {
      _filteredAttractions = _attractions.where((attraction) {
        return attraction.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<String> _getDirections(double startLat, double startLon,
      double endLat, double endLon) async {
    final url = Uri.parse(
        'https://router.hereapi.com/v8/routes'
            '?apiKey=$_apiKey'
            '&transportMode=car'
            '&origin=$startLat,$startLon'
            '&destination=$endLat,$endLon'
            '&return=summary'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['sections'][0]['summary'];
        final duration = (route['duration'] / 60).round(); // Convert to minutes
        final distance = (route['length'] / 1000).round(); // Convert to kilometers
        return 'Duration: $duration mins\nDistance: $distance km';
      }
    } catch (e) {
      print("Error getting directions: $e");
    }
    return 'Unable to get directions';
  }

  void _showAttractionDetails(Attraction attraction) async {
    String directions = 'Calculating...';
    if (_currentPosition != null) {
      directions = await _getDirections(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        attraction.lat,
        attraction.lng,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                attraction.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported),
                  );
                },
              ),
              SizedBox(height: 16),
              Text(
                attraction.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Rating: ${attraction.rating.toStringAsFixed(1)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  RatingBar.builder(
                    initialRating: attraction.rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      // Implement rating update logic here
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text('Category: ${attraction.category}'),
              Text('Address: ${attraction.address}'),
              if (attraction.website.isNotEmpty)
                TextButton(
                  onPressed: () => _launchUrl(attraction.website),
                  child: Text('Visit Website'),
                ),
              SizedBox(height: 16),
              Text('Description: ${attraction.description}'),
              SizedBox(height: 8),
              Text('Contact: ${attraction.contactInfo}'),
              SizedBox(height: 8),
              Text('Opening Hours: ${attraction.openingHours}'),
              SizedBox(height: 16),
              Text(
                'Directions from current location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(directions),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Get Directions'),
                onPressed: () {
                  _launchMapsUrl(attraction.lat, attraction.lng);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _launchMapsUrl(double lat, double lng) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location not available')),
      );
      return;
    }

    final url = Uri.parse(
        'https://wego.here.com/directions/mix/'
            '${_currentPosition!.latitude},${_currentPosition!.longitude}/'
            '$lat,$lng'
    ).toString();

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch maps')),
      );
    }
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 1).clamp(5.0, 18.0);
      _mapController.move(_mapController.center, _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 1).clamp(5.0, 18.0);
      _mapController.move(_mapController.center, _zoomLevel);
    });
    _fetchMoreAttractions();
  }

  Future<void> _fetchMoreAttractions() async {
    final currentCenter = _mapController.center;
    final radius = 5000 * pow(2, 13 - _zoomLevel); // Adjust radius based on zoom level

    try {
      final categories = [
        'restaurant',
        'hotel',
        'sights-museums',
        'leisure-outdoor',
        'shopping',
        'transport',
      ];

      final newAttractions = <Attraction>[];

      for (final category in categories) {
        final url = Uri.parse(
            'https://discover.search.hereapi.com/v1/discover'
                '?apiKey=$_apiKey'
                '&q=$category'
                '&in=circle:${currentCenter.latitude},${currentCenter.longitude};r=$radius'
                '&limit=20'
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['items'] as List;

          newAttractions.addAll(
              items.map((item) => Attraction.fromHereAPI(item)).toList());
        }
      }

      setState(() {
        _attractions.addAll(newAttractions);
        _filteredAttractions = _attractions;
        if (_selectedCategory != 'All') {
          _filteredAttractions = _filteredAttractions
              .where((attraction) =>
          attraction.category == _selectedCategory)
              .toList();
        }
      });
    } catch (e) {
      print("Error fetching more attractions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more attractions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} Attractions'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildMapView(),
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildAttractionList(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(widget.cityLat, widget.cityLng),
              zoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _filteredAttractions.map((attraction) {
                  return Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(attraction.lat, attraction.lng),
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showAttractionDetails(attraction),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "btn1",
                  child: Icon(Icons.add),
                  onPressed: () => _zoomIn(),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: "btn2",
                  child: Icon(Icons.remove),
                  onPressed: () => _zoomOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search attractions',
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: _filterAttractions,
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', ...Set<String>.from(_attractions.map((a) => a.category))];

    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _filteredAttractions = _attractions.where((attraction) =>
                  _selectedCategory == 'All' || attraction.category == _selectedCategory)
                      .toList();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttractionList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _filteredAttractions.length,
        itemBuilder: (context, index) {
          final attraction = _filteredAttractions[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                Image.network(
                  attraction.imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
                ListTile(
                  title: Text(attraction.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(attraction.category),
                      Text(
                        attraction.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Rating: ${attraction.rating.toStringAsFixed(1)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          RatingBar.builder(
                            initialRating: attraction.rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 16,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              // Implement rating update logic here
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    _mapController.move(
                      LatLng(attraction.lat, attraction.lng),
                      _zoomLevel,
                    );
                    _showAttractionDetails(attraction);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.directions),
                    onPressed: () {
                      _launchMapsUrl(attraction.lat, attraction.lng);
                    },
                  ),
                ),
              ],
            ),
          );
        },
=======
  final List<Attraction> attractions = [
    Attraction(id: '1', name: 'Central Park', category: 'Park', rating: 4.5, imageUrl: 'https://example.com/centralpark.jpg'),
    Attraction(id: '2', name: 'Empire State Building', category: 'Landmark', rating: 4.7, imageUrl: 'https://example.com/empirestate.jpg'),
    Attraction(id: '3', name: 'The Met', category: 'Museum', rating: 4.8, imageUrl: 'https://example.com/themet.jpg'),
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<String> categories = ['All', 'Park', 'Landmark', 'Museum'];

  @override
  Widget build(BuildContext context) {
    List<Attraction> filteredAttractions = attractions.where((attraction) {
      return attraction.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          (_selectedCategory == 'All' || attraction.category == _selectedCategory);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Attractions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search attractions',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAttractions.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      filteredAttractions[index].imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(filteredAttractions[index].name),
                    subtitle: Text('${filteredAttractions[index].category} - Rating: ${filteredAttractions[index].rating}'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/attraction_detail',
                        arguments: filteredAttractions[index].id,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
>>>>>>> a29e46e1d94a96b0b2dc542a27bdb8a4910611d0
      ),
    );
  }
}

