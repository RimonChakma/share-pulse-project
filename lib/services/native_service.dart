import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel =
  MethodChannel('native/device');

  static Future<Map<String, dynamic>> getDeviceData() async {
    try {
      final result = await _channel.invokeMethod('getDeviceData');
      if (result == null) {
        return {'error': 'No data from native'};
      }
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
