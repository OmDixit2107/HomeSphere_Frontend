import 'package:flutter/material.dart';
import 'package:homesphere/pages/property_owner/EditProperty.dart';
import 'package:homesphere/pages/property_owner/PropertyOwnerHome.dart';
import 'package:homesphere/pages/user/UserHome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'utils/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Signup/Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth-checker', // Use a custom route for dynamic checks
      routes: {
        '/auth-checker': (context) => AuthChecker(),
        MyRoutes.loginScreen: (context) => const LoginScreen(),
        MyRoutes.signUp: (context) => const SignUp(),
        MyRoutes.propertyOwnerHome: (context) => const PropertyOwnerHome(),
        MyRoutes.userHome: (context) => const UserHome(),
        // MyRoutes.editScreen:(context) => const EditProperty(propertyId: propertyId) // Corrected typo
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
          print(role);
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
}

Future<String> getUserRole() async {
  // Retrieve the user role from SharedPreferences (if stored) or from backend
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('userRole') ?? '';
  print("this is while getting\n");
  print(role); // Default to empty string if not found
  return role;
}
