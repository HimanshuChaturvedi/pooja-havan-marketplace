import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SamagriCartPage extends StatelessWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Samagri Cart')),
      body: const Center(
        child: Text(
          'Cart Summary – Coming Next',
          style: TextStyle(fontSize: 16),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            context.push('/home-summary');
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
