import 'package:flutter/material.dart';

import '../domain/explore_service.dart';

class ExploreServiceDetailPage extends StatelessWidget {
  final ExploreService service;

  const ExploreServiceDetailPage({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.description,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            _sectionTitle('What this service involves'),
            ...service.requirements.map(_bullet),

            const SizedBox(height: 16),

            _sectionTitle('Additional arrangements may be required'),
            ...service.additionalArrangements.map(_bullet),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: null, // 🔒 PHASE-1: Disabled
                child: const Text('Request this service (Coming Soon)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
