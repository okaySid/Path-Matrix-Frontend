import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/models/app_state.dart';

class FigmaFlowAnalyzerApp extends StatelessWidget {
  const FigmaFlowAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final router = AppRouter.createRouter(appState);

    return MaterialApp.router(
      title: 'Figma Flow Analyzer',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
