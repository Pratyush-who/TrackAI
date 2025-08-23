import 'package:flutter/material.dart';

class Recipegenerator extends StatefulWidget {
  const Recipegenerator({super.key});

  @override
  State<Recipegenerator> createState() => _RecipegeneratorState();
}

class _RecipegeneratorState extends State<Recipegenerator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}