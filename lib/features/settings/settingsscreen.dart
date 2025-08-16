import 'package:flutter/material.dart';

class Settingsscreen extends StatefulWidget {
  const Settingsscreen({super.key});

  @override
  State<Settingsscreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Settingsscreen> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('Settings'),);
  }
}