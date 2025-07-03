import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _selectedTransportMode = 'Car';
  final _distanceController = TextEditingController();
  bool _isLoading = false;
  
  // List of available transport modes
  final List<String> _transportModes = [
    'Car',
    'Motorcycle',
    'Bus',
    'Train',
    'Bicycle',
    'Walking',
  ];

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  // Save trip to Firestore
  Future<void> _saveTrip() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Parse distance
      final distance = double.parse(_distanceController.text);
      
      // Calculate CO2 emissions
      final co2Emitted = Trip.calculateCO2(_selectedTransportMode, distance);
      
      // Create trip data
      final trip = Trip(
        id: '', // Will be set by Firestore
        userId: userId,
        transportMode: _selectedTransportMode,
        distance: distance,
        co2Emitted: co2Emitted,
        timestamp: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore.collection('trips').add(trip.toMap());
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip logged! You emitted ${co2Emitted.toStringAsFixed(2)} kg of CO₂',
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        
        // Go back to home screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F9F6);
    const cardColor = Colors.white;
    const textColor = Color(0xFF2E7D32);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Add Trip'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Transport mode selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transport Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedTransportMode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _transportModes.map((mode) {
                          return DropdownMenuItem<String>(
                            value: mode,
                            child: Row(
                              children: [
                                Icon(
                                  _getTransportIcon(mode),
                                  color: const Color(0xFF4CAF50),
                                ),
                                const SizedBox(width: 10),
                                Text(mode),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTransportMode = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Distance input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance (km)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _distanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          suffixText: 'km',
                          hintText: 'Enter distance',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a distance';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Distance must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // CO2 emission info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Emission Factors (kg CO₂ per km)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: Trip.emissionFactors.entries.map((entry) {
                          return Chip(
                            label: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to get icon for transport mode
  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'Car':
        return Icons.directions_car;
      case 'Motorcycle':
        return Icons.motorcycle;
      case 'Bus':
        return Icons.directions_bus;
      case 'Train':
        return Icons.train;
      case 'Bicycle':
        return Icons.directions_bike;
      case 'Walking':
        return Icons.directions_walk;
      default:
        return Icons.directions_car;
    }
  }
}
