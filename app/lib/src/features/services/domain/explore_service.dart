class ExploreService {
  final String id;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> additionalArrangements;

  const ExploreService({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.additionalArrangements,
  });
}

const exploreServices = [
  ExploreService(
    id: 'mata_chowki',
    title: 'Mata Ki Chowki',
    description:
        'A devotional gathering involving bhajans, kirtan, and ritual worship of Maa Durga.',
    requirements: [
      'Pandit / Katha Vachak',
      'Standard pooja samagri',
      'Mata chowki setup',
    ],
    additionalArrangements: [
      'Decoration',
      'Bhajan Mandali / Orchestra',
      'Sound system',
    ],
  ),
  ExploreService(
    id: 'jagran',
    title: 'Jagran',
    description:
        'An overnight devotional event with singing, chanting, and large gatherings.',
    requirements: [
      'Pandit / Lead Singer',
      'Extended samagri',
      'Stage setup',
    ],
    additionalArrangements: [
      'Professional orchestra',
      'Lighting & decoration',
      'Seating / tent arrangement',
    ],
  ),
  ExploreService(
    id: 'grah_pravesh',
    title: 'Grah Pravesh (Custom)',
    description:
        'A customized house-entering ritual depending on tradition and family customs.',
    requirements: [
      'Pandit consultation',
      'Customized samagri',
    ],
    additionalArrangements: [
      'Decoration',
      'Havan kund setup',
    ],
  ),
  ExploreService(
    id: 'bhandara',
    title: 'Bhandara',
    description:
        'Community food service organized for religious or charitable occasions.',
    requirements: [
      'Pandit / Ritual guidance',
      'Large-scale samagri',
    ],
    additionalArrangements: [
      'Catering / Cooking staff',
      'Utensils & serving setup',
      'Seating arrangements',
    ],
  ),
];
