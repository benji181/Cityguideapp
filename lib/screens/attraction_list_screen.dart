import 'package:flutter/material.dart';

class Attraction {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String imageUrl;

  Attraction({required this.id, required this.name, required this.category, required this.rating, required this.imageUrl});
}

class AttractionListScreen extends StatefulWidget {
  @override
  _AttractionListScreenState createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
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
      ),
    );
  }
}

