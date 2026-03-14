import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_client.dart';

class Ritual {
  final String id;
  final String name;
  final String description;
  final String category;
  final Map<BookingLocation, double> basePricing;
  final List<String> mandatorySamagri;

  const Ritual({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePricing,
    this.mandatorySamagri = const [],
  });
}

enum BookingLocation { home, temple, tirth, other }

abstract class RitualRepository {
  Future<List<Ritual>> getRituals();
  Future<Ritual?> getRitualById(String id);
  Future<Map<String, double>> getRitualPricing(PricingParams params);
}

class PricingParams {
  final String ritualId;
  final String? cityId;
  final BookingLocation location;

  const PricingParams({
    required this.ritualId,
    this.cityId,
    required this.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PricingParams &&
          runtimeType == other.runtimeType &&
          ritualId == other.ritualId &&
          cityId == other.cityId &&
          location == other.location;

  @override
  int get hashCode => ritualId.hashCode ^ cityId.hashCode ^ location.hashCode;
}

class SupabaseRitualRepository implements RitualRepository {
  @override
  Future<List<Ritual>> getRituals() async {
    // 1. Fetch all rituals
    final List<dynamic> ritualsData = await supabase.from('rituals').select('*');
    
    // 2. Fetch all pricing
    final List<dynamic> pricingData = await supabase.from('ritual_pricing').select('*');

    return ritualsData.map((json) {
      final ritualId = json['id'];
      
      // Filter pricing for this ritual
      final Map<BookingLocation, double> pricing = {};
      for (var p in pricingData) {
        if (p['ritual_id'] == ritualId) {
          final loc = BookingLocation.values.firstWhere(
            (e) => e.name == p['location_type'],
            orElse: () => BookingLocation.other,
          );
          // Use pooja_dakshina as the base price for the catalog list
          pricing[loc] = ((p['pooja_dakshina'] ?? p['price'] ?? 0.0) as num).toDouble();
        }
      }

      return Ritual(
        id: ritualId,
        name: json['name'],
        description: json['description'] ?? '',
        category: json['category'] ?? 'All',
        basePricing: pricing,
      );
    }).toList();
  }

  @override
  Future<Ritual?> getRitualById(String id) async {
    try {
      final data = await supabase
          .from('rituals')
          .select('*')
          .eq('id', id)
          .single();
      
      // Fetch pricing for this ritual to fulfill the Ritual model requirement
      final pricingData = await supabase
          .from('ritual_pricing')
          .select('*')
          .eq('ritual_id', id);

      final Map<BookingLocation, double> pricing = {};
      for (var p in pricingData) {
        final loc = BookingLocation.values.firstWhere(
          (e) => e.name == p['location_type'],
          orElse: () => BookingLocation.other,
        );
        pricing[loc] = ((p['pooja_dakshina'] ?? p['price'] ?? 0.0) as num).toDouble();
      }

      return Ritual(
        id: data['id'],
        name: data['name'],
        description: data['description'] ?? '',
        category: data['category'] ?? 'All',
        basePricing: pricing,
      );
    } catch (e) {
      debugPrint('Error fetching ritual by id: $e');
      return null;
    }
  }

  @override
  Future<Map<String, double>> getRitualPricing(PricingParams params) async {
    try {
      // 1. Try to fetch city-specific pricing first
      if (params.cityId != null) {
        final List<dynamic> cityData = await supabase
            .from('ritual_pricing')
            .select('pooja_dakshina, samagri_charges, platform_fee_override, delivery_fee_override')
            .eq('ritual_id', params.ritualId)
            .eq('city_id', params.cityId!)
            .eq('location_type', params.location.name);
        
        if (cityData.isNotEmpty) {
          final data = cityData.first;
          return {
            'pooja_dakshina': (data['pooja_dakshina'] as num).toDouble(),
            'samagri_charges': (data['samagri_charges'] as num).toDouble(),
            'platform_fee': (data['platform_fee_override'] ?? 20.0 as num).toDouble(),
            'delivery_fee': (data['delivery_fee_override'] ?? 50.0 as num).toDouble(),
          };
        }
      }

      // 2. Fallback to default pricing (where city_id is null)
      final List<dynamic> defaultData = await supabase
          .from('ritual_pricing')
          .select('pooja_dakshina, samagri_charges')
          .eq('ritual_id', params.ritualId)
          .eq('location_type', params.location.name)
          .filter('city_id', 'is', null);

      if (defaultData.isNotEmpty) {
        final data = defaultData.first;
        return {
          'pooja_dakshina': (data['pooja_dakshina'] as num).toDouble(),
          'samagri_charges': (data['samagri_charges'] as num).toDouble(),
          'platform_fee': 20.0,
          'delivery_fee': 50.0,
        };
      }

      // 3. Final safety fallback
      return {
        'pooja_dakshina': 2100.0,
        'samagri_charges': 1100.0,
        'platform_fee': 20.0,
        'delivery_fee': 50.0,
      };
    } catch (e) {
      debugPrint('Error fetching pricing: $e');
      return {
        'pooja_dakshina': 2100.0,
        'samagri_charges': 1100.0,
        'platform_fee': 20.0,
        'delivery_fee': 50.0,
      };
    }
  }
}

class LocalRitualRepository implements RitualRepository {
  @override
  Future<List<Ritual>> getRituals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockRituals;
  }

  @override
  Future<Ritual?> getRitualById(String id) async {
    return _mockRituals.firstWhere((r) => r.id == id);
  }

  @override
  Future<Map<String, double>> getRitualPricing(PricingParams params) async {
    final ritual = _mockRituals.firstWhere((r) => r.id == params.ritualId);
    final dakshina = ritual.basePricing[params.location] ?? 2100.0;
    return {
      'pooja_dakshina': dakshina,
      'samagri_charges': 1100.0,
    };
  }

  static const List<Ritual> _mockRituals = [
    Ritual(
      id: 'griha_pravesh',
      name: 'Griha Pravesh Pooja',
      description: 'Sacred housewarming ceremony for peace and prosperity.',
      category: 'Griha',
      basePricing: {
        BookingLocation.home: 5100,
        BookingLocation.temple: 3100,
      },
    ),
    Ritual(
      id: 'satyanarayan_katha',
      name: 'Satyanarayan Katha',
      description: 'The narrative of Lord Satyanarayan.',
      category: 'Festival',
      basePricing: {
        BookingLocation.home: 2100,
        BookingLocation.temple: 1100,
      },
    ),
    Ritual(
      id: 'rudrabhishek',
      name: 'Rudrabhishek',
      description: 'Divine bathing of Shiva Lingam.',
      category: 'Shanti',
      basePricing: {
        BookingLocation.home: 2100,
        BookingLocation.temple: 1100,
        BookingLocation.tirth: 3500,
      },
    ),
  ];
}
