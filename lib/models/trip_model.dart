import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String userId;
  final String transportMode;
  final double distance;
  final double co2Emitted;
  final DateTime timestamp;

  Trip({
    required this.id,
    required this.userId,
    required this.transportMode,
    required this.distance,
    required this.co2Emitted,
    required this.timestamp,
  });

  // Convert Trip to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'transportMode': transportMode,
      'distance': distance,
      'co2Emitted': co2Emitted,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create Trip from a Firestore document
  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      userId: data['userId'] ?? '',
      transportMode: data['transportMode'] ?? '',
      distance: (data['distance'] ?? 0).toDouble(),
      co2Emitted: (data['co2Emitted'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Emission factors for different transport modes
  static Map<String, double> emissionFactors = {
    'Car': 0.192,
    'Motorcycle': 0.103,
    'Bus': 0.089,
    'Train': 0.041,
    'Bicycle': 0.0,
    'Walking': 0.0,
  };

  // Calculate CO2 emissions based on transport mode and distance
  static double calculateCO2(String transportMode, double distance) {
    final factor = emissionFactors[transportMode] ?? 0.0;
    return factor * distance;
  }
}
