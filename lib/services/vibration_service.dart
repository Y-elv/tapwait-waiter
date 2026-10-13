
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  VibrationService._();

  static Timer? _repeatTimer;
  static bool _alertActive = false;

  static Future<void> alert() async {
    // Avoid starting duplicate vibration loops.
    if (_alertActive) return;

    _alertActive = true;

    try {
      final supported = await Vibration.hasVibrator();

      if (supported != true) {
        debugPrint('Vibration is not supported on this device.');
        _alertActive = false;
        return;
      }

      // Vibrate immediately, then repeat every 5 seconds.
      await Vibration.vibrate(
        pattern: [0, 1000],
      );

      _repeatTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) async {
          if (!_alertActive) return;

          try {
            await Vibration.vibrate(
              pattern: [0, 1000],
            );
          } catch (error) {
            debugPrint('Repeated vibration error: $error');
          }
        },
      );
    } catch (error) {
      _alertActive = false;
      debugPrint('Vibration error: $error');
    }
  }

  static Future<void> stop() async {
    _alertActive = false;
    _repeatTimer?.cancel();
    _repeatTimer = null;

    try {
      await Vibration.cancel();
    } catch (error) {
      debugPrint('Could not stop vibration: $error');
    }
  }
}
