import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'shared/models/app_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const FigmaFlowAnalyzerApp(),
    ),
  ); 
}
  