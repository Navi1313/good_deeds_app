// ignore_for_file: public_member_api_docs

import 'package:env/env.dart';

enum Flavor { development, staging, production }

sealed class AppEnv {
  const AppEnv();

  String getEnv(Env env);
}

class AppFlavor extends AppEnv {
  const AppFlavor._({required this.flavor});

  factory AppFlavor.development() =>
      const AppFlavor._(flavor: Flavor.development);
  factory AppFlavor.staging() => const AppFlavor._(flavor: Flavor.staging);
  factory AppFlavor.production() =>
      const AppFlavor._(flavor: Flavor.production);

  final Flavor flavor;

  @override
  String getEnv(Env env) => switch (env) {
        Env.supabaseUrl => switch (flavor) {
            Flavor.development => EnvDev.supabaseUrl,
            Flavor.production => EnvProd.supabaseUrl,
            Flavor.staging => EnvProd.supabaseUrl,
          },
        Env.powersyncUrl => switch (flavor) {
            Flavor.development => EnvDev.powersyncUrl,
            Flavor.production => EnvProd.powersyncUrl,
            Flavor.staging => EnvProd.powersyncUrl,
          },
        Env.supabaseAnonKey => switch (flavor) {
            Flavor.development => EnvDev.supabaseAnonKey,
            Flavor.production => EnvProd.supabaseAnonKey,
            Flavor.staging => EnvProd.supabaseAnonKey,
          },
        Env.iosClientId => switch (flavor) {
            Flavor.development => EnvDev.iosClientId,
            Flavor.production => EnvProd.iosClientId,
            Flavor.staging => EnvProd.iosClientId,
          },
        Env.webClientId => switch (flavor) {
            Flavor.development => EnvDev.webClientId,
            Flavor.production => EnvProd.webClientId,
            Flavor.staging => EnvProd.webClientId,
          }
      };
}
