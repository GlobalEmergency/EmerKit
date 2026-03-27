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
      builder: (context, child) {
        final data = MediaQuery.of(context);
        final shortSide = data.size.shortestSide;
        // Tablets have shortestSide >= 600dp
        // Scale text proportionally, composing with user preference
        double extraScale;
        if (shortSide >= 720) {
          extraScale = 1.3;
        } else if (shortSide >= 600) {
          extraScale = 1.2;
        } else {
          extraScale = 1.0;
        }
        if (extraScale == 1.0) return child!;
        // Compose: user's textScaler * our tablet factor
        final userScale = data.textScaler.scale(1.0);
        return MediaQuery(
          data: data.copyWith(
            textScaler: TextScaler.linear(userScale * extraScale),
          ),
          child: child!,
        );
      },
    );
  }
}
