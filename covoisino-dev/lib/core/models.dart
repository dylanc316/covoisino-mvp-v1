// models.dart

// Constants for sponsorship status
enum SponsorshipStatus { notStarted, pending, completed }

class Vehicle {
  final String model;
  final String licensePlate;
  final String color;

  Vehicle({
    required this.model,
    required this.licensePlate,
    required this.color,
  });
}

class Contact {
  final String name;
  final String phone;
  final bool isVerified;
  final String? status;

  Contact({
    required this.name,
    required this.phone,
    this.isVerified = false,
    this.status,
  });
}

class User {
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final bool isVerified;
  final List<Contact> verifiers;
  final List<Contact> pendingVerifiers; // Make sure this matches

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.isVerified = false,
    this.verifiers = const [],
    this.pendingVerifiers = const [], // And this matches
  });
}

class Ride {
  final String id;
  final User driver;
  final User passenger;
  final Vehicle vehicle;
  final DateTime timestamp;
  final bool isActive;

  Ride({
    required this.id,
    required this.driver,
    required this.passenger,
    required this.vehicle,
    required this.timestamp,
    this.isActive = true,
  });
}

class RideQRData {
  final String driverId;
  final String vehicleId;
  final DateTime timestamp;
  final String signature;

  RideQRData({
    required this.driverId,
    required this.vehicleId,
    required this.timestamp,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'vehicleId': vehicleId,
        'timestamp': timestamp.toIso8601String(),
        'signature': signature,
      };

  factory RideQRData.fromJson(Map<String, dynamic> json) => RideQRData(
        driverId: json['driverId'],
        vehicleId: json['vehicleId'],
        timestamp: DateTime.parse(json['timestamp']),
        signature: json['signature'],
      );
}
