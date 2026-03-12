import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/src/core/supabase/supabase_client.dart';

/// Provider that exposes the current Supabase user.
final supabaseUserProvider = StreamProvider<User?>((ref) {
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Provider to check if the user is currently authenticated with a verified email.
/// USAGE: Use this to guard features that require a logged-in identity.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(supabaseUserProvider);
  
  return userAsync.when(
    data: (user) {
      final isAuthed = user != null && !user.isAnonymous && (user.email?.isNotEmpty ?? false);
      debugPrint('Auth Provider: isAuthed=$isAuthed, isAnon=${user?.isAnonymous}, email="${user?.email}"');
      return isAuthed;
    },
    loading: () {
      final currentUser = supabase.auth.currentUser;
      final isSyncAuthed = currentUser != null && !currentUser.isAnonymous && (currentUser.email?.isNotEmpty ?? false);
      debugPrint('Auth Provider (loading): isAuthed=$isSyncAuthed, isAnon=${currentUser?.isAnonymous}');
      return isSyncAuthed;
    },
    error: (_, __) => false,
  );
});
