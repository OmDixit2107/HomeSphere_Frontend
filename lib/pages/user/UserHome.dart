import 'package:flutter/material.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'package:homesphere/utils/routes.dart';

class Userhome extends StatelessWidget {
  const Userhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("This is a home screen"),
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
          )
        ],
      ),
      body: Container(
        child: const Text("This is the user screen"),
      ),
    );
  }
}
