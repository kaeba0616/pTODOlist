import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/router/app_router.dart';
import 'package:ptodolist/core/db/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();

  runApp(
    const ProviderScope(
      child: PtodolistApp(),
    ),
  );
}

class PtodolistApp extends StatelessWidget {
  const PtodolistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'pTODOlist',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
