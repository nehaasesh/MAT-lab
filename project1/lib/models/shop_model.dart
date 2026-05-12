class Shop {
  final int? id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int ownerId;

  Shop({
    this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'owner_id': ownerId,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      lat: map['lat'],
      lng: map['lng'],
      ownerId: map['owner_id'],
    );
  }
}
