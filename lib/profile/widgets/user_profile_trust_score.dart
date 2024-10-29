import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/widgets/user_Profile_list_tile.dart';

class UserProfileTrustScore extends StatefulWidget {
  const UserProfileTrustScore({super.key});

  @override
  State<UserProfileTrustScore> createState() => _UserProfileFollowersState();
}

class _UserProfileFollowersState extends State<UserProfileTrustScore>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ProfileBloc>()
        .add(const UserProfileFollowersSubscriptionRequested());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final followers =
        context.select((ProfileBloc bloc) => bloc.state.followers);

    return CustomScrollView(
      cacheExtent: 2760,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList.builder(
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final user = followers[index];
            return UserProfileListTile(user: user, follower: true);
          },
        ),
      ],
    );
  }
}
