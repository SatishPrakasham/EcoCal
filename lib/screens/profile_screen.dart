import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _username = '';
  double _currentGoal = 0.0;
  bool _hasGoal = false;
  
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
  
  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }
  
  // Fetch user profile from Firestore
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          
          setState(() {
            _username = userData['username'] ?? '';
            
            // Check if dailyCarbonGoal exists
            if (userData.containsKey('dailyCarbonGoal')) {
              _currentGoal = (userData['dailyCarbonGoal'] ?? 5.0).toDouble();
              _hasGoal = true;
              _goalController.text = _currentGoal.toString();
            } else {
              _hasGoal = false;
              _currentGoal = 5.0; // Default value
              _goalController.text = '';
            }
            
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasGoal = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Save goal to Firestore
  Future<void> _saveGoal() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Parse goal value
        final newGoal = double.parse(_goalController.text);
        
        // Update in Firestore
        await _firestore.collection('users').doc(userId).update({
          'dailyCarbonGoal': newGoal,
        });
        
        setState(() {
          _currentGoal = newGoal;
          _hasGoal = true;
          _isSaving = false;
        });
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goal updated successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating goal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Build goal setting section
  Widget _buildGoalSettingSection(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Carbon Goal Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Set your daily carbon emission target',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          // Current goal display
          if (_hasGoal) ...[
            Text(
              'Your current daily goal is:',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${_currentGoal.toStringAsFixed(1)} kg CO₂',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            Text(
              'You haven\'t set a goal yet.',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Goal input form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set New Goal (kg CO₂/day)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _goalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintText: 'Enter goal (e.g., 5.0)',
                    suffixText: 'kg CO₂',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal value';
                    }
                    final goal = double.tryParse(value);
                    if (goal == null) {
                      return 'Please enter a valid number';
                    }
                    if (goal <= 0) {
                      return 'Goal must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Tip box for goal setting guidance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "🧠 Tip: Most car users emit 5–6 kg CO₂ daily. If you take public transport, aim for 2–3 kg. You can always adjust your goal later based on your travel habits.",
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save Goal'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F9F6);
    const cardColor = Colors.white;
    const textColor = Color(0xFF2E7D32);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchUserProfile,
                color: const Color(0xFF4CAF50),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // User profile header
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _username,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _auth.currentUser?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Goal setting section
                    _buildGoalSettingSection(cardColor, textColor),
                    
                    const SizedBox(height: 20),
                    
                    // Sign out button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _auth.signOut();
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
