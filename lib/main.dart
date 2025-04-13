import 'package:flutter/material.dart';
import 'package:homesphere/pages/property_owner/EditProperty.dart';
import 'package:homesphere/pages/property_owner/PropertyOwnerHome.dart';
import 'package:homesphere/pages/user/UserHome.dart';
import 'package:homesphere/providers/ChatProvider.dart';
import 'package:homesphere/providers/PropertyProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'utils/routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF4CAF50),
          tertiary: const Color(0xFFFFA726),
          background: Colors.grey[50],
          surface: Colors.white,
          error: const Color(0xFFE53935),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E88E5),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      initialRoute: '/auth-checker',
      routes: {
        '/auth-checker': (context) => AuthChecker(),
        MyRoutes.loginScreen: (context) => const LoginScreen(),
        MyRoutes.signUp: (context) => const SignUp(),
        MyRoutes.propertyOwnerHome: (context) => const PropertyOwnerHome(),
        MyRoutes.userHome: (context) => const UserHome(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserRole(), // Fetch role from SharedPreferences or backend
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final role = snapshot.data!;
          print("this is inside login page\n");
          print(role);

          // Initialize providers if the user is logged in
          if (role.isNotEmpty) {
            _initializeProviders(context);
          }

          if (role == 'User') {
            return const UserHome(); // Navigate to User Home screen
          } else if (role == 'Property Owner') {
            return const PropertyOwnerHome(); // Navigate to Property Owner Home screen
          }
        }

        return const LoginScreen(); // If no role or no data, show the login screen
      },
    );
  }

  Future<void> _initializeProviders(BuildContext context) async {
    try {
      // Get user ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // Initialize ChatProvider
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        await chatProvider.initialize(userId);
        print('Initialized ChatProvider for user ID: $userId');
      }
    } catch (e) {
      print('Error initializing providers: $e');
    }
  }
}

Future<String> getUserRole() async {
  // Retrieve the user role from SharedPreferences (if stored) or from backend
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('userRole') ?? '';
  print("this is while getting\n");
  print(role); // Default to empty string if not found
  return role;
}
