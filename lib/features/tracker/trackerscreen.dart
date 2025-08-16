import 'package:flutter/material.dart';

class Trackerscreen extends StatefulWidget {
  const Trackerscreen({super.key});

  @override
  State<Trackerscreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Trackerscreen> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('TRACKER'),);
  }
}