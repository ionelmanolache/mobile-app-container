import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate(final String? reason) async {
    //final biometricOnly = await hasBiometrics();
    //if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
          localizedReason: reason ?? 'Please authenticate to access the app',
          //biometricOnly: false, //biometricOnly,
          useErrorDialogs: true,
          stickyAuth: true);
    } on PlatformException catch (e) {
      return false;
    }
  }
}
