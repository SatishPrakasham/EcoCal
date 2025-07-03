import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isPasswordVisible = false;
  bool _isLogin = true; // Toggle between login and register view
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6), // Light off-white with green tint
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Welcome Text
                Center(
                  child: Text(
                    "Welcome to EcoCal",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF33691E),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Center(
                  child: Text(
                    "Start living sustainably.",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Username TextField (only visible in register mode)
                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Choose a username',
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF4CAF50)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                  ),
                
                // Email TextField
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF4CAF50)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black12
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF4CAF50)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF4CAF50),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black12
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Login/Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    
                    try {
                      if (_isLogin) {
                        // Login
                        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                          throw FirebaseAuthException(
                            code: 'invalid-input',
                            message: 'Please enter both email and password',
                          );
                        }
                        
                        await _firebaseService.signInWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        
                        // Navigate to home screen after successful login
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                        debugPrint('Login successful');
                      } else {
                        // Register
                        if (_emailController.text.isEmpty || 
                            _passwordController.text.isEmpty ||
                            _usernameController.text.isEmpty) {
                          throw FirebaseAuthException(
                            code: 'invalid-input',
                            message: 'Please fill in all fields',
                          );
                        }
                        
                        await _firebaseService.registerWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          _usernameController.text.trim(),
                        );
                        
                        // Navigate to home screen after successful registration
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                        debugPrint('Registration successful');
                      }
                    } catch (e) {
                      setState(() {
                        _errorMessage = e is FirebaseAuthException 
                            ? e.message 
                            : 'An error occurred. Please try again.';
                      });
                      debugPrint('Auth error: $e');
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Login' : 'Register',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
                
                const SizedBox(height: 16),
                
                // Toggle between Login and Register
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin ? 'New user? Register here' : 'Already have an account? Login',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                

                
                SizedBox(height: size.height * 0.05),
                
                // Terms and Privacy Policy
                Center(
                  child: Text(
                    'By continuing, you agree to our Privacy Policy and Terms.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black45,
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
