import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cityguideapp/models/attraction.dart';


class AttractionDetailScreen extends StatefulWidget {
  final Attraction attraction;
  late final Position? currentPosition;

  AttractionDetailScreen({
    required this.attraction,
    this.currentPosition,
  });

  @override
  _AttractionDetailScreenState createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  bool _isLoading = false;
  List<LatLng> _routePoints = [];
  final String _hereApiKey = 'puSI3dzJ263diYCcXINNhmrqDfp0ZeM_Wjv3c07_VKQ';


  @override
  void initState() {
    super.initState();
    if (widget.currentPosition != null) {
      _getDirections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attraction.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.attraction.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.attraction.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Category: ${widget.attraction.category}'),
                  Text('Address: ${widget.attraction.address}'),
                  Text('Opening Hours: ${widget.attraction.openingHours}'),
                  SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.attraction.rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.attraction.description),
                  SizedBox(height: 16),
                  Text(
                    'Contact Information:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.attraction.contactInfo),
                  SizedBox(height: 16),
                  Text(
                    'Location and Directions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your starting location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          final coordinates = await _geocodeAddress(value);
                          if (coordinates != null) {
                            setState(() {
                              widget.currentPosition = Position(
                                longitude: coordinates[1],
                                latitude: coordinates[0],
                                timestamp: DateTime.now(),
                                accuracy: 0,
                                altitude: 0,
                                heading: 0,
                                speed: 0,
                                speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
                              );
                            });
                            _getDirections();
                          }
                        }
                      },
                    ),
                  ),
                  Container(
                    height: 300,
                    child: _buildMap(),
                  ),
                  SizedBox(height: 16),
                  if (widget.currentPosition == null)
                    ElevatedButton(
                      child: Text('Get Directions'),
                      onPressed: () async {
                        Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );
                        setState(() {
                          widget.currentPosition = position;
                        });
                        _getDirections();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(widget.attraction.lat, widget.attraction.lng),
        zoom: 13.0,
      ),
      nonRotatedChildren: [
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                child: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    final controller = MapController();
                    controller.move(
                      LatLng(widget.attraction.lat, widget.attraction.lng),
                      controller.zoom + 1,
                    );
                  });
                },
              ),
              SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                child: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    final controller = MapController();
                    controller.move(
                      LatLng(widget.attraction.lat, widget.attraction.lng),
                      controller.zoom - 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ],
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
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(widget.attraction.lat, widget.attraction.lng),
              builder: (ctx) => Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
            if (widget.currentPosition != null)
              Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
                builder: (ctx) => Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40.0,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<List<double>?> _geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://geocoder.ls.hereapi.com/6.2/geocode.json?searchtext=${Uri.encodeComponent(address)}&apiKey=$_hereApiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['Response']['View'][0]['Result'][0]['Location']['NavigationPosition'][0];
        return [location['Latitude'], location['Longitude']];
      }
    } catch (e) {
      print('Error geocoding address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not find location. Please try again.')),
      );
    }
    return null;
  }

  Future<void> _getDirections() async {
    if (widget.currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://router.hereapi.com/v8/routes?transportMode=car&origin=${widget.currentPosition!.latitude},${widget.currentPosition!.longitude}&destination=${widget.attraction.lat},${widget.attraction.lng}&return=polyline&apiKey=$_hereApiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<LatLng> points = [];
        final String encodedPolyline = data['routes'][0]['sections'][0]['polyline'];

        final List<PointLatLng> decodedPolyline = PolylinePoints().decodePolyline(encodedPolyline);

        points.addAll(decodedPolyline.map((point) => LatLng(point.latitude, point.longitude)));

        setState(() {
          _routePoints = points;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      print('Error getting directions: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting directions. Please try again.')),
      );
    }
  }
}