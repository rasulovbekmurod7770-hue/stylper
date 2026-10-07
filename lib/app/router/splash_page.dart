import 'package:flutter/material.dart';

import '../../core/widgets/stylper_wordmark.dart';

/// Shown while the stored session is being restored.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: StylperWordmark()));
  }
}
