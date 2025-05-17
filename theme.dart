import 'package:flutter/material.dart';

ThemeData buildRusskiyBredTheme() {
  final ThemeData base = ThemeData.light();
  
  return base.copyWith(
    primaryColor: const Color(0xFF795548),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF795548),
      secondary: Color(0xFFB71C1C),
      surface: Color(0xFFF5F0E1),
      background: Color(0xFFF5F0E1),
      error: Color(0xFFB00020),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F0E1),
    textTheme: _buildRusskiyBredTextTheme(base.textTheme),
    appBarTheme: _buildRusskiyBredAppBarTheme(base.appBarTheme),
    elevatedButtonTheme: _buildRusskiyBredButtonTheme(),
    cardTheme: _buildRusskiyBredCardTheme(base.cardTheme),
    tabBarTheme: _buildRusskiyBredTabBarTheme(base.tabBarTheme),
    iconTheme: base.iconTheme.copyWith(
      color: const Color(0xFF3E2723),
    ),
  );
}

TextTheme _buildRusskiyBredTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge!.copyWith(
      fontFamily: 'RusskiyFont',
      fontSize: 24.0,
      color: const Color(0xFF3E2723),
      fontWeight: FontWeight.bold,
    ),
    displayMedium: base.displayMedium!.copyWith(
      fontFamily: 'RusskiyFont',
      fontSize: 22.0,
      color: const Color(0xFF3E2723),
    ),
    displaySmall: base.displaySmall!.copyWith(
      fontFamily: 'RusskiyFont',
      fontSize: 20.0,
      color: const Color(0xFF3E2723),
    ),
    headlineMedium: base.headlineMedium!.copyWith(
      fontFamily: 'RusskiyFont',
      fontSize: 18.0,
      color: const Color(0xFF3E2723),
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: base.bodyLarge!.copyWith(
      fontFamily: 'RusskiyFont',
      fontSize: 16.0,
      color: const Color(0xFF3E2723),
    ),
    bodyMedium: base.bodyMedium!.copyWith(
      fontFamily: 'RusskiyFont',
      fontSize: 14.0,
      color: const Color(0xFF3E2723),
    ),
  );
}

AppBarTheme _buildRusskiyBredAppBarTheme(AppBarTheme base) {
  return base.copyWith(
    backgroundColor: const Color(0xFF795548),
    foregroundColor: const Color(0xFFF5F0E1),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontFamily: 'RusskiyFont',
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF5F0E1),
    ),
  );
}

ElevatedButtonThemeData _buildRusskiyBredButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF795548),
      foregroundColor: const Color(0xFFF5F0E1),
      textStyle: const TextStyle(
        fontFamily: 'RusskiyFont',
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );
}

CardTheme _buildRusskiyBredCardTheme(CardTheme base) {
  return base.copyWith(
    color: const Color(0xFFF5F0E1),
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: const BorderSide(
        color: Color(0xFF795548),
        width: 1.0,
      ),
    ),
    margin: const EdgeInsets.all(8.0),
  );
}

TabBarTheme _buildRusskiyBredTabBarTheme(TabBarTheme base) {
  return base.copyWith(
    labelColor: const Color(0xFFF5F0E1),
    unselectedLabelColor: const Color(0xFFE0E0E0),
    indicator: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFB71C1C),
          width: 2.0,
        ),
      ),
    ),
    labelStyle: const TextStyle(
      fontFamily: 'RusskiyFont',
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'RusskiyFont',
      fontSize: 16.0,
    ),
  );
}
