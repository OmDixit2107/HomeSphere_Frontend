import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Userhome extends StatelessWidget {
  const Userhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This is a home screen"),
      ),
      body: Container(
        child: Text("This is the user screen"),
      ),
    );
  }
}
