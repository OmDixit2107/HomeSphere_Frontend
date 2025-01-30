import 'package:flutter/material.dart';

class PropertyOwnerHome extends StatefulWidget {
  const PropertyOwnerHome({Key? key}) : super(key: key);

  @override
  State<PropertyOwnerHome> createState() => _PropertyOwnerHomeState();
}

class _PropertyOwnerHomeState extends State<PropertyOwnerHome> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    AddPropertyScreen(),
    ManageListingsScreen(),
    FinalizeSaleScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Owner Dashboard'),
        backgroundColor: Colors.red,
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

// Placeholder Screens
class AddPropertyScreen extends StatelessWidget {
  const AddPropertyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Add Property Screen"),
    );
  }
}

class ManageListingsScreen extends StatelessWidget {
  const ManageListingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Manage Listings Screen"),
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
