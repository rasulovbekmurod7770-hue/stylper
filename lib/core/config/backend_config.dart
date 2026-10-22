/// Which backend the app talks to, chosen at build time with
/// `--dart-define-from-file=env/<target>.json` (see `env/example.json`).
///
/// The default is the in-memory [BackendKind.fake], so tests and goldens never
/// need a server. With [BackendKind.supabase], features already ported to
/// Supabase use it and the rest keep calling the fake backend.
enum BackendKind { fake, supabase }

abstract final class BackendConfig {
  static const _kind = String.fromEnvironment('BACKEND', defaultValue: 'fake');

  /// e.g. `http://10.0.2.2:54321` for the local stack on an Android emulator.
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The project's publishable key (`sb_publishable_…`); safe to ship in
  /// the app.
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static BackendKind get kind {
    final kind = BackendKind.values.asNameMap()[_kind];
    if (kind == null) {
      throw StateError('BACKEND must be "fake" or "supabase", not "$_kind".');
    }
    if (kind == BackendKind.supabase &&
        (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty)) {
      throw StateError(
        'BACKEND=supabase needs SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY '
        '(see env/example.json).',
      );
    }
    return kind;
  }
}
