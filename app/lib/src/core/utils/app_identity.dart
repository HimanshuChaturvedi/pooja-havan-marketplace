import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AppIdentity {
  static const _keyUserId = 'app_user_id';
  static String? _cachedUserId;

  static Future<String> get userId async {
    if (_cachedUserId != null) return _cachedUserId!;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyUserId);

    if (stored != null) {
      _cachedUserId = stored;
      return stored;
    }

    final newId = _generateUserId();
    await prefs.setString(_keyUserId, newId);
    _cachedUserId = newId;
    return newId;
  }

  static String _generateUserId() {
    final rand = Random().nextInt(999999);
    return 'USR-${DateTime.now().millisecondsSinceEpoch}-$rand';
  }
}
