import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceIdentityStorage {
  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'device_identity';

  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _generateDeviceId();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final buffer = StringBuffer('device');
    for (var i = 0; i < 4; i++) {
      buffer.write('-${random.nextInt(0x100000000).toRadixString(16).padLeft(8, '0')}');
    }
    return buffer.toString();
  }
}
