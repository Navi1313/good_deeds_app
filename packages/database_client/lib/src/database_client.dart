// ignore_for_file: public_member_api_docs

import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

abstract class UserBaseRepository {
  const UserBaseRepository();

  String? get currentUserId;

  Stream<User> profile({required String id});

  Stream<int> followersCountOf({required String userId});

  Stream<int> followingCountOf({required String userId});

  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  });

  /// the user identified by [userId].
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  });

  /// Follows to the user by provided [followToId]. [followerId] is the id
  /// of currently authenticated user.
  Future<void> follow({
    required String followToId,
    String? followerId,
  });

  /// Unfollow from user profile, identified by [unfollowId].
  Future<void> unfollow({required String unfollowId, String? unfollowerId});

  /// List of User folloers :->
  Stream<List<User>> followers({required String userId});

  /// List of User following :->
  Future<List<User>> getFollowings({String? userId});

  Future<void> removeFollowers({required String id});

  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  });
}

// ignore: one_member_abstracts
abstract class PostBaseRepository {
  const PostBaseRepository();
  Stream<int> postAmountOf({required String userId});

  /// Likes the post by provided either post or comment [id].
  Future<void> like({
    required String id,
    bool post = true,
  });

  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  });

  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  });

  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  });

  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  });
  Stream<int> likesOf({
    required String id,
    bool post = true,
  });

  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  });
  Stream<int> commentsAmountOf({required String postId});
}

abstract class DatabaseClient
    implements UserBaseRepository, PostBaseRepository {
  DatabaseClient();
}

class PowerSyncDatabaseClient implements DatabaseClient, PostBaseRepository {
  PowerSyncDatabaseClient({
    required PowerSyncRepository powerSyncRepository,
  }) : _poweSyncRepository = powerSyncRepository;

  final PowerSyncRepository _poweSyncRepository;

  @override
  String? get currentUserId =>
      _poweSyncRepository.supabase.auth.currentSession?.user.id;

  @override
  Stream<User> profile({required String id}) => _poweSyncRepository.db().watch(
        '''
SELECT * FROM profiles WHERE id = ? ''',
        parameters: [id],
      ).map(
        (event) => event.isEmpty ? User.anonymous : User.fromJson(event.first),
      );

  @override
  Stream<int> postAmountOf({required String userId}) =>
      _poweSyncRepository.db().watch(
        '''SELECT count(*) as posts_count FROM posts where user_id = ?''',
        parameters: [userId],
      ).map(
        (event) => event
            .safeMap(
              (element) => element['posts_count'],
            )
            .first as int,
      );

