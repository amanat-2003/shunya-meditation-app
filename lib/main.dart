import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'features/meditation/data/models/meditation_session.dart';
import 'features/settings/data/models/user_settings_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MeditationSessionAdapter());
  Hive.registerAdapter(UserSettingsModelAdapter());
  await Hive.openBox<MeditationSession>('meditation_sessions');
  await Hive.openBox<UserSettingsModel>('user_settings');
  await Hive.openBox('app_state'); // For general key-value state

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://bxctadqcjxhrtajvktun.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ4Y3RhZHFjanhocnRhanZrdHVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzNDU5MjQsImV4cCI6MjA5MDkyMTkyNH0.gbUaUgBfL0eaFJrQ3E9HXQrL2uSl8y37JFRP_ooKARs',
  );

  runApp(
    const ProviderScope(
      child: ShunyaApp(),
    ),
  );
}
