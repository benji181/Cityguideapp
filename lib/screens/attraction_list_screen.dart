import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cityguideapp/models/attraction.dart';
import 'package:cityguideapp/screens/attraction_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionListScreen extends StatefulWidget {
  final String cityId;
  final String cityName;
  final double cityLat;
  final double cityLng;
  final bool isManageMode;

  AttractionListScreen({
    required this.cityId,
    required this.cityName,
    required this.cityLat,
    required this.cityLng,
    this.isManageMode = false,
  });

  @override
  _AttractionListScreenState createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
  List<Attraction> _attractions = [];
  List<Attraction> _filteredAttractions = [];
  String _selectedCategory = 'All';
  String _sortBy = 'Rating';
  Position? _currentPosition;
  MapController _mapController = MapController();
  bool _isLoading = true;
  double _zoomLevel = 13.0;
  final TextEditingController _searchController = TextEditingController();

  final String _unsplashApiKey = 'rAJe0q86-WJBOOnSk4PbCIZUQK1vkJLX0XP5880I90g'; // Replace with your Unsplash access key
  final String _apiKey = 'puSI3dzJ263diYCcXINNhmrqDfp0ZeM_Wjv3c07_VKQ'; // Replace with your actual HE  RE API key


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchAttractions();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Error getting location: $e");
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
          print('API Response: $data'); // Debug print
          final items = data['items'] as List;

          attractions.addAll(
              items.map((item) => _attractionFromHereAPI(item)).toList()
          );
        } else {
          print('Error response: ${response.statusCode} - ${response.body}'); // Debug print
          throw Exception('API returned ${response.statusCode}');
        }
      }

      // Fetch images for attractions
      final attractionsWithImages = await Future.wait(
          attractions.map((attraction) async {
            final imageUrl = await _getImageFromUnsplash(attraction.name, attraction.category);
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

  Attraction _attractionFromHereAPI(Map<String, dynamic> json) {
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

  String _formatOpeningHours(dynamic hours) {
    if (hours == null) return 'Opening hours not available';
    try {
      final text = hours['text'] ?? hours['structured']?.map((h) =>
      '${h['day']}: ${h['start']}-${h['end']}').join('\n');
      return text ?? 'Opening hours not available';
    } catch (e) {
      return 'Opening hours not available';
    }
  }

  Future<String> _getImageFromUnsplash(String query, String category) async {
    final searchQuery = '${widget.cityName} ${category.toLowerCase()} ${query} location landmark';
    final url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=${Uri.encodeComponent(searchQuery)}&per_page=10&orientation=landscape'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Client-ID $_unsplashApiKey',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final images = data['results'] as List;
        if (images.isNotEmpty) {
          final random = Random().nextInt(images.length);
          return images[random]['urls']['regular'];
        }
      }
    } catch (e) {
      print("Error fetching image from Unsplash: $e");
    }
    return 'https://picsum.photos/seed/${query.hashCode}/150/150';
  }

  void _filterAttractions() {
    setState(() {
      _filteredAttractions = _attractions.where((attraction) {
        final nameMatch = attraction.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final categoryMatch = _selectedCategory == 'All' || attraction.category == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();

      _sortAttractions();
    });
  }

  void _sortAttractions() {
    setState(() {
      switch (_sortBy) {
        case 'Rating':
          _filteredAttractions.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Name':
          _filteredAttractions.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Distance':
          if (_currentPosition != null) {
            _filteredAttractions.sort((a, b) {
              final distanceA = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                a.lat,
                a.lng,
              );
              final distanceB = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                b.lat,
                b.lng,
              );
              return distanceA.compareTo(distanceB);
            });
          }
          break;
      }
    });
  }

  void _showAttractionDetails(Attraction attraction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttractionDetailScreen(
          attraction: attraction,
          currentPosition: _currentPosition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} Attractions'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildMapView(),
          _buildAttractionList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search attractions',
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: (_) => _filterAttractions(),
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
                  _filterAttractions();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 200,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(widget.cityLat, widget.cityLng),
          zoom: _zoomLevel,
          onPositionChanged: (position, hasGesture) {
            if (!hasGesture) return;
            _fetchMoreAttractions();
          },
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
                      _zoomLevel = min(_zoomLevel + 1, 18);
                      _mapController.move(_mapController.center, _zoomLevel);
                    });
                  },
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      _zoomLevel = max(_zoomLevel - 1, 3);
                      _mapController.move(_mapController.center, _zoomLevel);
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
    );
  }

  Widget _buildAttractionList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await _fetchAttractions();
          return;
        },
        child: ListView.builder(
          itemCount: _filteredAttractions.length,
          itemBuilder: (context, index) {
            final attraction = _filteredAttractions[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    attraction.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                title: Text(attraction.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(attraction.category),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < attraction.rating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                trailing: widget.isManageMode ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editAttraction(attraction),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteAttraction(attraction),
                    ),
                  ],
                ) : TextButton(
                  onPressed: attraction.website.isNotEmpty ? () {
                    // Open the website in a browser
                    launch(attraction.website);
                  } : null,
                  child: Text('Website'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(48, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                onTap: () => _showAttractionDetails(attraction),
              ),
            );
          },
        ),
      ),
    );
  }
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Rating'),
                value: 'Rating',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortAttractions();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text('Name'),
                value: 'Name',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortAttractions();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text('Distance'),
                value: 'Distance',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortAttractions();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchMoreAttractions() async {
    final currentCenter = _mapController.center;
    final radius = 5000 * pow(2, 13 - _zoomLevel);

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
          print('API Response: $data'); // Debug print
          final items = data['items'] as List;

          for (var item in items) {
            final attraction = _attractionFromHereAPI(item);
            final imageUrl = await _getImageFromUnsplash(attraction.name, attraction.category);
            final attractionWithImage = attraction.copyWith(imageUrl: imageUrl);
            newAttractions.add(attractionWithImage);
          }
        } else {
          print('Error response: ${response.statusCode} - ${response.body}'); // Debug print
          throw Exception('API returned ${response.statusCode}');
        }
      }

      setState(() {
        _attractions.addAll(newAttractions);
        _filteredAttractions = _attractions;
        if (_selectedCategory != 'All') {
          _filteredAttractions = _filteredAttractions
              .where((attraction) => attraction.category == _selectedCategory)
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

  void _editAttraction(Attraction attraction) {
    String name = attraction.name;
    String category = attraction.category;
    String description = attraction.description;
    String address = attraction.address;
    String website = attraction.website;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Attraction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Category'),
                  controller: TextEditingController(text: category),
                  onChanged: (value) => category = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  controller: TextEditingController(text: description),
                  onChanged: (value) => description = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Address'),
                  controller: TextEditingController(text: address),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Website'),
                  controller: TextEditingController(text: website),
                  onChanged: (value) => website = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Here you would typically update your database
                final updatedAttraction = Attraction(
                  id: attraction.id,
                  name: name,
                  category: category,
                  rating: attraction.rating,
                  imageUrl: attraction.imageUrl,
                  lat: attraction.lat,
                  lng: attraction.lng,
                  description: description,
                  contactInfo: attraction.contactInfo,
                  openingHours: attraction.openingHours,
                  address: address,
                  website: website,
                );

                // Update in database logic here

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Attraction updated successfully')),
                );
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAttraction(Attraction attraction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Attraction'),
          content: Text('Are you sure you want to delete ${attraction.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete from database logic here

                setState(() {
                  _attractions.removeWhere((a) => a.id == attraction.id);
                  _filteredAttractions.removeWhere((a) => a.id == attraction.id);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Attraction deleted successfully')),
                );
              },
              child: Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}