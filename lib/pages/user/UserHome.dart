import 'package:flutter/material.dart';
import 'package:homesphere/pages/user/BuyProperty.dart';
import 'package:homesphere/pages/user/RentProperty.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'package:homesphere/utils/routes.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  bool isBuying = true; // Default to Buy property screen

  void toggleScreen() {
    setState(() {
      isBuying = !isBuying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomeSphere"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Authfunctions.logoutUser();
              Navigator.pushNamedAndRemoveUntil(
                  context, MyRoutes.loginScreen, (route) => false);
            },
          ),
        ],
      ),
      body: isBuying
          ? BuyProperty() // Replace with actual Buy screen
          : Rentproperty(), // Replace with actual Rent screen
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!isBuying)
                    toggleScreen(); // Switch to Buy only if not already there
                },
                child: Container(
                  color: isBuying ? Colors.blue : Colors.grey,
                  alignment: Alignment.center,
                  child: const Text(
                    "BUY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (isBuying)
                    toggleScreen(); // Switch to Rent only if not already there
                },
                child: Container(
                  color: isBuying ? Colors.grey : Colors.green,
                  alignment: Alignment.center,
                  child: const Text(
                    "RENT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
