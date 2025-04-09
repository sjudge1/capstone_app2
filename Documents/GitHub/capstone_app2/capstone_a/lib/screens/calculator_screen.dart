import 'package:flutter/material.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Size Matching Calculator'),
      ),
      body: const Center(
        child: Text('Calculator functionality coming soon...'),
      ),
    );
  }
} 