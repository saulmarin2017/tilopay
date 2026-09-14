import 'package:flutter/material.dart';

/// Paleta Tilopay Demo (misma que APEX `theme_tilopay_colores.md`).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFED1525);
  static const Color primaryDark = Color(0xFFB0101C);
  static const Color primaryDeeper = Color(0xFF7A0A14);
  static const Color loginBgDeep = Color(0xFF5C0810);
  static const Color primarySoft = Color(0xFFFF6B75);

  static const Color secondary = Color(0xFF160065);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color error = Color(0xFFC62828);
  static const Color onPrimary = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color ok = Color(0xFF1B8A4A);

  static const Color workOrange = Color(0xFFE65100);

  static const Color loginBgTop = loginBgDeep;
  static const Color loginBgMid = primaryDark;
  static const Color loginBgBottom = primary;
}
