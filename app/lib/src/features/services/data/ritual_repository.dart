import 'package:flutter/foundation.dart';

/// 🕉️ RITUAL MODEL - The Core Entity
/// This handles everything from naming to location-based pricing.
class Ritual {
  final String id;
  final String name;
  final String description;
  final Map<BookingLocation, double> basePricing;
  final List<String> mandatorySamagri;
  /// If null, any pandit can perform. If present, only these pandits are allowed.
  final List<String>? authorizedPanditIds;

  const Ritual({
    required this.id,
    required this.name,
    required this.description,
    required this.basePricing,
    this.mandatorySamagri = const [],
    this.authorizedPanditIds,
  });
}

enum BookingLocation { home, temple, tirth, other }

/// 🏛️ REPOSITORY INTERFACE
/// This is the "Contract". UI will only talk to this.
/// To change from Local -> Database, we just provide a different implementation.
abstract class RitualRepository {
  Future<List<Ritual>> getRituals();
  Future<Ritual?> getRitualById(String id);
}

/// 📦 LOCAL IMPLEMENTATION
/// Uses hardcoded data for the "Pre-seen" stage.
class LocalRitualRepository implements RitualRepository {
  @override
  Future<List<Ritual>> getRituals() async {
    // Simulating network delay for future-proofing
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockRituals;
  }

  @override
  Future<Ritual?> getRitualById(String id) async {
    return _mockRituals.firstWhere((r) => r.id == id);
  }

  static const List<Ritual> _mockRituals = [
    Ritual(
      id: 'griha_pravesh',
      name: 'Griha Pravesh Pooja',
      description: 'Sacred housewarming ceremony for peace and prosperity.',
      basePricing: {
        BookingLocation.home: 5100,
        BookingLocation.temple: 3100,
      },
    ),
    Ritual(
      id: 'rudrabhishek',
      name: 'Rudrabhishek',
      description: 'Divine bathing of Shiva Lingam.',
      basePricing: {
        BookingLocation.home: 2100,
        BookingLocation.temple: 1100,
        BookingLocation.tirth: 3500, // Prepared for future Varanasi/Haridwar
      },
    ),
  ];
}
