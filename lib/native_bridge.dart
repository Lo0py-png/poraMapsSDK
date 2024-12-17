// native_bridge.dart
import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('mk.upsy.app/maps');

  Future<void> showRoute(String departureCity, String arrivalCity) async {
    try {
      await _channel.invokeMethod('showRoute', {
        'departureCity': departureCity,
        'arrivalCity': arrivalCity,
      });
    } on PlatformException catch (e) {
      print("Failed to show route: ${e.message}");
    }
  }
}
