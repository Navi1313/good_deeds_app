import 'package:envied/envied.dart';

part 'env.prod.g.dart';

/// {@template env}
/// Dev Environment variables. Used to access environment variables in the app.
/// {@endtemplate}
@Envied(path: '.env.prod', obfuscate: true)
abstract class EnvProd {
  /// Supabase url secret.
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static String supabaseUrl = _EnvProd.supabaseUrl;

  /// Supabase anon key secret.
  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _EnvProd.supabaseAnonKey;

  /// PowerSync ulr secret.
  @EnviedField(varName: 'POWERSYNC_URL', obfuscate: true)
  static String powersyncUrl = _EnvProd.powersyncUrl;

  /// Ios  ulr secret.
  @EnviedField(varName: 'IOS_CLIENT_ID', obfuscate: true)
  static String iosClientId = _EnvProd.iosClientId;

  /// Web ulr secret.
  @EnviedField(varName: 'WEB_CLIENT_ID', obfuscate: true)
  static String webClientId = _EnvProd.webClientId;


}
