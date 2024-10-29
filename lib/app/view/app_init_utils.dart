import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:good_deeds_app/l10n/slang/translations.g.dart';
import 'package:good_deeds_block_ui/good_deeds_blockui.dart';
import 'package:shared/shared.dart';

void initUtilities(BuildContext context) {
  PickImage().init(
    tabsTexts: const TabsTexts(
      photoText: 'photo',
      videoText: 'video',
      acceptAllPermissions: 'acceptAllPermissions',
      clearImagesText: 'clearImages',
      deletingText: 'deleting ',
      galleryText: 'gallery ',
      holdButtonText: 'hold Button',
      noMediaFound: 'no Media Found',
      notFoundingCameraText: 'not Founding Camera',
      noCameraFoundText: 'no CameraFoundText',
      newPostText: 'new Post ',
      newAvatarImageText: 'new Avatar Image',
    ),
  );

  BlockSettings().init(
    postDelegate: PostTextDelegate(
      cancelText: 'l10n.cancelText',
      editText: 'l10n.editText',
      deleteText: 'l10n.deleteText',
      deletePostText: 'l10n.deletePostText',
      deletePostConfirmationText: 'l10n.deletePostConfirmationText',
      notShowAgainText: 'l10n.notShowAgainText',
      blockAuthorConfirmationText: 'l10n.blockAuthorConfirmationText',
      blockAuthorText: 'l10n.blockAuthorText',
      blockPostAuthorText: 'l10n.blockPostAuthorText',
      blockText: 'l10n.blockText',
      noPostsText: 'l10n.noPostsText',
      visitSponsoredInstagramProfileText: 'l10n.visitSponsoredInstagramProfile',
      likedByText: (count, name, onUsernameTap) => t.likedBy(
        name: TextSpan(
          text: name,
          style: context.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
          recognizer: TapGestureRecognizer()..onTap = onUsernameTap,
        ),
        and: TextSpan(text: count < 1 ? '' : 'and'),
        others: TextSpan(
          text: 'l10n.othersText(count)',
          style: context.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
        ),
      ),
      sponsoredPostText: 'Sponsored Post',
      likesCountText: (int count) => '$count likes',
likesCountShortText: (int count) => 'likes count: $count',

    ),
    commentDelegate:  CommentTextDelegate(
      seeAllCommentsText: (int count) => 'See all $count comments',

      replyText: 'replyText',
    ),
    followDelegate: const FollowTextDelegate(
      followText: 'l10n.followUser',
      followingText: 'followingUser',
    ),
  );
}
