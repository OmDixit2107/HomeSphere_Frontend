import 'package:flutter/material.dart';
import 'package:homesphere/pages/property_owner/PropertyOwnerHome.dart';
import 'package:homesphere/pages/user/UserHome.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'utils/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        MyRoutes.loginScreen: (context) => LoginScreen(),
        MyRoutes.signUp: (context) => SignUp(),
        MyRoutes.propertyOwnerHome: (context) => PropertyOwnerHome(),
        MyRoutes.userHome:(context)=>Userhome()
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: loadHomeScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.data == true) {
          return PropertyOwnerHome();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

Future<bool> loadHomeScreen() async {
  bool isLoggedIn = await AuthFunctions.fetchProtectedData();
  return isLoggedIn;
}
