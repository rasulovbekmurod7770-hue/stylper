import '../config/backend_config.dart';

/// The public URL of an uploaded photo's storage key (`media.full_key` or
/// `thumb_key`), or null without one or without
/// [BackendConfig.imgPublicBase].
String? mediaUrl(String? key, {String base = BackendConfig.imgPublicBase}) {
  if (key == null || base.isEmpty) return null;
  final root = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  return '$root/$key';
}
