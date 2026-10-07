import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// [AppTextField] with the lock icon and an eye toggle that reveals the text.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.showPasswordLabel,
    required this.hidePasswordLabel,
    this.hintText,
    this.errorText,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String showPasswordLabel;
  final String hidePasswordLabel;
  final String? hintText;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      iconAsset: AppIcons.lock,
      controller: widget.controller,
      hintText: widget.hintText,
      errorText: widget.errorText,
      obscureText: _obscured,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      trailing: Semantics(
        button: true,
        label: _obscured ? widget.showPasswordLabel : widget.hidePasswordLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _obscured = !_obscured),
          child: SvgPicture.asset(
            AppIcons.eye,
            width: 20,
            height: 20,
            colorFilter: _obscured
                ? null
                : const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
