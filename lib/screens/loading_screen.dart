import 'package:flutter/material.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Simulate loading time and navigate to login page
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6), // Light off-white with green tint
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: isTablet ? 180 : 120,
                height: isTablet ? 180 : 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // Green color
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.eco,
                    size: isTablet ? 100 : 70,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 40 : 30),
              
              // Loading Spinner
              SizedBox(
                width: isTablet ? 60 : 40,
                height: isTablet ? 60 : 40,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)), // Darker green
                  strokeWidth: isTablet ? 5 : 3,
                ),
              ),
              
              SizedBox(height: isTablet ? 30 : 20),
              
              // Loading Text
              Text(
                "Tracking your carbon footprint...",
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                  color: const Color(0xFF33691E), // Dark green
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
