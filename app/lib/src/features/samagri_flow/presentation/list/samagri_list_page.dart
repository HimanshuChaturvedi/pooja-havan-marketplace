import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import 'widgets/samagri_item_card.dart';

class SamagriListPage extends StatefulWidget {
  const SamagriListPage({super.key});

  @override
  State<SamagriListPage> createState() => _SamagriListPageState();
}

class _SamagriListPageState extends State<SamagriListPage> {
  final Map<String, int> samagri = {
    'Havan Samagri': 0,
    'Ghee': 0,
    'Dhoop': 0,
    'Agarbatti': 0,
    'Kumkum': 0,
  };

  bool get hasItems => samagri.values.any((qty) => qty > 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Samagri')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: samagri.entries.map((entry) {
          return SamagriItemCard(
            name: entry.key,
            quantity: entry.value,
            onAdd: () {
              setState(() {
                samagri[entry.key] = entry.value + 1;
              });
            },
            onRemove: () {
              setState(() {
                samagri[entry.key] =
                    entry.value > 0 ? entry.value - 1 : 0;
              });
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: hasItems
              ? () {
                  // 🔥 CLEAR + SAVE SELECTED ITEMS
                  BookingSession.current?.samagriItems.clear();

                  samagri.forEach((item, qty) {
                    if (qty > 0) {
                      BookingSession.current?.samagriItems.add(item);
                    }
                  });

                  context.push('/samagri-cart');
                }
              : null,
          child: const Text('View Cart'),
        ),
      ),
    );
  }
}
