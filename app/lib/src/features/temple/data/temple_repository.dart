import '../../../core/supabase/supabase_client.dart';
import 'temple_data.dart';

abstract class TempleRepository {
  Future<List<CityConfig>> getCities();
  Future<List<TempleModel>> getTemples(String cityId);
  Future<TempleModel?> getTempleById(String id);
}

class SupabaseTempleRepository implements TempleRepository {
  @override
  Future<List<CityConfig>> getCities() async {
    // Fetch all columns to handle is_active vs state variations
    final List<dynamic> data = await supabase
        .from('cities')
        .select('id, name');

    return data.map((json) => CityConfig(
      id: json['id'],
      name: json['name'],
      supportsTempleBooking: true,
      templeCount: 0,
    )).toList();
  }

  @override
  Future<List<TempleModel>> getTemples(String cityId) async {
    final List<dynamic> data = await supabase
        .from('temples')
        .select('*')
        .eq('city_id', cityId)
        .eq('is_active', true);

    return data.map((json) => TempleModel(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
    )).toList();
  }

  @override
  Future<TempleModel?> getTempleById(String id) async {
    final Map<String, dynamic> data = await supabase
        .from('temples')
        .select('*')
        .eq('id', id)
        .single();
    
    return TempleModel(
      id: data['id'],
      name: data['name'],
      cityId: data['city_id'],
      address: data['address'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: data['is_active'] ?? true,
    );
  }
}
