import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/loading_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_trip_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tips_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize auth service
  final authService = AuthService();
  
  runApp(EcoCalApp(authService: authService));
}

class EcoCalApp extends StatelessWidget {
  final AuthService authService;
  
  const EcoCalApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return AuthStateProvider(
      authService: authService,
      authStateStream: authService.authStateChanges,
      child: MaterialApp(
        title: 'EcoCal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Montserrat',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Montserrat',
        ),
        themeMode: ThemeMode.system,
        home: StreamBuilder<User?>(  // Use StreamBuilder to listen to auth state changes
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            // Show loading indicator while connection state is waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }
            
            // If user is logged in, show HomeScreen, otherwise show AuthScreen
            final user = snapshot.data;
            if (user != null) {
              return const HomeScreen();
            } else {
              return const AuthScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/add_trip': (context) => const AddTripScreen(),
          '/history': (context) => const HistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/tips': (context) => const TipsScreen(),
        },
      ),
    );
  }
}
