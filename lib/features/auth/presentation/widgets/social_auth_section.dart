import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/usecases/social_auth.dart';
import '../cubits/social_sign_in_cubit.dart';

/// "or sign in with" divider plus the Google and Apple buttons.
class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({
    super.key,
    required this.dividerText,
    this.dividerStyle = AppTypography.divider,
  });

  final String dividerText;
  final TextStyle dividerStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<SocialSignInCubit, SocialSignInState>(
      builder: (context, state) {
        final cubit = context.read<SocialSignInCubit>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OrDivider(text: dividerText, style: dividerStyle),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    label: l10n.google,
                    logoAsset: AppIcons.googleLogo,
                    isLoading: state.inProgress == SocialProvider.google,
                    onPressed: () => cubit.signIn(SocialProvider.google),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SocialButton(
                    label: l10n.apple,
                    logoAsset: AppIcons.appleLogo,
                    isLoading: state.inProgress == SocialProvider.apple,
                    onPressed: () => cubit.signIn(SocialProvider.apple),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: AppColors.inputBorder),
      ),
    );
    return Row(
      children: [
        line,
        const SizedBox(width: 12),
        Text(text, style: style),
        const SizedBox(width: 12),
        line,
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.logoAsset,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final String logoAsset;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.controlFill,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.socialBorder),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                SvgPicture.asset(logoAsset, width: 18, height: 18),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.socialButton),
            ],
          ),
        ),
      ),
    );
  }
}
