import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'post_event.dart';
part 'post_state.dart';
part 'post_bloc.g.dart';

class PostBloc extends HydratedBloc<PostEvent, PostState> {
  PostBloc({
    required String postId,
    required PostsRepository postsRepository,
    required UserRepository userRepository,
  })  : _postsRepository = postsRepository,
        _userRepository = userRepository,
        _postId = postId,
        super(const PostState.initial()) {
    on<PostLikesCountSubscriptionRequested>(
      _onPostLikesCountSubscriptionRequested,
    );
    on<PostIsLikedSubscriptionRequested>(
      _onPostIsLikedSubscriptionRequested,
    );
    on<PostAuthorFollowingStatusSubscriptionRequested>(
      _onPostAuthorFollowingStatusSubscriptionRequested,
    );
    on<PostCommentsCountSubscriptionRequested>(
      _onPostCommentsCountSubscriptionRequested,
    );
    on<PostLikersInFollowingsFetchRequested>(
      _onPostLikersInFollowingsFetchRequested,
    );
    on<PostFetchLikersInFollowingRequested>(
      _onPostFetchLikersInFollowingRequested,
    );
    on<PostLikersPageRequested>(_onPostLikersPageRequested);
    on<PostLikeRequested>(_onPostLikeRequested);
    on<PostAuthorFollowRequested>(_onPostAuthorFollowRequested);
  }

  final String _postId;
  final PostsRepository _postsRepository;
  final UserRepository _userRepository;
  @override
  String get id => _postId;

  Future<void> _onPostLikesCountSubscriptionRequested(
    PostLikesCountSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.likesOf(
        id: id,
      ),
      onData: (likesCount) => state.copyWith(likes: likesCount),
    );
  }

  Future<void> _onPostIsLikedSubscriptionRequested(
    PostIsLikedSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.isLiked(id: id),
      onData: (isLiked) => state.copyWith(
        isLiked: isLiked,
      ),
    );
  }

  Future<void> _onPostAuthorFollowingStatusSubscriptionRequested(
    PostAuthorFollowingStatusSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    if (event.currentUserId == event.ownerId) {
      emit(state.copyWith(isOwner: true));
      return;
    }
    await emit.forEach(
      _userRepository.followingStatus(userId: event.ownerId),
      onData: (isFollowed) =>
          state.copyWith(isFollowed: isFollowed, isOwner: false),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: PostStatus.failure);
      },
    );
  }

  Future<void> _onPostCommentsCountSubscriptionRequested(
    PostCommentsCountSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.commentsAmountOf(postId: id),
      onData: (commentsCount) => state.copyWith(commentsCount: commentsCount),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: PostStatus.failure);
      },
    );
  }

  Future<void> _onPostLikersPageRequested(
    PostLikersPageRequested event,
    Emitter<PostState> emit,
  ) async {
    //final page = event.page;
    emit(state.copyWith(status: PostStatus.loading));
    try {
      // final users = await _postsRepository.getPostLikers(
      //   postId: id,
      //   offset: page * _usersLimit,
      //   limit: _usersLimit,
      // );
      //emit(state.copyWith(status: PostStatus.success, likers: users));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostFetchLikersInFollowingRequested(
    PostFetchLikersInFollowingRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      final likersInFollowing =
          await _postsRepository.getPostLikersInFollowings(postId: id);
      emit(state.copyWith(likersInFollowings:  likersInFollowing));
    } catch (errr, stackTrace) {
      addError(errr, stackTrace);
    }
  }

  Future<void> _onPostLikeRequested(
    PostLikeRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      await _postsRepository.like(id: id);
      emit(state.copyWith(status: PostStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostAuthorFollowRequested(
    PostAuthorFollowRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      await _userRepository.follow(followToId: event.authorId);
      emit(state.copyWith(status: PostStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostLikersInFollowingsFetchRequested(
    PostLikersInFollowingsFetchRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      final likersInFollowings =
          await _postsRepository.getPostLikersInFollowings(postId: id);
      emit(state.copyWith(likersInFollowings: likersInFollowings));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  @override
  PostState? fromJson(Map<String, dynamic> json) => PostState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(PostState state) => state.toJson();
}
