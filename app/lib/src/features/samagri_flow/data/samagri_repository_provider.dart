import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'samagri_repository.dart';
import '../state/samagri_item.dart';

final samagriRepositoryProvider = Provider<SamagriRepository>((ref) {
  return SupabaseSamagriRepository();
});

final samagriItemsProvider = FutureProvider<List<SamagriItem>>((ref) async {
  final repository = ref.watch(samagriRepositoryProvider);
  return repository.getItems();
});
