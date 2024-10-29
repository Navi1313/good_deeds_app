import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/onboarding/donor_status_provider.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/profile.dart';
import 'package:good_deeds_block_ui/good_deeds_blockui.dart';
import 'package:shared/shared.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({
    required this.userId,
    super.key,
  });

  final String userId;
  void _pushToUserStatistics(BuildContext context, {required int tabIndex}) =>
      context
          .pushNamed('user_statistics', queryParameters: {'user_id': userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = context.select((ProfileBloc bloc) => bloc.state.user);
    final isOwner = context.select((ProfileBloc bloc) => bloc.isOwner);
    //final profile = context.select((ProfileBloc bloc) => bloc.state.user);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.topRight,
          child: Column(
            children: [
              Row(
                children: [
                  UserProfileAvatar(
                    avatarUrl: user.avatarUrl,
                    radius: 30,
                    onLongPress: (avatarUrl) => avatarUrl == null
                        ? null
                        : context.showImagePreview(avatarUrl),
                    onTap: (imageUrl) {
                      if (imageUrl == null) return;
                      if (!isOwner) context.showImagePreview(imageUrl);
                    },
                     
                  ),
                  const Gap.h(AppSpacing.md),
                  Expanded(
                    child: UserProfileStatisticsCounts(
                      onStatisticTap: (tabIndex) =>
                          _pushToUserStatistics(context, tabIndex: tabIndex),
                    ),
                  ),
                ],
              ),
              const Gap.v(AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        // ignore: lines_longer_than_80_chars
                        text: user.username == 'TRUE' || user.username == null
                            ? ' Donor Id: '
                            : ' NGO Id: ',
                        style: context.titleMedium?.copyWith(
                          fontWeight: AppFontWeight.semiBold,
                          backgroundColor: AppColors.ourColor,

                          // Set your desired background color
                        ),
                      ),
                      // if (isDonor)
                      //   TextSpan(
                      //     // ignore: lines_longer_than_80_chars
                      //     text: user.displayUsername == 'TRUE' ||
                      //     user.displayUsername == null
                      //         ? ' Donor Id: '
                      //         : ' NGO Id: ',
                      //     style: context.titleMedium?.copyWith(
                      //       fontWeight: AppFontWeight.semiBold,
                      //       backgroundColor: AppColors
                      //           .ourColor, // Set your desired background color
                      //     ),
                      //   ),
                      TextSpan(
                        text: '  ${user.email}',
                        style: context.titleMedium?.copyWith(
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap.v(AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOwner)
                    ...<Widget>[
                      const Flexible(flex: 3, child: EditProfileButton()),
                      const Flexible(flex: 3, child: ShareProfileButton()),
                      const Flexible(child: ShowSuggestedPeopleButton()),
                    ].spacerBetween(width: AppSpacing.sm)
                  else ...[
                    const Expanded(
                      flex: 3,
                      child: UserProfileFollowUserButton(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfileStatisticsCounts extends ConsumerWidget {
  const UserProfileStatisticsCounts({required this.onStatisticTap, super.key});

  final ValueSetter<int> onStatisticTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsCount =
        context.select((ProfileBloc bloc) => bloc.state.postsCount);
    final followersCount =
        context.select((ProfileBloc bloc) => bloc.state.followersCount);
    final followingCount =
        context.select((ProfileBloc bloc) => bloc.state.followingsCount);
    final isDonor = ref.read<bool>(donorStatusProvider);
    return Row(
      
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8), // Add padding between the buttons
            child: UserProfileStatistic(
              name: 'Posts',
              value: postsCount,
            ),
          ),
        ),
        if (isDonor)
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(8), // Add padding between the buttons
              child: UserProfileStatistic(
                name: 'Your Network',
                value: followingCount,
                onTap: () => onStatisticTap(1),
              ),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(8), // Add padding between the buttons
              child: UserProfileStatistic(
                name: 'Trust Score',
                value: followersCount,
                onTap: () => onStatisticTap(0),
              ),
            ),
          ),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      label: 'Edit Profile',
      onTap: () => context.pushNamed('edit_profile'),
    );
  }
}

class ShareProfileButton extends StatelessWidget {
  const ShareProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      label: '  Share Profile',
      onTap: () {},
    );
  }
}

class ShowSuggestedPeopleButton extends StatefulWidget {
  const ShowSuggestedPeopleButton({super.key});

  @override
  State<ShowSuggestedPeopleButton> createState() =>
      _ShowSuggestedPeopleButtonState();
}

class _ShowSuggestedPeopleButtonState extends State<ShowSuggestedPeopleButton> {
  var _showPeople = false;

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      onTap: () => setState(() => _showPeople = !_showPeople),
      child: Icon(
        _showPeople ? Icons.person_add_rounded : Icons.person_add_outlined,
        size: 20,
      ),
    );
  }
}

class UserProfileFollowUserButton extends StatelessWidget {
  const UserProfileFollowUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final user = context.select((ProfileBloc bloc) => bloc.state.user);

    return BetterStreamBuilder<bool>(
      stream: bloc.followingStatus(),
      builder: (context, isFollowed) {
        return UserProfileButton(
          label: isFollowed ? 'Already Trusting ▼' : 'Trust It',
          color: isFollowed
              ? null
              : context.customReversedAdaptiveColor(
                  light: AppColors.ourColor,
                  dark: AppColors.ourColor,
                ),
          onTap: isFollowed
              ? () async {
                  void callback(ModalOption option) =>
                      option.onTap.call(context);

                  final option = await context.showListOptionsModal(
                    title: user.fullName,
                    options: followerModalOptions(
                      unfollowLabel: 'Do not Trust',
                      onUnfollowTap: () =>
                          bloc.add(const UserProfileFollowUserRequested()),
                    ),
                  );
                  if (option == null) return;
                  callback.call(option);
                }
              : () => bloc.add(const UserProfileFollowUserRequested()),
        );
      },
    );
  }
}
