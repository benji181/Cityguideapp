import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Attraction {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String imageUrl;
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
      imageUrl: 'https://via.placeholder.com/150', // We'll update this later
      lat: position?['lat']?.toDouble() ?? 0.0,
      lng: position?['lng']?.toDouble() ?? 0.0,
      description: json['description'] ?? 'No description available',
      contactInfo: json['contacts']?.first?['phone']?.first?['value'] ?? 'No contact information available',
      openingHours: _formatOpeningHours(json['openingHours']),
      address: json['address']['label'] ?? 'Address not available',
      website: json['contacts']?.first?['www']?.first?['value'] ?? '',
    );
  }

  static String _formatOpeningHours(dynamic hours) {
    if (hours == null) return 'Opening hours not available';
    // Format opening hours from HERE API response
    try {
      final text = hours['text'] ?? hours['structured']?.map((h) =>
      '${h['day']}: ${h['start']}-${h['end']}').join('\n');
      return text ?? 'Opening hours not available';
    } catch (e) {
      return 'Opening hours not available';
    }
  }

  Attraction copyWith({String? imageUrl}) {
    return Attraction(
      id: this.id,
      name: this.name,
      category: this.category,
      rating: this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      lat: this.lat,
      lng: this.lng,
      description: this.description,
      contactInfo: this.contactInfo,
      openingHours: this.openingHours,
      address: this.address,
      website: this.website,
    );
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

  @override
  _AttractionListScreenState createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
  List<Attraction> _attractions = [];
  String _selectedCategory = 'All';
  Position? _currentPosition;
  MapController _mapController = MapController();
  bool _isLoading = true;
  List<Attraction> _filteredAttractions = [];
  double _zoomLevel = 13.0;
  final String _apiKey = 'gywUzR7OETC2wSWi7bj8xZy4J4pkDIAmeaK8Xp0_UCs'; // Replace with your HERE API key
  final String _unsplashApiKey = 'rAJe0q86-WJBOOnSk4PbCIZUQK1vkJLX0XP5880I90g'; // Replace with your Unsplash API key
  List<LatLng> _routePoints = [];
  List<String> _routeInstructions = [];


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
        'leisure-outdoor',
        'sights-museums',
        'shopping',
        'transport'
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
              items.map((item) => Attraction.fromHereAPI(item)).toList()
          );
        }
      }

      // Fetch images for attractions
      final attractionsWithImages = await Future.wait(
          attractions.map((attraction) async {
            final imageUrl = await _getImageUrlFromUnsplash(attraction.name);
            return attraction.copyWith(imageUrl: imageUrl);
          })
      );

      setState(() {
        _attractions = attractionsWithImages;
        _filteredAttractions = attractionsWithImages;
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

  Future<String> _getImageUrlFromUnsplash(String query) async {
    final url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$query&client_id=$_unsplashApiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results.first['urls']['small'];
        }
      }
    } catch (e) {
      print("Error fetching image from Unsplash: $e");
    }
    return 'https://via.placeholder.com/150';
  }

  void _filterAttractions(String query) {
    setState(() {
      _filteredAttractions = _attractions.where((attraction) {
        return attraction.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _getDirections(double startLat, double startLon, double endLat, double endLon) async {
    final url = Uri.parse(
        'https://router.hereapi.com/v8/routes'
            '?apiKey=$_apiKey'
            '&transportMode=car'
            '&origin=$startLat,$startLon'
            '&destination=$endLat,$endLon'
            '&return=polyline,actions,instructions'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['sections'][0];

        // Parse polyline
        final polyline = route['polyline'];
        final points = PolylinePoints().decodePolyline(polyline);
        setState(() {
          _routePoints = points.map((point) => LatLng(point.latitude, point.longitude)).toList();
        });

        // Parse instructions
        final actions = route['actions'] as List;
        setState(() {
          _routeInstructions = actions.map((action) => action['instruction'] as String).toList();
        });

        // Update map to show the route
        _mapController.fitBounds(
          LatLngBounds.fromPoints(_routePoints),
          options: FitBoundsOptions(padding: EdgeInsets.all(50.0)),
        );
      }
    } catch (e) {
      print("Error getting directions: $e");
    }
  }

  void _showAttractionDetails(Attraction attraction) async {
    if (_currentPosition != null) {
      await _getDirections(
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
              if (attraction.imageUrl.isNotEmpty)
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
              Text('Category: ${attraction.category}'),
              Text('Address: ${attraction.address}'),
              if (attraction.website.isNotEmpty)
                TextButton(
                  onPressed: () => _launchUrl(attraction.website),
                  child: Text('Visit Website'),
                ),
              SizedBox(height: 8),
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
              SizedBox(height: 16),
              Text('Description: ${attraction.description}'),
              SizedBox(height: 8),
              Text('Contact: ${attraction.contactInfo}'),
              SizedBox(height: 8),
              Text('Opening Hours: ${attraction.openingHours}'),
              SizedBox(height: 16),
              Text(
                'Directions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _routeInstructions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('${index + 1}. ${_routeInstructions[index]}'),
                    );
                  },
                ),
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

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
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
    return Stack(
      children: [
        Container(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(widget.cityLat, widget.cityLng),
              zoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  ..._filteredAttractions.map((attraction) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(attraction.lat, attraction.lng),
                      builder: (ctx) => Container(
                        child: IconButton(
                          icon: Icon(Icons.location_on),
                          color: Colors.red,
                          iconSize: 45.0,
                          onPressed: () {
                            _showAttractionDetails(attraction);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            children: [
              FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: _zoomIn,
                mini: true,
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                child: Icon(Icons.remove),
                onPressed: _zoomOut,
                mini: true,
              ),
            ],
          ),
        ),
      ],
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

    return SizedBox(
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
            child: ListTile(
              leading: Image.network(
                attraction.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported);
                },
              ),
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
                  // _launchMapsUrl(attraction.lat, attraction.lng);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

