import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../models/trip_model.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _selectedIndex = 0;
  String _username = '';
  double _todayCarbonOutput = 0.0;
  bool _isLoading = true;
  List<Trip> _todaysTrips = [];
  
  // Stream for user data
  Stream<DocumentSnapshot>? _userStream;
  
  @override
  void initState() {
    super.initState();
    _setupUserStream();
    _fetchTodaysTrips();
  }
  
  // Setup stream for user data
  void _setupUserStream() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _userStream = _firestore.collection('users').doc(userId).snapshots();
    }
  }
  
  // Fetch today's trips
  Future<void> _fetchTodaysTrips() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Fetch today's trips
        final DateTime now = DateTime.now();
        final DateTime startOfDay = DateTime(now.year, now.month, now.day);
        final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
        
        final tripsSnapshot = await _firestore
            .collection('trips')
            .where('userId', isEqualTo: userId)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
        
        final trips = tripsSnapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
        
        // Calculate total CO2 emissions for today
        double totalCO2 = 0.0;
        for (var trip in trips) {
          totalCO2 += trip.co2Emitted;
        }
        
        setState(() {
          _todaysTrips = trips;
          _todayCarbonOutput = totalCO2;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trips data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Build empty state widget when no trips are available
  Widget _buildEmptyTripState(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Text(
          'No Trips Today',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Add your first trip to start tracking your carbon footprint',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Icon(
          Icons.directions_car,
          size: 48,
          color: Color(0xFF4CAF50),
        ),
      ],
    );
  }
  
  // Helper method to get color based on percentage
  Color _getProgressColor(int percentage) {
    if (percentage < 30) {
      return const Color(0xFF4CAF50); // Green for good progress
    } else if (percentage < 70) {
      return const Color(0xFFFFA726); // Orange for moderate progress
    } else {
      return const Color(0xFFE53935); // Red for high usage
    }
  }
  
  // Helper method to get motivational message based on percentage
  String _getMotivationalMessage(int percentage) {
    if (percentage < 30) {
      return "Great job! You're keeping your carbon footprint low today.";
    } else if (percentage < 70) {
      return "You're doing okay. Consider greener transport options for your next trip.";
    } else if (percentage < 100) {
      return "You're approaching your daily limit. Try to use public transport or walk if possible.";
    } else {
      return "You've exceeded your daily goal. Let's do better tomorrow!";
    }
  }
  
  // Helper method to get tab name
  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Tips';
      case 2: return 'History';
      case 3: return 'Profile';
      default: return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F9F6);
    const textColor = Color(0xFF2E7D32);
    const secondaryTextColor = Color(0xFF388E3C);
    const cardColor = Colors.white;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchTodaysTrips,
                color: const Color(0xFF4CAF50),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  children: [
                    const SizedBox(height: 20),
                    // Welcome message with username from Firestore
                    Text(
                      'Hi ${_username.isNotEmpty ? _username : 'there'} 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let\'s track your carbon footprint today',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Carbon output card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _todaysTrips.isEmpty
                          ? _buildEmptyTripState(textColor, secondaryTextColor)
                          : Column(
                        children: [
                          Text(
                            'Today\'s Carbon Output',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'You\'ve emitted ${_todayCarbonOutput.toStringAsFixed(2)} kg CO₂ from transport today.',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          
                          // Circular progress indicator
                          StreamBuilder<DocumentSnapshot>(
                            stream: _userStream,
                            builder: (context, snapshot) {
                              // Default goal if no data or error
                              double dailyCarbonGoal = 5.0;
                              String username = '';
                              
                              // Extract user data if available
                              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                if (userData != null) {
                                  dailyCarbonGoal = (userData['dailyCarbonGoal'] ?? 5.0).toDouble();
                                  username = userData['username'] ?? '';
                                  
                                  // Update username in state for use elsewhere
                                  if (_username != username) {
                                    _username = username;
                                  }
                                }
                              }
                              
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Progress indicator
                                    SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: CircularProgressIndicator(
                                        value: _todayCarbonOutput / dailyCarbonGoal,
                                        strokeWidth: 15,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                        color: _getProgressColor((_todayCarbonOutput / dailyCarbonGoal * 100).toInt()),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_todayCarbonOutput.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          'kg CO₂',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'of ${dailyCarbonGoal.toStringAsFixed(1)} kg goal',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Motivational message
                          StreamBuilder<DocumentSnapshot>(
                            stream: _userStream,
                            builder: (context, snapshot) {
                              // Default goal if no data or error
                              double dailyCarbonGoal = 5.0;
                              
                              // Extract user data if available
                              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                if (userData != null) {
                                  dailyCarbonGoal = (userData['dailyCarbonGoal'] ?? 5.0).toDouble();
                                }
                              }
                              
                              final percentageUsed = (_todayCarbonOutput / dailyCarbonGoal * 100).toInt();
                              
                              return Column(
                                children: [
                                  Text(
                                    '$percentageUsed% of your daily goal used',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _getProgressColor(percentageUsed),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _getMotivationalMessage(percentageUsed),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Add Trip button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Navigate to Add Trip screen
                          await Navigator.pushNamed(context, '/add_trip');
                          // Refresh data when returning
                          _fetchTodaysTrips();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
      
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Handle navigation based on selected tab
          if (index == 0) {
            // Already on Home screen
          } else if (index == 1) {
            // Navigate to Tips screen
            Navigator.pushNamed(context, '/tips');
          } else if (index == 2) {
            // Navigate to History screen
            Navigator.pushNamed(context, '/history');
          } else if (index == 3) {
            // Navigate to Profile screen
            Navigator.pushNamed(context, '/profile');
          }
        },
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
