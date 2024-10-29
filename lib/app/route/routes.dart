import 'dart:async';

import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/bloc/app_bloc.dart';
import 'package:good_deeds_app/app/onboarding/on_boarding_provider.dart';
import 'package:good_deeds_app/app/onboarding/on_boarding_screen.dart';
import 'package:good_deeds_app/auth/auth.dart';
import 'package:good_deeds_app/feeds/feeds.dart';
import 'package:good_deeds_app/home/home.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/profile.dart';
import 'package:good_deeds_app/profile/view/userProfile.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_create_post.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_statistics.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
GoRouter router(AppBloc appBloc, WidgetRef ref) {
  final isOnBoardingCompleted = ref.watch(onboardingNotifierProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isOnBoardingCompleted ? '/feeds' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/profile/:user_id',
        name: 'user_profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['user_id']!;
          UserProfileProps? props;

          return CustomTransitionPage(
            key: state.pageKey,
            child: UserProfilePage(
              userId: userId,
              props: props ?? const UserProfileProps.build(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return HomePage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feeds',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const FeedsPage(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    child: const AppScaffold(
                      body: Text('timeline'),
                    ),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOut,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create_media',
                redirect: (context, state) => null,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/videos',
                pageBuilder: (context, state) {
                  final user = context.select(
                    (AppBloc bloc) => bloc.state.user,
                  );
                  return CustomTransitionPage(
                    child: AppScaffold(
                      body: UserPage(
                        userId: user.id,
                      ),
                    ),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOut,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) {
                  final user =
                      context.select((AppBloc bloc) => bloc.state.user);
                  return CustomTransitionPage(
                    child: UserProfilePage(
                      userId: user.id,
                    ),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'create_post',
                    name: 'create_post',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const UserProfileCreatePost(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        name: 'publish_post',
                        path: 'publish_post',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final props = state.extra! as CreatePostProps;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: CreatePostPage(props: props),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'edit_profile',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const UserProfileEdit(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'info/:label',
                        name: 'edit_profile_info',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final query = state.uri.queryParameters;
                          final label = state.pathParameters['label']!;
                          final appBarTitle = query['title']!;
                          final description = query['description'];
                          final infoValue = query['value'];
                          final infoType = state.extra as ProfileEditInfoType?;

                          return MaterialPage<void>(
                            fullscreenDialog: true,
                            child: ProfileInfoEditPage(
                              appBarTitle: appBarTitle,
                              description: description,
                              infoValue: infoValue,
                              infoLabel: label,
                              infoType: infoType!,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'statistics',
                    name: 'user_statistics',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final userId = state.uri.queryParameters['user_id']!;
                      const tabIndex = 0;
                      //final tabIndex = state.extra! ;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: BlocProvider(
                          create: (context) => ProfileBloc(
                            userId: userId,
                            userRepository: context.read<UserRepository>(),
                            postsRepository: context.read<PostsRepository>(),
                          )
                            ..add(const UserProfileSubscriptionRequested())
                            ..add(
                              // ignore: lines_longer_than_80_chars
                              const UserProfileFollowingsCountSubscriptionRequested(),
                            )
                            ..add(
                              // ignore: lines_longer_than_80_chars
                              const UserProfileFollowersCountSubscriptionRequested(),
                            ),
                          // ignore: lines_longer_than_80_chars
                          child: const UserProfileStatistics(
                            tabIndex: tabIndex,
                          ),
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authenticated = appBloc.state.status == AppStatus.authenticated;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuthPage = state.matchedLocation == '/auth';
      final isInFeed = state.matchedLocation == '/feeds';

      if (isInFeed && !authenticated) return '/auth';

      // 1. If onboarding is not completed, redirect to the onboarding page.
      if (!isOnBoardingCompleted && !isOnboarding) {
        return '/onboarding';
      }

      // 2. If onboarding is completed, redirect from the onboarding page to
      //  the auth page.
      if (isOnBoardingCompleted && isOnboarding) {
        return '/auth';
      }

      // 3. If authenticated, redirect from auth to the feeds page.
      if (authenticated && isAuthPage) {
        return '/feeds';
      }

      // 4. If not authenticated, redirect to the auth page unless the user
      // is already on it.
      if (!authenticated && !isAuthPage && !isOnboarding) {
        return '/auth';
      }

      return null;
    },
    refreshListenable: GoRouterAppBlocRefreshStream(appBloc.stream),
  );
}

/// {@template go_router_refresh_stream}
/// A [ChangeNotifier] that notifies listeners when a [Stream] emits a value.
/// This is used to rebuild the UI when the [AppBloc] emits a new state.
/// {@endtemplate}
class GoRouterAppBlocRefreshStream extends ChangeNotifier {
  /// {@macro go_router_refresh_stream}
  GoRouterAppBlocRefreshStream(Stream<AppState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((appState) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
