import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app.dart';

import 'providers/auth_provider.dart' as app_auth;
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/admin_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp();

    // Disable reCAPTCHA bypass for testing in debug mode
    try {
      final auth = FirebaseAuth.instance;
      await auth.setSettings(appVerificationDisabledForTesting: true);
    } catch (e) {
      debugPrint("Auth Settings Error: $e");
    }

    // Clear data on every start to begin from onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: const MarketplaceApp(),
      ),
    );
  } catch (e) {
    debugPrint("Firebase Error: $e");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text("Startup Failed: $e\n\nFix: Change Gradle JDK to 17 in Android Studio Settings."),
          ),
        ),
      ),
    ));
  }
}
