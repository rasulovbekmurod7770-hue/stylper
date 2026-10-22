import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/session/session_cubit.dart';
import 'core/config/backend_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseClient? supabase;
  if (BackendConfig.kind == BackendKind.supabase) {
    // Restores the session saved on the device, if any.
    await Supabase.initialize(
      url: BackendConfig.supabaseUrl,
      publishableKey: BackendConfig.supabasePublishableKey,
    );
    supabase = Supabase.instance.client;
  }
  configureDependencies(supabase: supabase);

  final session = sl<SessionCubit>()..start();
  runApp(StylperApp(session: session));
}
