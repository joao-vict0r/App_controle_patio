import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'parking_controller.dart';
import 'parking_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = ParkingController();
  await controller.load();
  runApp(ParkingApp(controller: controller));
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key, required this.controller});

  final ParkingController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pátio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: appPurple,
              brightness: Brightness.dark,
            ).copyWith(
              primary: appPurple,
              onPrimary: Colors.white,
              secondary: appGreen,
              surface: appSurface,
              onSurface: appInk,
            ),
        scaffoldBackgroundColor: appCanvas,
        appBarTheme: const AppBarTheme(
          backgroundColor: appCanvas,
          foregroundColor: appInk,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: appBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: appPurple, width: 1.5),
          ),
          labelStyle: const TextStyle(color: appMuted),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: appCanvas,
          indicatorColor: appPurple.withValues(alpha: .18),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? appPurple : appMuted,
            );
          }),
        ),
      ),
      home: ParkingHome(controller: controller),
    );
  }
}
