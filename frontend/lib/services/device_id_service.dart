import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIDService {
  static const _key = 'device_id';

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null || id.isEmpty) {
      id = _generate();
      await prefs.setString(_key, id);
    }
    return id;
  }

  String _generate() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    return '${_hex(bytes, 0, 4)}-${_hex(bytes, 4, 2)}-${_hex(bytes, 6, 2)}-${_hex(bytes, 8, 2)}-${_hex(bytes, 10, 6)}';
  }

  String _hex(List<int> bytes, int start, int count) {
    final buf = StringBuffer();
    for (var i = start; i < start + count; i++) {
      buf.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buf.toString();
  }
}
