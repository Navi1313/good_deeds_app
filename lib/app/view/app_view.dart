import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/app.dart';
import 'package:good_deeds_app/app/route/routes.dart';
import 'package:good_deeds_app/app/view/app_init_utils.dart';
import 'package:good_deeds_app/l10n/arb/app_localizations.dart';
import 'package:good_deeds_app/l10n/slang/translations.g.dart';
import 'package:good_deeds_app/selector/selector.dart';
import 'package:shared/shared.dart';

class AppView extends ConsumerWidget {
  const AppView({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final routerConfig = router(context.read<AppBloc>(), ref);
    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
WidgetsBinding.instance.addPostFrameCallback(
              (_) => LocaleSettings.setLocaleRaw(locale.languageCode),
            );
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (context, themeMode) {
            
            return AnimatedSwitcher(
              duration: 350.ms,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: MaterialApp.router(
                  theme: const AppTheme().theme,
                  themeMode: themeMode,
                  darkTheme: const AppDarkTheme().theme,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => initUtilities(context),
                    );
                  
                    return Stack(
                      children: [
                        child!,
                        AppSnackbar(key: snackbarKey),
                        AppLoadingIndeterminate(key: loadingIntermediateKey),
                      ],
                    );
                  },
                  routerConfig: routerConfig,
                  locale: locale,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
