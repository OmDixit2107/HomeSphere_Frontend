import 'package:flutter/material.dart';
import 'package:homesphere/pages/property_owner/AddPropertyScreen.dart';
import 'package:homesphere/pages/property_owner/ManageListingsScreen.dart';
import 'package:homesphere/services/api/UserAPI.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'package:homesphere/utils/routes.dart';

class PropertyOwnerHome extends StatefulWidget {
  const PropertyOwnerHome({super.key});

  @override
  State<PropertyOwnerHome> createState() => _PropertyOwnerHomeState();
}

class _PropertyOwnerHomeState extends State<PropertyOwnerHome> {
  int _selectedIndex = 0;

  // This function fetches the userId asynchronously
  Future<int?> _fetchUserId() async {
    String? email = await Authfunctions.getUserEmail();
    print("printing " + email); // Fetch the email from shared preferences
    return await UserApi.getUserIdByEmail(
        email); // Fetch the userId from the API
  }

  @override
  Widget build(BuildContext context) {
    // Create the screens list
    List<Widget> _screens = <Widget>[
      const AddPropertyScreen(),
      FutureBuilder<int?>(
        future: _fetchUserId(), // Fetch userId asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          } else if (snapshot.hasData) {
            int? userId = snapshot.data;
            return ManageListingsScreen(
              userId: userId!, // Safely pass the userId
            );
          } else {
            return Center(
              child: Text(
                "User ID not found",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
        },
      ),
      const FinalizeSaleScreen(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Owner Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await Authfunctions.logoutUser();
              if (mounted) {
                Navigator.pushReplacementNamed(context, MyRoutes.loginScreen);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Add Property',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Manage Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Finalize Sale',
          ),
        ],
      ),
    );
  }
}

class FinalizeSaleScreen extends StatelessWidget {
  const FinalizeSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is under development',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
