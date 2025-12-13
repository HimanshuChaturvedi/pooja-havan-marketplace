import 'package:flutter/material.dart';

class SamagriItemCard extends StatelessWidget {
  final String name;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const SamagriItemCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 0 ? onRemove : null,
                ),
                Text(quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAdd,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
