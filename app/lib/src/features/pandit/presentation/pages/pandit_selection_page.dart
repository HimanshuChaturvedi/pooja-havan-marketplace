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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pandit'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a Pandit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              templeName.isNotEmpty
                  ? 'Available pandits for $templeName'
                  : 'Available pandits for your pooja',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  _PanditCard(
                    name: 'Pandit Sharma',
                    experience: '12+ years experience',
                    onTap: () {
                      context.push(
                        '/pandit-details',
                        extra: 'Pandit Sharma',
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _PanditCard(
                    name: 'Pandit Mishra',
                    experience: '8+ years experience',
                    onTap: () {
                      context.push(
                        '/pandit-details',
                        extra: 'Pandit Mishra',
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _PanditCard(
                    name: 'Pandit Verma',
                    experience: '15+ years experience',
                    onTap: () {
                      context.push(
                        '/pandit-details',
                        extra: 'Pandit Verma',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanditCard extends StatelessWidget {
  final String name;
  final String experience;
  final VoidCallback onTap;

  const _PanditCard({
    required this.name,
    required this.experience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.orange.shade100,
              child: const Icon(
                Icons.person,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    experience,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
