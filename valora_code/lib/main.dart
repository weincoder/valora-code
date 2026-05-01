import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initHive() async {
  try {
    await Hive.initFlutter();
  } catch (_) {
    // Fallback: use application documents directory directly
    try {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    } catch (_) {
      // Last resort: current working directory (e.g., desktop tests)
      Hive.init(Directory.current.path);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ValoraCode',
      theme: AppTheme.themeData,
      routerConfig: AppRouter.router,
    );
  }
}
