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
  bool isBuying = true;

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
            onPressed: () async {
              await Authfunctions.logoutUser();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyRoutes.loginScreen,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: isBuying ? const BuyProperty() : const RentProperty(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: isBuying ? 0 : 1,
        onDestinationSelected: (index) {
          if ((index == 0 && !isBuying) || (index == 1 && isBuying)) {
            toggleScreen();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Buy Property',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Rent Property',
          ),
        ],
      ),
    );
  }
}
