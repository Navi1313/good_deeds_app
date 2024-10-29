import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

part 'feed_bloc_mixin.dart';
part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> with FeedBlocMixin {
  FeedBloc({
    required PostsRepository postsRepository,
  })  : _postsRepository = postsRepository,
        super(const FeedState.initial()) {
    // Registering the handler for the FeedPageRequested event
    on<FeedPageRequested>(_onPageRequested);
    on<FeedRefreshRequested>(
      _onFeedRefreshRequested,
    );
    on<FeedRecommendedPostsPageRequested>(
      _onFeedRecommendedPostsPageRequested,
    );
  }

  final PostsRepository _postsRepository;

  Future<void> _onPageRequested(
    FeedPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final currentPage = event.page ?? state.feed.feedPage.page;
      final (:newPage, :hasMore, :blocks) =
          await fetchFeedPage(page: currentPage);

      // Update the feed state with the new page data
      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          page: newPage,
          hasMore: hasMore,
          blocks: [...state.feed.feedPage.blocks, ...blocks],
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));
    } catch (err, stackTrace) {
      addError(err, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    logI('Feed Refresh Requestred');
    emit(state.loading());
    try {
      final (:newPage, :hasMore, :blocks) = await fetchFeedPage();

      // Update the feed state with the new page data
      final feed = state.feed.copyWith(
        feedPage: FeedPage(
          page: newPage,
          hasMore: hasMore,
          blocks: blocks,
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));
      if (!hasMore) add(const FeedRecommendedPostsPageRequested());
    } catch (err, stackTrace) {
      addError(err, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedRecommendedPostsPageRequested(
    FeedRecommendedPostsPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    const FeedRecommendedPostsPageRequested();
  }

  @override
  PostsRepository get postsRepository => _postsRepository;
}

// Unique extension to prevent conflicts
extension PostToLargeBlockConverter on Post {
  PostLargeBlock get toPostLargeBlock => PostLargeBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author.id,
          avatarUrl: author.avatarUrl,
          username: author.fullName,
        ),
        createdAt: createdAt,
        media: media,
        caption: caption,
        action: NavigateToPostAuthorProfileAction(authorId: author.id),
      );
}
