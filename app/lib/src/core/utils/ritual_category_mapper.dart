class RitualCategoryMapper {
  static const String katha = 'Standard Katha & Path';
  static const String havan = 'Specialized Havans';
  static const String marriage = 'Vivah & Marriage Ceremonies';
  static const String death = 'Anusthan & Death Rituals';

  static String getCategoryForSlug(String slug) {
    final s = slug.toLowerCase();
    
    // 1. Shradh/Death rituals
    if (s.contains('shradh') || s.contains('death') || s.contains('pind_daan') || s.contains('antyeshti') || s.contains('tarpan')) {
      return death;
    }
    
    // 2. Vivah/Marriage rituals
    if (s.contains('vivah') || s.contains('marriage') || s.contains('shadi') || s.contains('engagement') || s.contains('sagai') || s.contains('roka')) {
      return marriage;
    }
    
    // 3. Havans/Yagnas
    if (s.contains('havan') || s.contains('yagna') || s.contains('homa') || s.contains('shanti') || s.contains('mahamrityunjaya') || s.contains('navgraha')) {
      return havan;
    }
    
    // 4. Default: Katha & Path
    return katha;
  }

  static List<String> getCategories() {
    return [katha, havan, marriage, death];
  }
}
