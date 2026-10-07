import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/session/session_cubit.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/stylper_wordmark.dart';

/// Placeholder until the Home feed is designed into the app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.watch<SessionCubit>();
    final state = session.state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: StylperWordmark()),
              const SizedBox(height: 32),
              Text(
                l10n.homePlaceholderTitle,
                style: AppTypography.title.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                switch (state) {
                  SessionAuthenticated(:final user) => l10n.homeSignedInMessage(
                    user.username ?? user.email,
                  ),
                  _ => l10n.homeGuestMessage,
                },
                style: AppTypography.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (state is SessionGuest)
                PrimaryButton(
                  label: l10n.signIn,
                  onPressed: session.leaveGuestMode,
                )
              else
                PrimaryButton(label: l10n.signOut, onPressed: session.signOut),
            ],
          ),
        ),
      ),
    );
  }
}
