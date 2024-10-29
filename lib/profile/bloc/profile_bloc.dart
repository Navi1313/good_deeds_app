import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
    required PostsRepository postsRepository,
    String? userId,
  })  : _userRepository = userRepository,
        _postsRepository = postsRepository,
        _userId = userId ?? userRepository.currentUserId ?? '',
        super(const UserProfileState.initial()) {
    on<UserProfileSubscriptionRequested>(
      _onUserProfileSubscriptionRequested,
    );
    on<UserProfilePostsCountSubscriptionRequested>(
      _onUserProfilePostsCountSubscriptionRequested,
    );
    on<UserProfileFollowersCountSubscriptionRequested>(
      _onUserProfileFollowersCountSubscriptionRequested,
    );
    on<UserProfileFollowingsCountSubscriptionRequested>(
      _onUserProfileFollowingsCountSubscriptionRequested,
    );
    on<UserProfileFollowUserRequested>(
      _onUserProfileFollowUserRequested,
    );
    on<UserProfileFetchFollowingsRequested>(
      _onUserProfileFetchFollowingsRequested,
    );
    on<UserProfileFollowersSubscriptionRequested>(
      _onUserProfileFollowersSubscriptionRequested,
    );
    on<UserProfileRemoveFollowerRequested>(
      _onUserProfileRemoveFollowerRequested,
    );
    on<UserProfileUpdateRequested>(
      _onUserProfileUpdateRequested,
    );
  }

  final UserRepository _userRepository;
  final String _userId;
  final PostsRepository _postsRepository;

  bool get isOwner => _userId == _userRepository.currentUserId;

  Stream<bool> followingStatus({String? followerId}) =>
      _userRepository.followingStatus(userId: _userId).asBroadcastStream();

  Future<void> _onUserProfileSubscriptionRequested(
    UserProfileSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      isOwner ? _userRepository.user : _userRepository.profile(id: _userId),
      onData: (user) => state.copyWith(user: user),
    );
  }

  Future<void> _onUserProfilePostsCountSubscriptionRequested(
    UserProfilePostsCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.postAmountOf(userId: _userId),
      onData: (postsCount) => state.copyWith(postsCount: postsCount),
    );
  }

  Future<void> _onUserProfileFollowingsCountSubscriptionRequested(
    UserProfileFollowingsCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followingCountOf(userId: _userId),
      onData: (followingsCount) =>
          state.copyWith(followingsCount: followingsCount),
    );
  }

  Future<void> _onUserProfileFollowersCountSubscriptionRequested(
    UserProfileFollowersCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followersCountOf(userId: _userId),
      onData: (followersCount) =>
          state.copyWith(followersCount: followersCount),
    );
  }

  Future<void> _onUserProfileFollowUserRequested(
    UserProfileFollowUserRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _userRepository.follow(followToId: event.userId ?? _userId);
    } catch (err, stacktrace) {
      addError(err, stacktrace);
    }
  }

  Future<void> _onUserProfileFollowersSubscriptionRequested(
    UserProfileFollowersSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followers(userId: _userId),
      onData: (followers) => state.copyWith(followers: followers),
    );
  }

  Future<void> _onUserProfileFetchFollowingsRequested(
    UserProfileFetchFollowingsRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final followings = await _userRepository.getFollowings(userId: _userId);
      emit(
        state.copyWith(
          followings: followings,
        ),
      );
    } catch (err, stackTrace) {
      addError(err, stackTrace);
    }
  }

  Future<void> _onUserProfileRemoveFollowerRequested(
    UserProfileRemoveFollowerRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _userRepository.removeFollowers(id: event.userId ?? _userId);
    } catch (err, stacktrace) {
      addError(err, stacktrace);
    }
  }

  Future<void> _onUserProfileUpdateRequested(
    UserProfileUpdateRequested event,
    Emitter<UserProfileState> emit,
  )async {
    try {
      await _userRepository.updateUser(
        email: event.email,
        username: event.username,
        avatarUrl: event.avatarUrl,
        fullName: event.fullName,
        pushToken: event.pushToken,
      );
      emit(state.copyWith(status: UserProfileStatus.userUpdated));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: UserProfileStatus.userUpdateFailed));
    }
  }

}
