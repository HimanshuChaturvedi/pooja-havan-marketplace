import 'package:flutter/material.dart';

class HomeBookingPage extends StatelessWidget {
  const HomeBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('At Home Pooja'),
      ),
      body: const Center(
        child: Text(
          'Home Pooja Flow – Coming Next',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
