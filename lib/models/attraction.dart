
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
