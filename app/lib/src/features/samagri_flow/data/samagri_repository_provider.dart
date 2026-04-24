import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'samagri_repository.dart';
import '../state/samagri_item.dart';

import '../../../core/services/whatsapp_service.dart';

final samagriRepositoryProvider = Provider<SamagriRepository>((ref) {
  final whatsApp = ref.watch(whatsappServiceProvider);
  return SupabaseSamagriRepository(whatsApp);
});

final samagriItemsProvider = FutureProvider<List<SamagriItem>>((ref) async {
  final repository = ref.watch(samagriRepositoryProvider);
  return repository.getItems();
});
