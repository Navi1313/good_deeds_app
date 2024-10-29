import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/onboarding/donor_status_provider.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_trust_score.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_you_trust.dart';

class UserProfileStatistics extends ConsumerStatefulWidget {
  const UserProfileStatistics({
    required this.tabIndex,
    super.key,
  });
  final int tabIndex;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileStatisticsState();
}

class _UserProfileStatisticsState extends ConsumerState<UserProfileStatistics>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _tabController.animateTo(widget.tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDonor = ref.watch<bool>(donorStatusProvider);
    return AppScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: UserProfileStatisticsAppBar(controller: _tabController),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            if (!isDonor)
              const UserProfileTrustScore()
            else
              const UserProfileYouTrust(),
            const Column(),
          ],
        ),
      ),
    );
  }
}

class UserProfileStatisticsAppBar extends ConsumerWidget {
  const UserProfileStatisticsAppBar({
    required this.controller,
    super.key,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  final followers = context.select((ProfileBloc b)
    //=> b.state.followersCount);

    // final followings =
    //context.select((ProfileBloc b) => b.state.followingsCount);
    final user = context.select((ProfileBloc b) => b.state.user);

    final isDonor = ref.watch<bool>(donorStatusProvider);

    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      title: Text(user.displayUsername),
      bottom: TabBar(
        indicatorWeight: 1,
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        labelColor: context.adaptiveColor,
        labelStyle: context.bodyLarge,
        labelPadding: EdgeInsets.zero,
        unselectedLabelStyle: context.bodyLarge,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: context.adaptiveColor,
        tabs: [
          if (!isDonor)
            const Tab(text: 'People Who Trust You')
          else
            const Tab(text: 'My Network'),
          const Tab(
            text: '   ',
          ),
        ],
      ),
    );
  }
}
