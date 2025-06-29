class Location {
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? locationDescription;

  Location({
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.locationDescription,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      locationName: json['locationName'],
      locationDescription: json['locationDescription'],
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'locationDescription': locationDescription,
  };
}
