import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/soft_glow.dart';

/// Four tilted outfit photos with a pink glow, laid out on the 342×280 Figma
/// "HeroCollage" canvas and scaled down on narrower screens.
class WelcomeHeroCollage extends StatelessWidget {
  const WelcomeHeroCollage({super.key});

  static const size = Size(342, 280);

  // Figma frames: (left, top, frame w, frame h) of each rotated wrapper,
  // the card size inside it, and its rotation in degrees.
  static const _cards = [
    _Card(-12, -31, 243.882, 261.682, 220, 240, -6, AppImages.welcomeOutfit1),
    _Card(123.99, -4, 239.966, 256.988, 210, 230, 8, AppImages.welcomeOutfit2),
    _Card(-8, 106.14, 182.84, 201.396, 170, 190, -4, AppImages.welcomeOutfit3),
    _Card(175, 104, 188.826, 205.049, 160, 180, -10, AppImages.welcomeOutfit4),
  ];

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              left: -24,
              top: -24,
              child: SoftGlow(diameter: 120, blurSigma: 24),
            ),
            for (final card in _cards)
              Positioned(
                left: card.left,
                top: card.top,
                width: card.frameWidth,
                height: card.frameHeight,
                child: Center(
                  child: Transform.rotate(
                    angle: card.degrees * math.pi / 180,
                    child: _OutfitCard(card),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Card {
  const _Card(
    this.left,
    this.top,
    this.frameWidth,
    this.frameHeight,
    this.width,
    this.height,
    this.degrees,
    this.image,
  );

  final double left;
  final double top;
  final double frameWidth;
  final double frameHeight;
  final double width;
  final double height;
  final double degrees;
  final String image;
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard(this.card);

  final _Card card;

  static const _radius = BorderRadius.all(Radius.circular(24));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: card.width,
      height: card.height,
      decoration: const BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, 8),
            blurRadius: 13.3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Image.asset(card.image, fit: BoxFit.cover),
      ),
    );
  }
}
