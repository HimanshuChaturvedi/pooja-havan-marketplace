class SamagriItem {
  final String id;
  final String name;
  final double price;
  final String categoryId;

  const SamagriItem({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SamagriItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
