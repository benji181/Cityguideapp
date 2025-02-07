import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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
  });
}

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

  @override
  void initState() {
    super.initState();
    _fetchAttractionDetails();
  }

  Future<void> _fetchAttractionDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final query = '''
        [out:json];
        node(${widget.attractionId});
        out body;
      ''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        if (elements.isNotEmpty) {
          final element = elements[0];
          final tags = element['tags'] as Map<String, dynamic>;

          setState(() {
            _attraction = Attraction(
              id: widget.attractionId,
              name: tags['name'] ?? 'Unknown',
              category: _getCategoryFromTags(tags),
              rating: (tags['rating'] != null) ? double.parse(tags['rating']) : 0.0,
              imageUrl: tags['image'] ?? 'https://via.placeholder.com/150',
              lat: element['lat'],
              lng: element['lon'],
              description: tags['description'] ?? 'No description available',
              contactInfo: tags['phone'] ?? 'No contact information available',
              openingHours: tags['opening_hours'] ?? 'Opening hours not available',
            );
            _isLoading = false;
          });
        } else {
          throw Exception('Attraction not found');
        }
      } else {
        throw Exception('Failed to load attraction details');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getCategoryFromTags(Map<String, dynamic> tags) {
    if (tags['tourism'] == 'hotel') return 'Hotel';
    if (tags['amenity'] == 'restaurant') return 'Restaurant';
    if (tags['tourism'] != null) return 'Attraction';
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_attraction?.name ?? 'Attraction Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _attraction!.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.image_not_supported)),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              _attraction!.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text('Category: ${_attraction!.category}'),
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
              onRatingUpdate: (rating) {
                // Implement rating update logic here
              },
            ),
            SizedBox(height: 16),
            Text('Description: ${_attraction!.description}'),
            SizedBox(height: 8),
            Text('Contact: ${_attraction!.contactInfo}'),
            SizedBox(height: 8),
            Text('Opening Hours: ${_attraction!.openingHours}'),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Get Directions'),
              onPressed: () {
                _launchMapsUrl(_attraction!.lat, _attraction!.lng);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _launchMapsUrl(double lat, double lng) async {
    final url = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=15/$lat/$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

