import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_guard.dart';
import 'upload_remote_data_source.dart';

/// [UploadRemoteDataSource] on the `create-upload` / `finalize-upload` Edge
/// Functions (`supabase/functions/`), which hand out presigned URLs for
/// Cloudflare R2. The files go straight to R2, not through Supabase.
class SupabaseUploadRemoteDataSource implements UploadRemoteDataSource {
  SupabaseUploadRemoteDataSource(this._client, {http.Client? http})
    : _http = http ?? _defaultHttp;

  final SupabaseClient _client;
  final http.Client _http;

  static final _defaultHttp = http.Client();

  /// Past these, a call fails as offline instead of spinning on: a 1080 px
  /// WebP is well under a minute's upload even on a slow mobile network.
  static const _putTimeout = Duration(seconds: 60);
  static const _functionTimeout = Duration(seconds: 30);

  @override
  Future<Map<String, Object?>> createUpload(Map<String, Object?> body) =>
      _invoke('create-upload', body);

  /// The URL's signature covers `Content-Type: image/webp`, so it's sent
  /// exactly so; a bytes body keeps `http` from adding a charset.
  @override
  Future<void> putObject(String url, Uint8List bytes) async {
    final http.Response response;
    try {
      response = await _http
          .put(
            Uri.parse(url),
            headers: const {'Content-Type': 'image/webp'},
            body: bytes,
          )
          .timeout(_putTimeout);
    } on http.ClientException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException();
    }
    if (response.statusCode != 200) {
      // An expired or rejected URL; R2 answers in S3's XML.
      throw ServerException(
        statusCode: response.statusCode,
        code: ApiErrorCodes.uploadIncomplete,
      );
    }
  }

  @override
  Future<Map<String, Object?>> finalizeUpload(String mediaId) =>
      _invoke('finalize-upload', {'media_id': mediaId});

  Future<Map<String, Object?>> _invoke(
    String function,
    Map<String, Object?> body,
  ) => guardSupabase(() async {
    requireUserId(_client);
    final response = await _client.functions
        .invoke(function, body: body)
        .timeout(_functionTimeout);
    return (response.data as Map).cast<String, Object?>();
  });
}
