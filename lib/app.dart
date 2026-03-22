import 'package:flutter/material.dart';
import 'shared/presentation/theme/app_theme.dart';
import 'shared/presentation/router/app_router.dart';

class EmerKitApp extends StatelessWidget {
  const EmerKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EmerKit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
