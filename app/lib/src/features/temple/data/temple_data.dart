/// Data model for a city with temple booking support.
/// Used by the Temple flow to determine which cities to show.
class CityConfig {
  final String id;
  final String name;
  final bool supportsTempleBooking;
  final int templeCount;

  const CityConfig({
    required this.id,
    required this.name,
    required this.supportsTempleBooking,
    this.templeCount = 0,
  });
}

/// Data model for a Temple, ready for future location-based features.
class TempleModel {
  final String id;
  final String name;
  final String cityId;
  final String address;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String templeType;

  const TempleModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isActive = true,
    this.templeType = 'General',
  });
}

/// Configuration-based city list.
/// Only cities with `supportsTempleBooking == true` will be shown.
const List<CityConfig> allCities = [
  CityConfig(id: 'gzb', name: 'Ghaziabad', supportsTempleBooking: true, templeCount: 4),
  CityConfig(id: 'noida', name: 'Noida', supportsTempleBooking: true, templeCount: 3),
  CityConfig(id: 'delhi', name: 'Delhi NCR', supportsTempleBooking: true, templeCount: 6),
  CityConfig(id: 'haridwar', name: 'Haridwar', supportsTempleBooking: true, templeCount: 5),
  CityConfig(id: 'varanasi', name: 'Varanasi', supportsTempleBooking: true, templeCount: 8),
  CityConfig(id: 'greater_noida', name: 'Greater Noida', supportsTempleBooking: false, templeCount: 0),
  CityConfig(id: 'lucknow', name: 'Lucknow', supportsTempleBooking: false, templeCount: 0),
];

/// Filtered: only cities where temple booking is available
List<CityConfig> get templeEnabledCities =>
    allCities.where((c) => c.supportsTempleBooking).toList();

