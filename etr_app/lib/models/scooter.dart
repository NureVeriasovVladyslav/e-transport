/// ---------------------------
///        DATA MODEL
/// ---------------------------
class Scooter {
  final String id;
  final double lat;
  final double lng;
  final String status;
  final double runnedDistance;
  final DateTime releaseDate;

  const Scooter({
    required this.id,
    required this.lat,
    required this.lng,
    required this.status,
    required this.runnedDistance,
    required this.releaseDate,
  });

  factory Scooter.fromJson(Map<String, dynamic> json) => Scooter(
        id: json['id'] as String,
        lat: (json['currentLocation']['latitude'] as num).toDouble(),
        lng: (json['currentLocation']['longitude'] as num).toDouble(),
        status: json['status'] as String,
        runnedDistance: (json['runnedDistance'] as num).toDouble(),
        releaseDate: DateTime.parse(json['releaseDate'] as String),
      );
}