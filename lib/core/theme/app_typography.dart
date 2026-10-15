import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Text styles from the Figma file.
///
/// Form screens use Inter; the welcome and style-quiz screens use Poppins.
/// Poppins has no Cyrillic or Uzbek `ʻ` glyphs, so its styles fall back to
/// Inter for those characters.
///
/// Styles don't inherit from the Material text theme: Figma's "normal" line
/// height and zero letter spacing would otherwise pick up Material's
/// `height: 1.43` / `letterSpacing: 0.25` defaults.
abstract final class AppTypography {
  static const inter = 'Inter';
  static const poppins = 'Poppins';
  static const serifAccent = 'PlayfairDisplay';
  static const _poppinsFallback = [inter];

  // Inter — auth & onboarding forms
  static const title = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const subtitle = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const fieldLabel = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static const input = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const inputHint = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const fieldError = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
  );

  static const link = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
  );

  static const button = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const chip = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const chipSelected = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const socialButton = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const divider = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const footer = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textFooter,
  );

  static const footerLink = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );

  static const secondaryAction = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const hint = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.accent,
  );

  // Poppins — welcome & style quiz
  static const tagline = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
    color: AppColors.textMuted,
  );

  static const welcomeButton = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const welcomeSkip = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const wordmarkOverlay = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontSize: 51.84,
    fontWeight: FontWeight.w700,
    height: 1,
    color: Color(0x80220B34), // brandPlum @ 50%
  );

  static const quizTitle = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 41.757,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1722,
    color: AppColors.brandPlum,
  );

  static const quizTitleAccent = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: serifAccent,
    fontSize: 41.757,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.1722,
    color: AppColors.brandPlum,
  );

  static const productTag = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 8.586,
    fontWeight: FontWeight.w400,
    height: 14.53 / 8.586,
    letterSpacing: -0.2695,
    color: Color(0xFFFFFFFF),
  );

  // Figma reports 9.66px inside a component instance scaled ×1.45; this is
  // the size the design actually renders at.
  static const quizAction = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.38,
    color: Color(0xFFFFFFFF),
  );

  // Home feed (Figma 2775:2563). Figma's "normal" Poppins line height is
  // 1.5em rounded to whole pixels (11→17, 12→18, 13→20); Flutter leaves the
  // font's line gap out, so it's set explicitly, split evenly as in CSS.
  static const feedTab = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 13.511,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Upper-case the text where it's used; Figma sets it with text-transform.
  static const feedSectionLabel = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.32,
    height: 17 / 11,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textMuted,
  );

  static const feedSectionTitle = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textPrimary,
  );

  static const heroTag = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 17 / 11,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFFFFFFFF),
  );

  static const feedAuthorName = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 20 / 13,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textPrimary,
  );

  static const feedHandle = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 17 / 11,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textMuted,
  );

  static const feedCount = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textMuted,
  );

  static const feedPersonName = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textPrimary,
  );

  static const _cardTextShadow = [
    Shadow(color: Color(0x5E000000), offset: Offset(0, 1), blurRadius: 0.8),
  ];

  static const feedCardCaption = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFFFFFFFF),
    shadows: _cardTextShadow,
  );

  static const feedCardHandle = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 17 / 11,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xCCFFFFFF),
    shadows: _cardTextShadow,
  );

  // Outfit post (Figma "home-feed-2" 2775:2840). PROVISIONAL: the frame's
  // design context isn't cached yet; families and sizes are inferred from its
  // text boxes (mostly Inter). Refine from the frame's export.
  static const postAuthorName = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const postCount = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const productTagLabel = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
  );

  static const productCardName = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const productCardMeta = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const tagCardBrand = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const tagCardName = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const tagCardPrice = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const tagCardMeta = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const tagCardButton = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: inter,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const productPill = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: poppins,
    fontFamilyFallback: _poppinsFallback,
    fontSize: 7.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
