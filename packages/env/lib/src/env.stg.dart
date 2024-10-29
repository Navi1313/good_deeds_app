import 'package:envied/envied.dart';

part 'env.stg.g.dart';

/// {@template env}
// ignore: lines_longer_than_80_chars
/// Staging Environment variables. Used to access environment variables in the app
/// {@endtemplate}
@Envied(path: '.env.stg', obfuscate: true)
abstract class EnvStaging {
  /// Supabase url secret.
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static String supabaseUrl = _EnvStaging.supabaseUrl;

  /// Supabase anon key secret.
  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _EnvStaging.supabaseAnonKey;

  /// PowerSync ulr secret.
  @EnviedField(varName: 'POWERSYNC_URL', obfuscate: true)
  static String powersyncUrl = _EnvStaging.powersyncUrl;

  /// Ios  ulr secret.
  @EnviedField(varName: 'IOS_CLIENT_ID', obfuscate: true)
  static String iosClientId = _EnvStaging.iosClientId;

  /// Web ulr secret.
  @EnviedField(varName: 'WEB_CLIENT_ID', obfuscate: true)
  static String webClientId = _EnvStaging.webClientId;
}