/// Sample temple data with coordinates for future location features
const List<TempleModel> allTemples = [
  TempleModel(id: 't1', name: 'Dudheshwar Nath Mandir', cityId: 'gzb', address: 'GT Road, Ghaziabad', latitude: 28.6692, longitude: 77.4538, templeType: 'Shiv Temple'),
  TempleModel(id: 't2', name: 'ISKCON Temple', cityId: 'gzb', address: 'Raj Nagar, Ghaziabad', latitude: 28.6760, longitude: 77.4350, templeType: 'Krishna Temple'),
  TempleModel(id: 't3', name: 'Shri Hanuman Mandir', cityId: 'gzb', address: 'Lal Kuan, Ghaziabad', latitude: 28.6350, longitude: 77.4820, templeType: 'Hanuman Temple'),
  TempleModel(id: 't4', name: 'Shakti Peeth Devi Mandir', cityId: 'gzb', address: 'Sector 12, Ghaziabad', latitude: 28.6700, longitude: 77.4300, templeType: 'Devi Temple'),
  TempleModel(id: 't5', name: 'ISKCON Noida', cityId: 'noida', address: 'Sector 33, Noida', latitude: 28.5880, longitude: 77.3210, templeType: 'Krishna Temple'),
  TempleModel(id: 't6', name: 'Kali Bari Mandir', cityId: 'noida', address: 'Sector 26, Noida', latitude: 28.5740, longitude: 77.3250, templeType: 'Devi Temple'),
  TempleModel(id: 't7', name: 'Shiv Mandir', cityId: 'noida', address: 'Sector 15, Noida', latitude: 28.5850, longitude: 77.3150, templeType: 'Shiv Temple'),
  TempleModel(id: 't8', name: 'Akshardham', cityId: 'delhi', address: 'Noida Expressway, Delhi', latitude: 28.6127, longitude: 77.2773, templeType: 'General'),
  TempleModel(id: 't9', name: 'Birla Mandir', cityId: 'delhi', address: 'Connaught Place, Delhi', latitude: 28.6328, longitude: 77.2087, templeType: 'General'),
  TempleModel(id: 't10', name: 'Lotus Temple', cityId: 'delhi', address: 'Bahapur, Delhi', latitude: 28.5535, longitude: 77.2588, templeType: 'General'),
  TempleModel(id: 't11', name: 'Chatarpur Mandir', cityId: 'delhi', address: 'Chatarpur, Delhi', latitude: 28.5048, longitude: 77.1750, templeType: 'Devi Temple'),
  TempleModel(id: 't12', name: 'Kalkaji Mandir', cityId: 'delhi', address: 'Kalkaji, Delhi', latitude: 28.5409, longitude: 77.2470, templeType: 'Devi Temple'),
  TempleModel(id: 't13', name: 'Jhandewalan Mandir', cityId: 'delhi', address: 'Jhandewalan, Delhi', latitude: 28.6480, longitude: 77.2050, templeType: 'Devi Temple'),
  TempleModel(id: 't14', name: 'Har Ki Pauri', cityId: 'haridwar', address: 'Haridwar', latitude: 29.9457, longitude: 78.1748, templeType: 'Ghat'),
  TempleModel(id: 't15', name: 'Mansa Devi Temple', cityId: 'haridwar', address: 'Bilwa Parvat, Haridwar', latitude: 29.9490, longitude: 78.1660, templeType: 'Devi Temple'),
  TempleModel(id: 't16', name: 'Chandi Devi Temple', cityId: 'haridwar', address: 'Neel Parvat, Haridwar', latitude: 29.9595, longitude: 78.1730, templeType: 'Devi Temple'),
  TempleModel(id: 't17', name: 'Daksh Mahadev Temple', cityId: 'haridwar', address: 'Kankhal, Haridwar', latitude: 29.9270, longitude: 78.1520, templeType: 'Shiv Temple'),
  TempleModel(id: 't18', name: 'Maya Devi Temple', cityId: 'haridwar', address: 'Haridwar', latitude: 29.9450, longitude: 78.1700, templeType: 'Devi Temple'),
  TempleModel(id: 't19', name: 'Kashi Vishwanath', cityId: 'varanasi', address: 'Lahori Tola, Varanasi', latitude: 25.3109, longitude: 83.0107, templeType: 'Shiv Temple'),
  TempleModel(id: 't20', name: 'Sankat Mochan Hanuman', cityId: 'varanasi', address: 'Sankat Mochan, Varanasi', latitude: 25.2940, longitude: 83.0030, templeType: 'Hanuman Temple'),
  TempleModel(id: 't21', name: 'Durga Temple', cityId: 'varanasi', address: 'Durgakund, Varanasi', latitude: 25.2950, longitude: 83.0050, templeType: 'Devi Temple'),
  TempleModel(id: 't22', name: 'Tulsi Manas Temple', cityId: 'varanasi', address: 'Durgakund Rd, Varanasi', latitude: 25.2960, longitude: 83.0040, templeType: 'General'),
  TempleModel(id: 't23', name: 'Bharat Mata Temple', cityId: 'varanasi', address: 'Mahatma Gandhi Kashi Vidyapith, Varanasi', latitude: 25.3080, longitude: 83.0200, templeType: 'General'),
  TempleModel(id: 't24', name: 'New Vishwanath Temple', cityId: 'varanasi', address: 'BHU Campus, Varanasi', latitude: 25.2677, longitude: 82.9913, templeType: 'Shiv Temple'),
  TempleModel(id: 't25', name: 'Annapurna Devi Temple', cityId: 'varanasi', address: 'Vishwanath Gali, Varanasi', latitude: 25.3100, longitude: 83.0100, templeType: 'Devi Temple'),
  TempleModel(id: 't26', name: 'Dashashwamedh Ghat', cityId: 'varanasi', address: 'Dashashwamedh Rd, Varanasi', latitude: 25.3044, longitude: 83.0130, templeType: 'Ghat'),
];

/// Get temples for a given city ID
List<TempleModel> templesForCity(String cityId) =>
    allTemples.where((t) => t.cityId == cityId && t.isActive).toList();
