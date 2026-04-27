import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'log_service.dart';

class SecurityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalAuthentication _auth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check if biometric hardware is available
  Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate user via Biometrics
  Future<bool> authenticate() async {
    try {
      final bool canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      return await _auth.authenticate(
        localizedReason: 'Please scan your fingerprint or face to authenticate',
        biometricOnly: true,
      );
    } catch (e) {
      debugPrint("Biometric Auth Error: $e");
      return false;
    }
  }

  /// Log a login event to Firestore
  Future<void> logLogin(String userId) async {
    try {
      String deviceName = "Unknown Device";
      String deviceId = "Unknown ID";

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceName = '${iosInfo.name} ${iosInfo.model}';
        deviceId = iosInfo.identifierForVendor ?? "Unknown ID";
      }

      final logData = {
        'userId': userId,
        'deviceName': deviceName,
        'deviceId': deviceId,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      };

      // 1. Add to global login history
      await _db.collection('login_history').add(logData);

      // 2. Update user's trusted devices (unique by deviceId)
      await _db.collection('users').doc(userId).collection('devices').doc(deviceId).set({
        'name': deviceName,
        'lastLogin': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
        'isActive': true,
      });

      // 3. Log to System Logs if it's an important auth event
      await LogService().logEvent(
        action: 'User Login',
        details: 'User $userId logged in using $deviceName (${Platform.operatingSystem})',
        type: 'auth',
        targetId: userId,
      );
    } catch (e) {
      debugPrint("Log Login Error: $e");
    }
  }

  /// Get login history for a user
  Future<List<Map<String, dynamic>>> getLoginHistory(String userId) async {
    final snapshot = await _db
        .collection('login_history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get trusted devices for a user
  Future<List<Map<String, dynamic>>> getTrustedDevices(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('devices')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Remove a trusted device
  Future<void> removeDevice(String userId, String deviceId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }
}
