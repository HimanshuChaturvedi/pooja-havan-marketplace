class PoojaModel {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final int price;
  final bool isMorningSlot;
  final bool isWeekendAvailable;
  final bool isTempleOnly;
  final bool isSamagriIncluded;
  final String slug;

  const PoojaModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.price,
    this.isMorningSlot = false,
    this.isWeekendAvailable = false,
    this.isTempleOnly = false,
    this.isSamagriIncluded = false,
    required this.slug,
  });
}

const List<PoojaModel> dummyPoojas = [
  PoojaModel(
    id: '1',
    title: 'Ganesh Chaturthi Pooja',
    subtitle: 'Vignaharta Blessings',
    imagePath: 'assets/images/pooja_ganesha.png',
    price: 2100,
    isMorningSlot: true,
    isWeekendAvailable: true,
    isSamagriIncluded: true,
    slug: 'ganesh-chaturthi',
  ),
  PoojaModel(
    id: '2',
    title: 'Satyanarayan Katha',
    subtitle: 'Prosperity & Peace',
    imagePath: 'assets/images/samagri_thali.png',
    price: 3500,
    isMorningSlot: true,
    isWeekendAvailable: true,
    isSamagriIncluded: true,
    slug: 'satyanarayan',
  ),
  PoojaModel(
    id: '3',
    title: 'Rudrabhishek',
    subtitle: 'Mahadev Divine Grace',
    imagePath: 'assets/images/explore_divine.png',
    price: 5100,
    isTempleOnly: true,
    isMorningSlot: true,
    slug: 'rudrabhishek',
  ),
  PoojaModel(
    id: '4',
    title: 'Maha Laxmi Havan',
    subtitle: 'Wealth & Success',
    imagePath: 'assets/images/activity_scroll.png',
    price: 4500,
    isWeekendAvailable: true,
    isSamagriIncluded: true,
    slug: 'laxmi-havan',
  ),
];
