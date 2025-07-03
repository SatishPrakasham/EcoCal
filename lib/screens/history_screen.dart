import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Trip> _trips = [];
  
  @override
  void initState() {
    super.initState();
    _fetchTripHistory();
  }
  
  // Fetch trip history from Firestore
  Future<void> _fetchTripHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Query trips collection for current user, ordered by timestamp descending
        final tripsSnapshot = await _firestore
            .collection('trips')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();
        
        final trips = tripsSnapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
        
        setState(() {
          _trips = trips;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trip history: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show error message if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trip history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
  
  // Get icon for transport mode
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
  
  // Build empty state widget
  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No trips logged yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trip history will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add_trip');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build trip card
  Widget _buildTripCard(Trip trip, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and time
            Text(
              _formatDate(trip.timestamp),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            
            // Transport mode with icon
            Row(
              children: [
                Icon(
                  _getTransportIcon(trip.transportMode),
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  trip.transportMode,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Trip details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${trip.distance.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                
                // CO2 emissions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Carbon Emitted',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${trip.co2Emitted.toStringAsFixed(2)} kg CO₂',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getCO2Color(trip.co2Emitted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Get color based on CO2 emissions
  Color _getCO2Color(double co2) {
    if (co2 <= 0.5) {
      return Colors.green;
    } else if (co2 <= 2.0) {
      return Colors.orange;
    } else {
      return Colors.red;
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
        title: const Text('Trip History'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
            : RefreshIndicator(
                onRefresh: _fetchTripHistory,
                color: const Color(0xFF4CAF50),
                child: _trips.isEmpty
                    ? ListView(
                        // Need ListView for RefreshIndicator to work with empty state
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 150,
                            child: _buildEmptyState(textColor),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          return _buildTripCard(_trips[index], cardColor, textColor);
                        },
                      ),
              ),
      ),
    );
  }
}
