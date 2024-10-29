import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/bloc/app_bloc.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/profile.dart';
import 'package:good_deeds_app/selector/locale/view/locale_selector.dart';
import 'package:good_deeds_app/selector/theme/view/theme_selector.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:user_repository/user_repository.dart';



class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    required this.userId,
    this.props = const UserProfileProps.build(),
    super.key,
  });

  final String userId;
  final UserProfileProps props;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        postsRepository: context.read<PostsRepository>(),
        userId: userId,
        userRepository: context.read<UserRepository>(),
      )
        ..add(const UserProfileSubscriptionRequested())
        ..add(const UserProfilePostsCountSubscriptionRequested())
        ..add(const UserProfileFollowersCountSubscriptionRequested())
        ..add(const UserProfileFollowingsCountSubscriptionRequested()),
      child: UserProfileView(
        userId: userId,
        props: props,
      ),
    );
  }
}

class UserProfileView extends StatefulWidget {
  const UserProfileView({required this.userId, required this.props, super.key});

  final String userId;
  final UserProfileProps props;
  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileBloc bloc) => bloc.state.user);
    return AppScaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    const UserProfileAppBar(),
                    if (!user.isAnonymous) ...[
                      UserProfileHeader(
                        userId: widget.userId,
                      ),
                      const TextAboveTabBar(),
                      SliverPersistentHeader(
                        pinned: !ModalRoute.of(context)!.isFirst,
                        delegate: const _UserProfileTabBarDelegate(
                          TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            indicatorWeight: 1,
                            tabs: [
                              Tab(
                                icon: Icon(Icons.event_note_rounded),
                                iconMargin: EdgeInsets.zero,
                              ),
                              Tab(
                                icon: Icon(Icons.grid_on),
                                iconMargin: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              UserPofileEvents(),
              UserPostsPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class UserPostsPage extends StatelessWidget {
  const UserPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Posts'));
  }
}

class UserPofileEvents extends StatelessWidget {
  const UserPofileEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Events'),
    );
  }
}

class TextAboveTabBar extends StatelessWidget {
  const TextAboveTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Events'),
            ],
          ),
        ),
        SizedBox(
          width: AppSpacing.md, // Adjust spacing as needed
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Posts'),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _UserProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _UserProfileTabBarDelegate(this.tabBar);

  final TabBar tabBar;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    throw UnimplementedError();
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overLapsContent,
  ) {
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: tabBar,
    );
  }
}

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((ProfileBloc bloc) => bloc.isOwner);
    final user = context.select((ProfileBloc b) => b.state.user);

    return SliverPadding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      sliver: SliverAppBar(
        centerTitle: false,
        pinned: ModalRoute.of(context)!.isFirst,
        floating: ModalRoute.of(context)!.isFirst,
        title: Row(
          children: [
            Flexible(
              flex: 12,
              child: Text(
                '${user.displayFullName} ',
                style: context.titleLarge?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (!isOwner)
            const UserProfileActions()
          else ...[
            const UserProfileAddMediaButton(),
            if (ModalRoute.of(context)?.isFirst ?? false) ...const [
              Gap.h(AppSpacing.md),
              UserProfileSettingsButton(),
            ],
          ],
        ],
      ),
    );
  }
}

// Adding Media Button  :=>
class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () {},
      child: Icon(Icons.adaptive.more_outlined, size: AppSize.iconSize),
    );
  }
}

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      //   onTap: () => context
      //       .showListOptionsModal(
      //     title: 'Create',
      //     options: createMediaModalOptions(
      //       reelLabel: 'Clip',
      //       postLabel: 'Post',
      //       storyLabel: 'Event',

      //       enableStory: true,
      //       goTo: (route, {extra}) => context.pushNamed(route, extra: extra),
      //       onCreateReelTap: () => PickImage().pickImagesAndVideos(
      //         context,
      //         onMediaPicked: (context, details) => context.pushNamed(
      //           'publish_post',
      //           extra: CreatePostProps(
      //             details: details,
      //             isReel: true,
      //           ),
      //         ),
      //       ),
      //     ),
      //   )
      //       .then((option) {
      //     if (option == null) return;
      //     option.onTap(context);
      //   }),
      onTap: () => Navigator.of(context).push(
        // ignore: inference_failure_on_instance_creation
        MaterialPageRoute(
          builder: (context) => const Test(),
        ),
      ),
      child: const Icon(
        Icons.add_box_outlined,
        size: AppSize.iconSize,
      ),
    );
  }
}

class LogoutModalOption extends StatelessWidget {
  const LogoutModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context.confirmAction(
        fn: () {
          context.pop();
          context.read<AppBloc>().add(const AppLogoutRequested());
        },
        title: 'log Out',
        content: 'Are you sure you want to Log Out',
        noText: 'cancel',
        yesText: 'log out',
      ),
      child: ListTile(
        title: Text(
          'Log Out',
          style: context.bodyLarge?.apply(color: AppColors.red),
        ),
        leading: const Icon(Icons.logout, color: AppColors.ourColor),
      ),
    );
  }
}

class UserProfileSettingsButton extends StatelessWidget {
  const UserProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context.showListOptionsModal(
        options: [
          ModalOption(child: const LocaleModalOption()),
          ModalOption(child: const ThemeSelectorModalOption()),
          ModalOption(child: const LogoutModalOption()),
        ],
      ).then((option) {
        if (option == null) return;
        void onTap() => option.onTap(context);
        onTap.call();
      }),
      child: Assets.icons.setting.svg(
        height: AppSize.iconSize,
        width: AppSize.iconSize,
        colorFilter: ColorFilter.mode(
          context.adaptiveColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
