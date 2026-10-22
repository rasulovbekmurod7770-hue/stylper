import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/exceptions.dart';

/// Runs a Supabase call from a remote data source and reports its errors the
/// way data sources do: [ServerException] with an [ApiErrorCodes] code, or
/// [NetworkException] when the server can't be reached.
///
/// [codes] maps Postgres / PostgREST error codes to API codes for this call,
/// e.g. `{'23505': ApiErrorCodes.usernameTaken}` where a unique violation means
/// the username is taken.
Future<T> guardSupabase<T>(
  Future<T> Function() call, {
  Map<String, String> codes = const {},
}) async {
  try {
    return await call();
  } on PostgrestException catch (e) {
    throw ServerException(
      statusCode: 400,
      code: codes[e.code] ?? _postgrestCodes[e.code] ?? e.code ?? 'unknown',
    );
  } on AuthRetryableFetchException {
    throw const NetworkException();
  } on AuthException {
    // The session is gone or couldn't be refreshed.
    throw const ServerException(
      statusCode: 401,
      code: ApiErrorCodes.unauthorized,
    );
  } on http.ClientException {
    throw const NetworkException();
  } on TimeoutException {
    throw const NetworkException();
  }
}

/// The signed-in user's id, or [ApiErrorCodes.unauthorized] without a session.
String requireUserId(SupabaseClient client) =>
    client.auth.currentUser?.id ??
    (throw const ServerException(
      statusCode: 401,
      code: ApiErrorCodes.unauthorized,
    ));

const _postgrestCodes = {
  'PGRST301': ApiErrorCodes.unauthorized, // JWT expired or invalid
  'PGRST303': ApiErrorCodes.unauthorized,
  '42501': ApiErrorCodes.unauthorized, // denied by RLS or a grant
  'PGRST116': ApiErrorCodes.notFound, // .single() found no row
  '23514': ApiErrorCodes.validation, // check constraint
  '22P02': ApiErrorCodes.validation, // malformed value
};
