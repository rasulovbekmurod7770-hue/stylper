// Shared by the live tests in this folder (see auth_onboarding_live_test.dart
// for how to run them).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stylper/core/config/backend_config.dart';
import 'package:stylper/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:stylper/features/auth/domain/entities/app_user.dart';
import 'package:stylper/features/auth/domain/entities/sign_up_result.dart';
import 'package:stylper/features/auth/domain/failures/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const livePassword = 'stylper123';

/// Admin key of the local stack, for tests that need admin calls.
const liveSecretKey = String.fromEnvironment('SUPABASE_SECRET_KEY');

/// Local Mailpit, where the local stack delivers its emails.
final _mailpit = Uri.parse('http://127.0.0.1:54324');

/// A client with the app's settings (PKCE), minus the device storage and
/// auto-refresh.
SupabaseClient liveClient() {
  expect(
    BackendConfig.supabaseUrl,
    isNotEmpty,
    reason: 'run with --dart-define-from-file=env/test.json',
  );
  return SupabaseClient(
    BackendConfig.supabaseUrl,
    BackendConfig.supabasePublishableKey,
    authOptions: AuthClientOptions(
      autoRefreshToken: false,
      pkceAsyncStorage: _MemoryStorage(),
    ),
  );
}

/// An address and a username no earlier run has used.
({String email, String username}) newAccount(String prefix) {
  final stamp = DateTime.now().microsecondsSinceEpoch;
  return (
    email: '$prefix.$stamp@stylper.test',
    username: '${prefix}_${stamp % 100000000}',
  );
}

Future<AppUser> signInLive(SupabaseAuthRepository auth, String email) async =>
    (await auth.signInWithEmail(
      email: email,
      password: livePassword,
    )).getOrElse((f) => fail('sign-in failed: ${f.reason}'));

/// Signs up a new account and returns it signed in, through the
/// confirmation link when the stack wants the email confirmed.
Future<AppUser> signUpLive(
  SupabaseClient client,
  SupabaseAuthRepository auth,
  String email,
) async {
  final result = await auth.signUpWithEmail(
    email: email,
    password: livePassword,
  );
  switch (result.getOrElse((f) => fail('sign-up failed: ${f.reason}'))) {
    case SignedUp(:final user):
      printOnFailure('email confirmation is off: signed straight in');
      return user;
    case ConfirmationEmailSent(email: final sentTo):
      expect(sentTo, email);
      expect(auth.currentUser, isNull);
      expect(client.auth.currentSession, isNull);
      expect(
        (await auth.signInWithEmail(
          email: email,
          password: livePassword,
        )).getLeft().toNullable()?.reason,
        AuthFailureReason.emailNotConfirmed,
      );
      await _openConfirmationLink(email);
      return signInLive(auth, email);
  }
}

/// Opens the confirmation link Supabase emailed to [email], as the user would.
Future<void> _openConfirmationLink(String email) async {
  final search = _mailpit.replace(
    path: '/api/v1/search',
    queryParameters: {'query': 'to:"$email"'},
  );
  final found = jsonDecode((await http.get(search)).body) as Map;
  final messages = found['messages'] as List;
  expect(messages, isNotEmpty, reason: 'no confirmation email for $email');
  final message = await http.get(
    _mailpit.replace(path: '/api/v1/message/${(messages.first as Map)['ID']}'),
  );
  final html = (jsonDecode(message.body) as Map)['HTML'] as String;
  final link = RegExp(r'href="([^"]*/auth/v1/verify[^"]*)"').firstMatch(html);
  expect(link, isNotNull, reason: 'no verify link in the email');
  // Supabase confirms the address, then redirects to the site URL (not
  // running locally), so don't follow the redirect.
  final request = http.Request(
    'GET',
    Uri.parse(link!.group(1)!.replaceAll('&amp;', '&')),
  )..followRedirects = false;
  final response = await request.send();
  expect(response.statusCode, inInclusiveRange(300, 399));
}

class _MemoryStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}
