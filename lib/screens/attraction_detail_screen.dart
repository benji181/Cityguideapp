import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';

const String apiKey = 'YOUR_FOURSQUARE_API_KEY';

class AttractionDetailScreen extends StatefulWidget {
  final String attractionId;

  AttractionDetailScreen({required this.attractionId});

  @override
  _AttractionDetailScreenState createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  Attraction? _attraction;
  bool _isLoading = true;
  String? _error;
  Position? _userLocation;
  List<String> _directions = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchAttractionDetails();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() => _userLocation = position);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchAttractionDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = 'https://nominatim.openstreetmap.org/details.php?osmtype=N&osmid=${widget.attractionId}&format=json';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'YourAppName/1.0'},  // Required by OSM
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tags = data['addresstags'] ?? {};
        final names = data['names'] ?? {};
        final extratags = data['extratags'] ?? {};

        setState(() {
          _attraction = Attraction(
            id: widget.attractionId,
            name: names['name'] ?? tags['name'] ?? 'Unknown',
            category: extratags['tourism'] ?? extratags['amenity'] ?? 'Other',
            rating: double.tryParse(extratags['rating'] ?? '0') ?? 0.0,
            photos: _getWikimediaPhotos(extratags['image'] ?? ''),
            lat: double.parse(data['lat']),
            lng: double.parse(data['lon']),
            description: extratags['description'] ?? 'No description available',
            contactInfo: extratags['phone'] ?? extratags['contact:phone'] ?? 'No contact information available',
            openingHours: extratags['opening_hours'] ?? 'Hours not available',
            tips: [],
          );
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load attraction');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<String> _getWikimediaPhotos(String imageUrl) {
    if (imageUrl.isEmpty) return [];
    return [imageUrl];
  }

  List<String> _parsePhotos(List<dynamic> photos) {
    return photos.map<String>((photo) =>
    "${photo['prefix']}original${photo['suffix']}"
    ).toList();
  }

  List<String> _parseTips(List<dynamic> tips) {
    return tips.map<String>((tip) => tip['text'] as String).toList();
  }

  String _formatHours(Map<String, dynamic> hours) {
    if (hours.isEmpty) return 'Hours not available';
    return hours['display'] ?? 'Hours not available';
  }

  Future<void> _getDirections() async {
    if (_userLocation == null || _attraction == null) return;

    try {
      final url = 'https://api.openrouteservice.org/v2/directions/driving-car'
          '?start=${_userLocation!.longitude},${_userLocation!.latitude}'
          '&end=${_attraction!.lng},${_attraction!.lat}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'YOUR_OPENROUTE_API_KEY'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _directions = _parseDirections(data['features'][0]['properties']['segments']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get directions')),
      );
    }
  }

  List<String> _parseDirections(List<dynamic> segments) {
    List<String> steps = [];
    for (var segment in segments) {
      for (var step in segment['steps']) {
        steps.add(step['instruction']);
      }
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchAttractionDetails,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(_attraction?.name ?? 'Loading...'),
                background: _attraction?.photos.isNotEmpty == true
                    ? PageView.builder(
                  itemCount: _attraction!.photos.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: _attraction!.photos[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    );
                  },
                )
                    : Container(color: Colors.grey),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            ElevatedButton(
              onPressed: _fetchAttractionDetails,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _attraction!.category,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _attraction!.rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (_) {},
              ),
              SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(_attraction!.description),
              SizedBox(height: 16),
              Text(
                'Opening Hours',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(_attraction!.openingHours),
            ],
          ),
        ),
        Container(
          height: 300,
          child: GestureDetector(
            onTap: () => _showFullScreenMap(context),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(_attraction!.lat, _attraction!.lng),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(_attraction!.lat, _attraction!.lng),
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    if (_userLocation != null)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(
                          _userLocation!.latitude,
                          _userLocation!.longitude,
                        ),
                        builder: (ctx) => Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _getDirections,
                icon: Icon(Icons.directions),
                label: Text('Get Directions'),
              ),
              if (_directions.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Directions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _directions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(_directions[index]),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Map View')),
          body: FlutterMap(
            options: MapOptions(
              center: LatLng(_attraction!.lat, _attraction!.lng),
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(_attraction!.lat, _attraction!.lng),
                    builder: (ctx) => Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Attraction {
  final String id;
  final String name;
  final String category;
  final double rating;
  final List<String> photos;
  final double lat;
  final double lng;
  final String description;
  final String contactInfo;
  final String openingHours;
  final List<String> tips;

  Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.photos,
    required this.lat,
    required this.lng,
    required this.description,
    required this.contactInfo,
    required this.openingHours,
    required this.tips,
  });
}