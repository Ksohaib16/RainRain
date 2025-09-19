import 'dart:async';

import 'package:first/app.dart';
import 'package:first/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  try {
    await dotenv.load(fileName: '.env');
    AppLogger.info('.env loaded');
  } catch (e, st) {
    AppLogger.warn('Failed to load .env: $e');
    AppLogger.error('Proceeding without .env may cause missing API key', error: e, stackTrace: st);
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter framework error', error: details.exception, stackTrace: details.stack);
  };

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    AppLogger.error('Uncaught zone error', error: error, stackTrace: stack);
  });
}
