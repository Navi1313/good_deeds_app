import 'dart:async';
import 'dart:developer';
import 'package:app_ui/app_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:good_deeds_app/app/app.dart';
import 'package:good_deeds_app/l10n/slang/translations.g.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

typedef AppBuilder = Future<Widget> Function(
  PowerSyncRepository powersyncRepository,
);

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logD('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logD('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  AppBuilder builder, {
  required FirebaseOptions options,
  required AppFlavor appflavor,
}) async {
  FlutterError.onError = (details) {
    logE(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setUpDi(appFlavor: appflavor);

    // Awaiting firebase initialization :->
    await Firebase.initializeApp(
      name: 'good-deeds-dev',
      options: options,
    );

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getTemporaryDirectory(),
    );

    FlutterError.onError = (details) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    };
    // set bloc Observer ...
    Bloc.observer = const AppBlocObserver();

    final powerSyncRepository = PowerSyncRepository(env: appflavor.getEnv);
    await powerSyncRepository.initialize();

    SystemUiOverlayTheme.setPortraitOrientation();

    runApp(
      TranslationProvider(
        child: await builder(
          powerSyncRepository,
        ),
      ),
    );
  }, (error, stack) {
    logE(
      error.toString(),
      stackTrace: stack,
    );
  });
}
