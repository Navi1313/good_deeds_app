import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/feeds/bloc/feed_bloc.dart';
import 'package:good_deeds_app/feeds/post/view/post_view.dart';
import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:posts_repository/posts_repository.dart';

class FeedsPage extends StatelessWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        postsRepository: context.read<PostsRepository>(),
      ),
      child: const FeedsView(),
    );
  }
}

class FeedsView extends StatefulWidget {
  const FeedsView({super.key});

  @override
  State<FeedsView> createState() => _FeedsViewState();
}

class _FeedsViewState extends State<FeedsView> {
  @override
  void initState() {
    context.read<FeedBloc>().add(const FeedPageRequested(page: 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: FeedBody(),
    );
  }
}

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => Future.microtask(
        () =>
            // ignore: use_build_context_synchronously
            context.read<FeedBloc>().add(
                  const FeedRefreshRequested(),
                ),
      ),
      child: CustomScrollView(
        slivers: [
          BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              final blocks = state.feed.feedPage.blocks;

              if (blocks.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No posts available')),
                );
              }

              return SliverList.builder(
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  // Ensure index is within bounds of blocks list
                  if (index < blocks.length) {
                    final block = blocks[index];
                    return switch ('') {
                      _ when block is PostBlock => PostView(
                          block: block,
                          withInViewNotifier: false,
                        ),
                      _ => SizedBox(
                          child: Text('Unsupported block Type : ${block.type}'),
                        ),
                    };
                  } else {
                    // Return an empty widget if index is out of bounds
                    return const SizedBox.shrink();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
