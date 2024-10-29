import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/bloc/app_bloc.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_button.dart';
import 'package:good_deeds_block_ui/good_deeds_blockui.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileListTile extends ConsumerStatefulWidget {
  const UserProfileListTile({
    required this.user,
    required this.follower,
    super.key,
  });

  final User user;
  final bool follower;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileListTileState();
}

class _UserProfileListTileState extends ConsumerState<UserProfileListTile> {
  late Future<bool> _isFollowed;

  @override
  void initState() {
    super.initState();
    if (widget.follower) {
      _isFollowed =
          context.read<UserRepository>().isFollowed(userId: widget.user.id);
    }
  }

  void _removeFollower(BuildContext context) {
    context.confirmAction(
      title: 'remove',
      content: 'Are you sure you want to remove',
      yesText: 'Confirm',
      noText: 'Cancel',
      fn: () => context
          .read<ProfileBloc>()
          .add(UserProfileRemoveFollowerRequested(userId: widget.user.id)),
    );
  }

  void _follow(BuildContext context) => context
      .read<ProfileBloc>()
      .add(UserProfileFollowUserRequested(userId: widget.user.id));

  @override
  Widget build(BuildContext context) {
    // final isDonor = ref.watch<bool>(donorStatusProvider);
    final profile = context.select((ProfileBloc bloc) => bloc.state.user);
    final me = context.select((AppBloc bloc) => bloc.state.user);
    final isMe = widget.user.id == me.id;
    final isMine = me.id == profile.id;

    return Tappable(
      onTap: () => context.pushNamed(
        'user_profile',
        pathParameters: {'user_id': widget.user.id},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            UserProfileAvatar(
             avatarUrl: widget.user.avatarUrl,
              radius: 26,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style: context.bodyLarge!.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.user.displayFullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.follower && isMine)
                                FollowTextButton(
                                  wasFollowed: _isFollowed,
                                  user: widget.user,
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.user.username == 'TRUE' ||
                                      widget.user.username == null
                                  ? 'Donor'
                                  : 'NGO',
                              style: context.titleMedium?.copyWith(
                                fontWeight: AppFontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: AppColors.grey,

                                // Set your desired background color
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const Gap.h(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!(isMe && !isMine))
                              UserActionButton(
                                user: widget.user,
                                follower: widget.follower,
                                isMine: isMine,
                                isMe: isMe,
                                onTap: () => widget.follower
                                    ? !isMine
                                        ? _follow(context)
                                        : _removeFollower(context)
                                    : _follow(context),
                              ),
                            if (isMine) ...[
                              const Gap.h(AppSpacing.md),
                              Flexible(
                                child: Tappable(
                                  onTap: !widget.follower
                                      ? () {}
                                      : () => _removeFollower(context),
                                  child: const Icon(Icons.more_vert),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Optional spacing between Row and Text
                        // Your desired Text widget
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ].spacerBetween(width: AppSpacing.md),
        ),
      ),
    );
  }
}

class UserActionButton extends StatelessWidget {
  const UserActionButton({
    required this.user,
    required this.isMe,
    required this.isMine,
    required this.follower,
    required this.onTap,
    super.key,
  });

  final User user;
  final bool isMe;
  final bool isMine;
  final bool follower;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xs,
    );
    final textStyle =
        context.bodyLarge?.copyWith(fontWeight: AppFontWeight.semiBold);
    const fadeStrength = FadeStrength.md;

    late final Widget followerRemoveButton = UserProfileButton(
      onTap: onTap,
      label: 'remove',
      padding: padding,
      textStyle: textStyle,
      fadeStrength: fadeStrength,
    );
    late final Widget followingButton = BetterStreamBuilder(
      stream: context.read<UserRepository>().followingStatus(userId: user.id),
      builder: (context, isFollowed) {
        return UserProfileButton(
          onTap: onTap,
          label: isFollowed ? 'You Trust' : 'Trust it',
          padding: padding,
          textStyle: textStyle,
          fadeStrength: fadeStrength,
          color: isFollowed
              ? null
              : context.customReversedAdaptiveColor(
                  light: AppColors.ourColor,
                  dark: const Color.fromARGB(255, 253, 103, 183),
                ),
        );
      },
    );

    final child = switch ((follower, isMine, isMe)) {
      (true, true, false) => followerRemoveButton,
      (true, false, false) => followingButton,
      (false, true, false) => followingButton,
      (false, false, false) => followingButton,
      _ => null,
    };

    return switch (child) {
      null => const SizedBox.shrink(),
      final Widget child => Flexible(flex: 9, child: child),
    };
  }
}

class FollowTextButton extends StatelessWidget {
  const FollowTextButton({
    required this.wasFollowed,
    required this.user,
    super.key,
  });

  final Future<bool> wasFollowed;
  final User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: wasFollowed,
      builder: (context, snapshot) {
        final wasFollowed = snapshot.data;
        if (wasFollowed == null || wasFollowed) {
          return const SizedBox.shrink();
        }
        return BetterStreamBuilder<bool>(
          stream:
              context.read<UserRepository>().followingStatus(userId: user.id),
          builder: (context, followed) {
            if (followed && wasFollowed) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' • ',
                    style: context.bodyMedium,
                  ),
                  TextSpan(
                    text: followed ? 'You Trust' : 'Trust it ',
                    style: context.bodyMedium?.copyWith(
                      color: followed ? AppColors.white : AppColors.ourColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.read<ProfileBloc>().add(
                            UserProfileFollowUserRequested(userId: user.id),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
