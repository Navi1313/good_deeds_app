
import 'package:equatable/equatable.dart';
import 'package:good_deeds_block/good_deeds_block.dart';

class UserProfileProps extends Equatable {
  const UserProfileProps._({
    required this.isSponsored,
    required this.sponsoredPost,
    required this.promoBlockAction,
  });

  const UserProfileProps.build({
    bool? isSponsored,
    PostSponsoredBlock? sponsoredPost,
    BlockAction? promoBlockAction,
  }) : this._(
          isSponsored: isSponsored ?? false,
          sponsoredPost: sponsoredPost,
          promoBlockAction: promoBlockAction,
        );

  final bool isSponsored;
  final PostSponsoredBlock? sponsoredPost;
  final BlockAction? promoBlockAction;

  @override
  List<Object?> get props => [isSponsored, sponsoredPost, promoBlockAction];
}
