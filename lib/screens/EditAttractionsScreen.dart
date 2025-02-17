
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAttractionsScreen extends StatefulWidget {
  const EditAttractionsScreen({Key? key}) : super(key: key);

  @override
  _EditAttractionsScreenState createState() => _EditAttractionsScreenState();
}

class _EditAttractionsScreenState extends State<EditAttractionsScreen> {
  List<Map<String, dynamic>> attractions = [];
  bool isLoading = true;
  late RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _initializeRealtimeSubscription();
    fetchAttractions();
  }

  void _initializeRealtimeSubscription() {
    _channel = Supabase.instance.client
        .channel('public:attractions')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'attractions',
      callback: (payload) {
        fetchAttractions(); // Refresh data when changes occur
      },
    )
        .subscribe();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  Future<void> fetchAttractions() async {
    try {
      final response = await Supabase.instance.client
          .from('attractions')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        attractions = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attractions: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteAttraction(String id) async {
    try {
      await Supabase.instance.client
          .from('attractions')
          .delete()
          .match({'id': id});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attraction deleted successfully!')),
      );
      fetchAttractions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting attraction: ${e.toString()}')),
      );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> attraction) async {
    final nameController = TextEditingController(text: attraction['name']);
    final addressController = TextEditingController(text: attraction['address']);
    final categoryController = TextEditingController(text: attraction['category']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Attraction',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white

        ),),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
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
            onPressed: () async {
              try {
                await Supabase.instance.client
                    .from('attractions')
                    .update({
                  'name': nameController.text,
                  'address': addressController.text,
                  'category': categoryController.text,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                    .match({'id': attraction['id']});

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Attraction updated successfully!')),
                );
                fetchAttractions();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating attraction: ${e.toString()}')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Attractions',
        style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Colors.brown,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: attractions.length,
        itemBuilder: (context, index) {
          final attraction = attractions[index];
          return Card(
            elevation: 20,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(attraction['name'] ?? 'No name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attraction['address'] ?? 'No address'),
                  Text(attraction['category'] ?? 'No category'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditDialog(attraction),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteAttraction(attraction['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
