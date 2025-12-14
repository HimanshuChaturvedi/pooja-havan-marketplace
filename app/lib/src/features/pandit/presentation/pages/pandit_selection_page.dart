import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PanditSelectionPage extends StatelessWidget {
  final String templeName;

  const PanditSelectionPage({
    super.key,
    required this.templeName,
  });

  @override
  Widget build(BuildContext context) {
    // STATIC DATA (backend later)
    final pandits = [
      {
        'name': 'Pandit Ravi Shastri',
        'experience': '15 years',
        'language': 'Hindi, Sanskrit',
      },
      {
        'name': 'Pandit Anil Mishra',
        'experience': '10 years',
        'language': 'Hindi',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pandit'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pandits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = pandits[index];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Experience: ${p['experience']}'),
                Text('Languages: ${p['language']}'),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/home-summary');
                    },
                    child: const Text('Select Pandit'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
