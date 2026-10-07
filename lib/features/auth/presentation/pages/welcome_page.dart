import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fill_viewport_scroll_view.dart';
import '../../../../core/widgets/stylper_wordmark.dart';
import '../widgets/welcome_action_button.dart';
import '../widgets/welcome_hero_collage.dart';

/// Figma: "Screen-Login" (2775:2369) — the entry screen.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onContinueAsGuest});

  final VoidCallback onContinueAsGuest;

  /// Height of everything except the collage on the 766px Figma safe area.
  static const _contentHeight = 486.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          // On short screens the collage shrinks so the actions stay visible.
          builder: (context, viewport) => FillViewportScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 53),
              child: Column(
                children: [
                  SizedBox(
                    height: (viewport.maxHeight - _contentHeight).clamp(
                      120,
                      WelcomeHeroCollage.size.height,
                    ),
                    child: const WelcomeHeroCollage(),
                  ),
                  const SizedBox(height: 45),
                  const StylperWordmark(),
                  const SizedBox(height: 18),
                  Text(
                    l10n.welcomeTagline,
                    style: AppTypography.tagline,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  const SizedBox(height: 33),
                  WelcomeActionButton.filled(
                    label: l10n.signIn,
                    onPressed: () => context.go(AppRoutes.signIn),
                  ),
                  const SizedBox(height: 12),
                  WelcomeActionButton.outlined(
                    label: l10n.createAccount,
                    onPressed: () => context.go(AppRoutes.signUp),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onContinueAsGuest,
                    child: Text(
                      l10n.skipForNow,
                      style: AppTypography.welcomeSkip,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
