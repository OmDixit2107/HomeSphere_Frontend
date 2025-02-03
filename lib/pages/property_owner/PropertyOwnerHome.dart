import 'package:flutter/material.dart';
import 'package:homesphere/pages/property_owner/AddPropertyScreen.dart';
import 'package:homesphere/pages/property_owner/ManageListingsScreen.dart';
import 'package:homesphere/services/api/UserAPI.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'package:homesphere/utils/routes.dart';

class PropertyOwnerHome extends StatefulWidget {
  const PropertyOwnerHome({Key? key}) : super(key: key);

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
      AddPropertyScreen(),
      FutureBuilder<int?>(
        future: _fetchUserId(), // Fetch userId asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            int? userId = snapshot.data;
            return ManageListingsScreen(
              userId: userId!, // Safely pass the userId
            );
          } else {
            return const Center(child: Text("User ID not found"));
          }
        },
      ),
      FinalizeSaleScreen(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Owner Dashboard'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: () {
              Authfunctions.logoutUser();
              Navigator.pushReplacementNamed(
                context,
                MyRoutes.loginScreen,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Manage Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Finalize Sale',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}

class FinalizeSaleScreen extends StatelessWidget {
  const FinalizeSaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Finalize Sale Screen"),
    );
  }
}
