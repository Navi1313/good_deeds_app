import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/app.dart';
import 'package:good_deeds_app/selector/selector.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

// ignore: comment_references
/// Key to accces [AppSnackBarState] from the [BuildContext]
final snackbarKey = GlobalKey<AppSnackbarState>();

final loadingIntermediateKey = GlobalKey<AppLoadingIndeterminateState>();

class App extends StatelessWidget {
  const App({
    required this.userRepository,
    required this.user,
    required this.postsRepository,
    super.key,
  });
  final PostsRepository postsRepository;
  final User user;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: postsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              user: user,
              userRepository: userRepository,
            ),
          ),
          BlocProvider(
            create: (context) => LocaleBloc(),
          ),
          BlocProvider(
            create: (context) => ThemeModeBloc(),
          ),
        ],
        child: const ProviderScope(
          child: AppView(),
        ),
      ),
    );
  }
}

void toggleLoadingIndeterminate({bool enable = true, bool autoHide = false}) =>
    loadingIntermediateKey.currentState
        ?.setVisibility(visible: enable, autoHide: autoHide);
void openSnackBar(
  SnackbarMessage message, {
  bool clearIfQueue = false,
  bool undismissable = false,
}) {
  snackbarKey.currentState?.post(
    message,
    clearIfQueue: clearIfQueue,
    undismissable: undismissable, // Corrected spelling
  );
}

void closeSnackBars() => snackbarKey.currentState?.closeAll();
