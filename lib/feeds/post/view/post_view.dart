import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/app.dart';
import 'package:good_deeds_app/feeds/bloc/feed_bloc.dart';
import 'package:good_deeds_app/feeds/post/bloc/post_bloc.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_props.dart';
import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:good_deeds_block_ui/good_deeds_blockui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class PostView extends StatelessWidget {
  const PostView({
    required this.block,
    this.builder,
    this.postIndex,
    this.withInViewNotifier = true,
    this.withCustomVideoPlayer = true,
    super.key,
  });

  final PostBlock block;
  final WidgetBuilder? builder;
  final int? postIndex;
  final bool withInViewNotifier;
  final bool withCustomVideoPlayer;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return BlocProvider(
      create: (context) => PostBloc(
        postId: block.id,
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      )
        ..add(const PostLikesCountSubscriptionRequested())
        ..add(const PostCommentsCountSubscriptionRequested())
        ..add(const PostIsLikedSubscriptionRequested())
        ..add(
          PostAuthorFollowingStatusSubscriptionRequested(
            ownerId: block.author.id,
            currentUserId: user.id,
          ),
        )
        ..add(const PostLikersInFollowingsFetchRequested())
        ..add(const PostFetchLikersInFollowingRequested()),
      child: builder?.call(context) ??
          PostLargeView(
            block: block,
            postIndex: postIndex,
            withInViewNotifier: withInViewNotifier,
            withCustomVideoPlayer: withCustomVideoPlayer,
          ),
    );
  }
}

class PostLargeView extends StatelessWidget {
  const PostLargeView({
    required this.block,
    required this.postIndex,
    required this.withInViewNotifier,
    required this.withCustomVideoPlayer,
    super.key,
  });

  final PostBlock block;
  final int? postIndex;
  final bool withInViewNotifier;
  final bool withCustomVideoPlayer;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostBloc>();

    final isOwner = context.select((PostBloc bloc) => bloc.state.isOwner);
    final isLiked = context.select((PostBloc bloc) => bloc.state.isLiked);
    final likesCount = context.select((PostBloc bloc) => bloc.state.likes);
    final isFollowed = context.select((PostBloc bloc) => bloc.state.isFollowed);
    final commentsCount =
        context.select((PostBloc bloc) => bloc.state.commentsCount);
    final likersInFollowings =
        context.select((PostBloc bloc) => bloc.state.likersInFollowings);

    if (block is PostSponsoredBlock) {}
    return PostLarge(
      block: block,
      isOwner: isOwner,
      isLiked: isLiked,
      likePost: () => bloc.add(const PostLikeRequested()),
      likesCount: likesCount,
      isFollowed: isOwner || (isFollowed ?? true),
      follow: () =>
          bloc.add(PostAuthorFollowRequested(authorId: block.author.id)),
      enableFollowButton: true,
      likersInFollowings: likersInFollowings,
      onCommentsTap: (showFullSized) {
        // TODO
      },
      commentsCount: commentsCount,
      postIndex: postIndex,
      withInViewNotifier: withInViewNotifier,

      //postAuthorAvatarBuilder: (context, author, onAvatarTap) {
      //   return UserStoriesAvatar(
      //     resizeHeight: 108,
      //     author: author.toUser,
      //     onAvatarTap: onAvatarTap,
      //     enableInactiveBorder: false,
      //     withAdaptiveBorder: false,
      //   );
      // },
      postOptionsSettings: isOwner
          ? PostOptionsSettings.owner(
              onPostEdit: (block) => context.pushNamed(
                'post_edit',
                pathParameters: {'post_id': block.id},
                extra: block,
              ),
              onPostDelete: (_) {
                bloc.add(const PostDeleteRequested());
                context.read<FeedBloc>().add(
                      const FeedUpdateRequested(),
                    );
              },
            )
          : const PostOptionsSettings.viewer(),
      onUserTap: (userId) => context.pushNamed(
        'user_profile',
        pathParameters: {
          'user_id': userId,
        },
      ),
      onPressed: (action) => action.when(
        navigateToPostAuthor: (action) => context.pushNamed(
          'user_profile',
          pathParameters: {
            'user_id': action.authorId,
          },
        ),
        navigateToSponsoredPostAuthor: (action) => context.pushNamed(
          'user_profile',
          pathParameters: {
            'user_id': action.authorId,
          },
          extra: UserProfileProps.build(
            isSponsored: true,
            promoBlockAction: action,
            sponsoredPost: bloc as PostSponsoredBlock,
          ),
        ),
      ),
      onPostShareTap: (String postId, PostAuthor author) {
        //TODO
      },
    );
  }
}
