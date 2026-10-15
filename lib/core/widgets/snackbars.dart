import 'package:flutter/material.dart';

extension SnackBarX on BuildContext {
  /// Shows [message], replacing any snackbar already on screen. An optional
  /// [actionLabel] / [onAction] pair adds a button (e.g. "Sign in").
  void showMessage(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }
}
