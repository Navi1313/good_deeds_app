import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:good_deeds_app/app/di/di.dart';
import 'package:good_deeds_app/app/view/app.dart';
import 'package:good_deeds_app/bootstrap.dart';
import 'package:good_deeds_app/firebase_options_stg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:superbase_authentication_client/superbase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {

  bootstrap(
    (powerSyncRepository) async {
      final iosClientID = getIt<AppFlavor>().getEnv(Env.iosClientId);
      final webClientID = getIt<AppFlavor>().getEnv(Env.webClientId);
      final tokenStorage = InMemoryTokenStorage();
      final googleSignIn = GoogleSignIn(
        clientId: iosClientID,
        serverClientId: webClientID ,
      );
      final supabaseAuthClient = SupabaseAuthenticationClient(
        powerSyncRepository: powerSyncRepository,
        tokenStorage: tokenStorage,
        googleSignIn: googleSignIn,
      );
      final powerSyncDatabaseClient =
          PowerSyncDatabaseClient(powerSyncRepository: powerSyncRepository);
      final userRepository = UserRepository(
        databaseClient: powerSyncDatabaseClient,
        authenticationClient: supabaseAuthClient,
      );
      final postRepository =
          PostsRepository(databaseClient: powerSyncDatabaseClient);
      return App(
        user: await userRepository.user.first,
        userRepository: userRepository,
        postsRepository: postRepository,
      );
    },
    options: DefaultFirebaseOptions.currentPlatform,
    appflavor: AppFlavor.development(),
    // ignore: lines_longer_than_80_chars
  );
}
