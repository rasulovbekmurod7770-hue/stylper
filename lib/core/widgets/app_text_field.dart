import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Labelled input from the Figma forms: uppercase label above a 50px filled
/// container with a leading 18px icon and an optional trailing widget.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.errorText,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String iconAsset;
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? errorText;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final errorText = widget.errorText;
    final borderColor = errorText != null
        ? AppColors.accent
        : _focusNode.hasFocus
        ? AppColors.brandPink
        : AppColors.inputBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label.toUpperCase(), style: AppTypography.fieldLabel),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? _focusNode.requestFocus : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                SvgPicture.asset(widget.iconAsset, width: 18, height: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    autofillHints: widget.autofillHints,
                    inputFormatters: widget.inputFormatters,
                    autocorrect: widget.autocorrect,
                    enableSuggestions: widget.enableSuggestions,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: AppTypography.input,
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hintText,
                      hintStyle: widget.hintStyle ?? AppTypography.inputHint,
                    ),
                  ),
                ),
                if (widget.trailing case final trailing?) ...[
                  const SizedBox(width: 12),
                  trailing,
                ],
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: AppTypography.fieldError),
        ],
      ],
    );
  }
}
