import 'package:flutter/painting.dart';

/// Color tokens taken from the Stylper Figma file.
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFFFAFAF7);

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF807A87);
  static const textMuted = Color(0xFF736B85);
  static const textFooter = Color(0xFF898989);
  static const textPlaceholder = Color(0x4D1A1A1A); // #1A1A1A @ 30%

  // Brand
  static const accent = Color(0xFFFF325B);
  static const brandRed = Color(0xFFC11E38); // Figma variable "stylper-1"
  static const brandPink = Color(0xFFFF627B);
  static const brandPinkLight = Color(0xFFFF8A9B);
  static const brandPlum = Color(0xFF220B34);
  static const chevron = Color(0xFFDB3A54);
  static const tagBorder = Color(0xFFD04D63);

  // Inputs and outlined controls (all #1A1A1A at low opacity)
  static const inputFill = Color(0x0D1A1A1A); // 5%
  static const inputBorder = Color(0x1A1A1A1A); // 10%
  static const controlFill = Color(0x081A1A1A); // 3%
  static const controlFillStrong = Color(0x0A1A1A1A); // 4%
  static const socialBorder = Color(0x121A1A1A); // 7%
  static const outlineStrong = Color(0x331A1A1A); // 20%

  // Accent-tinted hint card
  static const accentSurface = Color(0x0FFF325B); // 6%
  static const accentBorder = Color(0x33FF325B); // 20%

  // Switch track: accent with a 20% black overlay, as in the Figma switch.
  static const switchTrackOn = Color(0xFFCC2849);
  static const switchTrackOff = Color(0x261A1A1A);
}
