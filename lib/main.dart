import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/session/session_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  final session = sl<SessionCubit>()..start();
  runApp(StylperApp(session: session));
}
