class Festival {
  final String title;
  final String subtitle;
  final String tag;
  final String cta;

  const Festival({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.cta,
  });
}

const List<Festival> upcomingFestivals = [
  Festival(
    title: 'Navgrah Shanti Special',
    subtitle: 'Align your stars for prosperity. Limited slots available.',
    tag: 'Limited Slots',
    cta: 'Reserve Slot',
  ),
  Festival(
    title: 'Maha Mrityunjay Jap',
    subtitle: 'Health & Longevity for your family.',
    tag: 'Popular 2024',
    cta: 'Book Now',
  ),
  Festival(
    title: 'Ganesh Chaturthi Havan',
    subtitle: 'Invoke wisdom and remove obstacles.',
    tag: 'Upcoming',
    cta: 'Remind Me',
  ),
];
