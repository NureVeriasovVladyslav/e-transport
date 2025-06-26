class User {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String role;
  final bool notification;
  final String? photo;
  final String? bonusAccount;
  final List<Rental>? rentals;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.notification,
    this.photo,
    required this.bonusAccount,
    this.rentals = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    role: json['role'] ?? 'USER',
    notification: json['notification'] ?? false,
    photo: json['photo'],
    bonusAccount: json['bonusAccount'],
    rentals: (json['rental'] as List<dynamic>?)
        ?.map((r) => Rental.fromJson(r as Map<String, dynamic>))
        .toList() ?? [],
  );
}

class Rental {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final List<RentalVehicle> rentalVehicles;
  final List<Payment> payments;

  Rental({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.status,
    this.rentalVehicles = const [],
    this.payments = const [],
  });

  factory Rental.fromJson(Map<String, dynamic> json) => Rental(
    id: json['id'] ?? '',
    startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    status: json['status'] ?? '',
    rentalVehicles: (json['rentalVehicle'] as List<dynamic>?)
        ?.map((rv) => RentalVehicle.fromJson(rv as Map<String, dynamic>))
        .toList() ?? [],
    payments: (json['payment'] as List<dynamic>?)
        ?.map((p) => Payment.fromJson(p as Map<String, dynamic>))
        .toList() ?? [],
  );
}

class RentalVehicle {
  final String id;
  final Vehicle vehicle;

  RentalVehicle({
    required this.id,
    required this.vehicle,
  });

  factory RentalVehicle.fromJson(Map<String, dynamic> json) => RentalVehicle(
    id: json['id'] ?? '',
    vehicle: Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
  );
}

class Vehicle {
  final String id;
  final String status;
  final double runnedDistance;

  Vehicle({
    required this.id,
    required this.status,
    required this.runnedDistance,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'] ?? '',
    status: json['status'] ?? '',
    runnedDistance: (json['runnedDistance'] ?? 0.0).toDouble(),
  );
}

class Payment {
  final String id;
  final double amount;
  final String status;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] ?? '',
    amount: (json['amount'] ?? 0.0).toDouble(),
    status: json['status'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}
