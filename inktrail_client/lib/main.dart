import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/service_locator.dart';
import 'core/notifications/onesignal_service.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup DI
  await setupLocator();

  // Register OneSignal click listener as early as possible for cold-start taps.
  primeOneSignalClickHandling();

  runApp(const InkTrail());

  // OneSignal can be heavy on emulator startup; keep it off the first frame.
  unawaited(initializeOneSignal());
}
