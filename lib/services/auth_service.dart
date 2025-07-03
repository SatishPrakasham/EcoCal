import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
}

// Auth state provider widget
class AuthStateProvider extends InheritedWidget {
  final AuthService authService;
  final Stream<User?> authStateStream;
  
  const AuthStateProvider({
    Key? key,
    required this.authService,
    required this.authStateStream,
    required Widget child,
  }) : super(key: key, child: child);
  
  static AuthStateProvider of(BuildContext context) {
    final AuthStateProvider? result = 
        context.dependOnInheritedWidgetOfExactType<AuthStateProvider>();
    assert(result != null, 'No AuthStateProvider found in context');
    return result!;
  }
  
  @override
  bool updateShouldNotify(AuthStateProvider oldWidget) {
    return authStateStream != oldWidget.authStateStream;
  }
}
