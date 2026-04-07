import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';

void main() {
  runApp(const MonefyApp());
}

class MonefyApp extends StatelessWidget {
  const MonefyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monefy',
      theme: AppTheme.theme,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
    );
  }
}