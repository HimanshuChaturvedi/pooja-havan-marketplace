class RitualSlugMapper {
  /// Maps various ritual identifiers (UUIDs from DB or display names) 
  /// to normalized slugs used in Pandit Specializations.
  static String getSlug({String? id, String? name}) {
    // 1. Map known UUIDs to Slugs
    final uuidMap = {
      '7645c2af-e0d2-4a07-b4a7-21a8fdbd33ab': 'grah_pravesh', // Griha Pravesh
      'b2069166-b533-451b-8cfb-5f3d8fde6c6d': 'rudrabhishek',
      '5c32217f-67e1-43bf-b0e0-a961bdf43aae': 'satyanarayan_katha',
      'd004b6d2-8aeb-4238-9845-403a89678a92': 'ganesh_havan',
      'c3234d63-e57e-4a0d-8ce0-5bb83757a901': 'mahamrityunjaya',
      'e5558073-79ad-4dc1-8e30-b403b9ddd326': 'navgraha_shanti',
      'd95e8987-d103-41b3-987d-71bb11ad3374': 'lakshmi_pooja',
    };

    if (id != null && uuidMap.containsKey(id)) {
      return uuidMap[id]!;
    }

    // 2. Map display names if ID didn't match (or was null for Explore services)
    final nameLower = (name ?? '').toLowerCase();
    
    if (nameLower.contains('mata') && nameLower.contains('chowki')) return 'mata_chowki';
    if (nameLower.contains('jagran')) return 'jagran';
    if (nameLower.contains('bhandara')) return 'bhandara';
    if (nameLower.contains('grih') || nameLower.contains('grah') || nameLower.contains('pravesh') || nameLower.contains('house')) return 'grah_pravesh';
    if (nameLower.contains('satyanarayan')) return 'satyanarayan_katha';
    if (nameLower.contains('rudrabhishek') || nameLower.contains('shiva')) return 'rudrabhishek';
    if (nameLower.contains('ganesh') || nameLower.contains('havan')) return 'ganesh_havan';

    // Fallback: lowercase underscore as before
    return nameLower.replaceAll(' ', '_');
  }
}
