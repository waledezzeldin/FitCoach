import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSecureStorageChannel {
  static const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> _store = {};
  bool _installed = false;

  void install() {
    if (_installed) return;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, _handleCall);
    _installed = true;
  }

  void reset() => _store.clear();

  Future<dynamic> _handleCall(MethodCall call) async {
    final Map<String, Object?> args = {};
    final raw = call.arguments;
    if (raw is Map) {
      raw.forEach((key, value) {
        final stringKey = key is String ? key : key?.toString();
        if (stringKey != null) {
          args[stringKey] = value;
        }
      });
    }
    switch (call.method) {
      case 'read':
        final key = args['key'];
        final resolvedKey = key is String ? key : key?.toString();
        return resolvedKey == null ? null : _store[resolvedKey];
      case 'readAll':
        return Map<String, String>.from(_store);
      case 'write':
        final key = args['key'];
        final resolvedKey = key is String ? key : key?.toString();
        final value = args['value']?.toString();
        if (resolvedKey != null && value != null) {
          _store[resolvedKey] = value;
        }
        return null;
      case 'delete':
        final key = args['key'];
        final resolvedKey = key is String ? key : key?.toString();
        if (resolvedKey != null) {
          _store.remove(resolvedKey);
        }
        return null;
      case 'deleteAll':
        _store.clear();
        return null;
      case 'containsKey':
        final key = args['key'];
        final resolvedKey = key is String ? key : key?.toString();
        return resolvedKey != null && _store.containsKey(resolvedKey);
      default:
        return null;
    }
  }
}
