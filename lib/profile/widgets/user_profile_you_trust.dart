import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/widgets/user_Profile_list_tile.dart';

class UserProfileYouTrust extends StatefulWidget {
  const UserProfileYouTrust({super.key});

  @override
  State<UserProfileYouTrust> createState() => _UserProfileFollowingsState();
}

class _UserProfileFollowingsState extends State<UserProfileYouTrust>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ProfileBloc>()
        .add(const UserProfileFetchFollowingsRequested());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final followings =
        context.select((ProfileBloc bloc) => bloc.state.followings);

    return CustomScrollView(
      cacheExtent: 2760,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList.builder(
          itemCount: followings.length,
          itemBuilder: (context, index) {
            final user = followings[index];
            return UserProfileListTile(user: user, follower: false);
          },
        ),
      ],
    );
  }
}