  @override
  Stream<int> followersCountOf({required String userId}) =>
      _poweSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscribed_to_id = ?',
        parameters: [userId],
      ).map(
        (event) => event
            .safeMap((element) => element['subscription_count'])
            .first as int,
      );

  @override
  Stream<int> followingCountOf({required String userId}) =>
      _poweSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscriber_id = ?',
        parameters: [userId],
      ).map(
        (event) => event
            .safeMap((element) => element['subscription_count'])
            .first as int,
      );

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) {
    if (followerId == null && currentUserId == null) {
      return const Stream.empty();
    }
    return _poweSyncRepository.db().watch(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      parameters: [followerId ?? currentUserId, userId],
    ).map((event) => event.isNotEmpty);
  }

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) async {
    if (currentUserId == null) return;
    if (followToId == currentUserId) return;
    final exists = await isFollowed(
      followerId: followerId ?? currentUserId!,
      userId: followToId,
    );
    if (!exists) {
      await _poweSyncRepository.db().execute(
        '''
          INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id)
            VALUES(uuid(), ?, ?)
      ''',
        [followerId ?? currentUserId!, followToId],
      );
      return;
    }
    await unfollow(
      unfollowId: followToId,
      unfollowerId: followerId ?? currentUserId!,
    );
  }

  @override
  Future<void> unfollow({
    required String unfollowId,
    String? unfollowerId,
  }) async {
    if (currentUserId == null) return;
    await _poweSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [unfollowerId ?? currentUserId, unfollowId],
    );
  }

  @override
  @override
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  }) async {
    final result = await _poweSyncRepository.db().execute(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      [followerId ?? currentUserId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  }) async {
    if (currentUserId == null) return null;
    final result = await Future.wait([
      _poweSyncRepository.db().execute(
        '''
    INSERT INTO posts(id, user_id  , caption, media, created_at)
    VALUES(?, ?, ?, ?, ?)
    RETURNING *
    ''',
        [
          id,currentUserId,caption,media,DateTime.timestamp().toIso8601String(),
        ],
      ),
      _poweSyncRepository.db().get(
        '''
SELECT * FROM profiles WHERE id = ?
''',
        [currentUserId],
      ),
    ]);
    if (result.isEmpty) return null;
    final row = Map<String, dynamic>.from((result.first as ResultSet).first);
    final author = User.fromJson(result.last as Row);
    return Post.fromJson(row).copyWith(author: author);
  }

  @override
  Future<List<User>> getFollowings({String? userId}) async {
    final followingsUserId = await _poweSyncRepository.db().getAll(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      [userId ?? currentUserId],
    );
    if (followingsUserId.isEmpty) return [];

    final followings = <User>[];
    for (final followingsUserId in followingsUserId) {
      final result = await _poweSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followingsUserId['subscribed_to_id']],
      );
      if (result.isEmpty) continue;
      final following = User.fromJson(result.first);
      followings.add(following);
    }
    return followings;
  }

  @override
  Stream<List<User>> followers({required String userId}) async* {
    final streamResult = _poweSyncRepository.db().watch(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      parameters: [userId],
    );
    await for (final result in streamResult) {
      final followers = <User>[];
      final followersFutures = await Future.wait(
        result.where((row) => row.isNotEmpty).safeMap(
              (row) => _poweSyncRepository.db().getOptional(
                'SELECT * FROM profiles WHERE id = ?',
                [row['subscriber_id']],
              ),
            ),
      );
      for (final user in followersFutures) {
        if (user == null) continue;
        final follower = User.fromJson(user);
        followers.add(follower);
      }
      yield followers;
    }
  }

  @override
  Future<void> removeFollowers({required String id}) async {
    if (currentUserId == null) return;
    await _poweSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [id, currentUserId],
    );
  }

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  }) =>
      _poweSyncRepository.updateUser(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (username != null) 'username': username,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (pushToken != null) 'push_token': pushToken,
        },
      );

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  }) async {
    final result = await _poweSyncRepository.db().execute(
      '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  inner join profiles p on posts.user_id = p.id
ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    ''',
      [limit, offset],
    );

    final posts = <Post>[];

    for (final row in result) {
      final json = Map<String, dynamic>.from(row);
      final post = Post.fromJson(json);
      posts.add(post);
    }
    return posts;
  }

  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) async {
    final result = await _poweSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, username, full_name
FROM profiles
WHERE id IN (
    SELECT l.user_id
    FROM likes l
    WHERE l.post_id = ?1
    AND EXISTS (
        SELECT *
        FROM subscriptions f
        WHERE f.subscribed_to_id = l.user_Id
        AND f.subscriber_id = ?2
    ) AND id <> ?2
)
LIMIT ?3 OFFSET ?4
''',
      [postId, currentUserId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Stream<int> likesOf({required String id, bool post = true}) {
    final statement = post ? 'post_id' : 'comment_id';
    return _poweSyncRepository.db().watch(
      '''
SELECT COUNT(*) AS total_likes
FROM likes
WHERE $statement = ? AND $statement IS NOT NULL
''',
      parameters: [id],
    ).map((result) => result.safeMap((row) => row['total_likes']).first as int);
  }

  @override
  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  }) {
    final statement = post ? 'post_id' : 'comment_id';
    return _poweSyncRepository.db().watch(
      '''
      SELECT EXISTS (
        SELECT 1 
        FROM likes
        WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      )
''',
      parameters: [userId ?? currentUserId, id],
    ).map((event) => (event.first.values.first! as int).isTrue);
  }

  @override
  Stream<int> commentsAmountOf({required String postId}) =>
      _poweSyncRepository.db().watch(
        '''
SELECT COUNT(*) AS comments_count FROM comments
WHERE post_id = ? 
''',
        parameters: [postId],
      ).map(
        (result) => result.map((row) => row['comments_count']).first as int,
      );

  @override
  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _poweSyncRepository.db().getAll(
      '''
SELECT up.id, up.username, up.full_name, up.avatar_url
FROM profiles up
INNER JOIN likes l ON up.id = l.user_id
INNER JOIN posts p ON l.post_id = p.id
WHERE p.post_id ?
LIMIT ? OFFSET ?
''',
      [postId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<void> like({
    required String id,
    bool post = true,
  }) async {
    if (currentUserId == null) return;
    final statement = post ? 'post_id' : 'comment_id';
    final exists = await _poweSyncRepository.db().execute(
      'SELECT 1 FROM likes '
      'WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL',
      [currentUserId, id],
    );
    if (exists.isEmpty) {
      await _poweSyncRepository.db().execute(
        '''
          INSERT INTO likes(user_id, $statement, id)
            VALUES(?, ?, uuid())
      ''',
        [currentUserId, id],
      );
      return;
    }
    await _poweSyncRepository.db().execute(
      '''
          DELETE FROM likes 
          WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      ''',
      [currentUserId, id],
    );
  }
}
