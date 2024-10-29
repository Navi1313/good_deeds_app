// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/app.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileCreatePost extends StatelessWidget {
  const UserProfileCreatePost({
    this.canPop = true,
    this.imagePickerKey,
    this.onPopInvoked,
    this.onBackButtonTap,
    super.key,
  });

  final bool canPop;
  final Key? imagePickerKey;
  final VoidCallback? onBackButtonTap;
  final VoidCallback? onPopInvoked;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;
        onPopInvoked?.call();
      },
      child: PickImage().customMediaPicker(
        key: imagePickerKey,
        context: context,
        source: ImageSource.both,
        pickerSource: PickerSource.both,
        onMediaPicked: (details) => context.pushNamed(
          'publish_post',
          extra: CreatePostProps(details: details),
        ),
        onBackButtonTap:
            onBackButtonTap != null ? () => onBackButtonTap?.call() : null,
      ),
    );
  }
}

class CreatePostProps {
  const CreatePostProps({
    required this.details,
    this.isReel = false,
    this.context,
  });

  final SelectedImagesDetails details;
  final bool isReel;
  final BuildContext? context;
}

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({required this.props, super.key});

  final CreatePostProps props;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late TextEditingController _captionController;
  late List<Media> _media;

  List<SelectedByte> get selectedFiles => widget.props.details.selectedFiles;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    _media = selectedFiles
        .map(
          (e) => e.isThatImage
              ? MemoryImageMedia(bytes: e.selectedByte, id: uuid.v4())
              : MemoryVideoMedia(id: uuid.v4(), file: e.selectedFile),
        )
        .toList();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _onShareTap(String caption) async {
    void goHome() {
      if (widget.props.isReel) {
        context
          ..pop()
          ..pop();
      } else {
        //TODOS
      }
    }

    final navigateToReelPage = widget.props.isReel ||
        (selectedFiles.length == 1 &&
            selectedFiles.every((e) => !e.isThatImage));

      // TODO
    StatefulNavigationShell.maybeOf(context)
        ?.goBranch(navigateToReelPage ? 3 : 0, initialLocation: true);

    try {
      toggleLoadingIndeterminate();

      final postId = uuid.v4();
      void uploadPost({
        required List<Map<String, dynamic>> media,
      }) =>   
          context.read<PostsRepository>().createPost(
                id: postId,
                caption: caption,
                media: jsonEncode(_media),
              );
      if (widget.props.isReel) {
        try {
          late final postId = uuid.v4();
          late final storage = Supabase.instance.client.storage.from('posts');

          late final mediaPath = '$postId/video_0';

          final selectedFile = selectedFiles.first;
          final firstFrame = await VideoPlus.getVideoThumbnail(
            selectedFile.selectedFile,
          );

          final blurHash = firstFrame == null
              ? ''
              : await BlurHashPlus.blurHashEncode(firstFrame);

          final compressedVideo = (await VideoPlus.compressVideo(
                selectedFile.selectedFile,
              ))
                  ?.file ??
              selectedFile.selectedFile;

          final compressedVideoBytes =
              await PickImage().imageBytes(file: compressedVideo);

          final attachment = AttachmentFile(
            size: compressedVideoBytes.length,
            bytes: compressedVideoBytes,
            path: compressedVideo.path,
          );

          await storage.uploadBinary(
            mediaPath,
            attachment.bytes!,
            fileOptions: FileOptions(
              contentType: attachment.mediaType!.mimeType,
              cacheControl: '9000000',
            ),
          );

          final mediaUrl = storage.getPublicUrl(mediaPath);
          String? firstFrameUrl;

          if (firstFrame != null) {
            late final firstFramePath = '$postId/video_first_frame_0';

            await storage.uploadBinary(
              firstFramePath,
              firstFrame,
              fileOptions: FileOptions(
                contentType: attachment.mediaType!.mimeType,
                cacheControl: '9000000',
              ),
            );
            firstFrameUrl = storage.getPublicUrl(firstFramePath);
          }
          final media = [
            {
              'media_id': uuid.v4(),
              'url': mediaUrl,
              'type': VideoMedia.identifier,
              'blur_hash': blurHash,
              'first_frame_url': firstFrameUrl,
            },
          ];
          uploadPost(media: media);
        } catch (error, stackTrace) {
          logE(
            'Failed to create reel',
            stackTrace: stackTrace,
          );
        }
      } else {
        final storage = Supabase.instance.client.storage.from('posts');
        final media = <Map<String, dynamic>>[];
        for (var i = 0; i < selectedFiles.length; i++) {
          late final selectedByte = selectedFiles[i].selectedByte;
          late final selectedFile = selectedFiles[i].selectedFile;
          late final isVideo = selectedFile.isVideo;

          String blurHash;
          Uint8List? convertedBytes;
          if (isVideo) {
            convertedBytes = await VideoPlus.getVideoThumbnail(
              selectedFile,
            );
            blurHash = convertedBytes == null
                ? ''
                : await BlurHashPlus.blurHashEncode(
                    convertedBytes,
                  );
          } else {
            blurHash = await BlurHashPlus.blurHashEncode(
              selectedByte,
            );
          }
          late final mediaExtension =
              selectedFile.path.split('.').last.toLowerCase();

          late final mediaPath =
              '$postId/${!isVideo ? 'image_$i' : 'video_$i'}';
          Uint8List bytes;
          if (isVideo) {
            try {
              final compressedVideo = await VideoPlus.compressVideo(
                selectedFile,
              );

              bytes = await PickImage().imageBytes(
                file: compressedVideo!.file!,
              );
            } catch (err, stackTrace) {
              logE(
                'Error Compressing value',
                error: err,
                stackTrace: stackTrace,
              );
              bytes = selectedByte;
            }
          } else {
            bytes = selectedByte;
          }
          await storage.uploadBinary(
            mediaPath,
            bytes,
            fileOptions: FileOptions(
              contentType: '${!isVideo ? 'image' : 'video'}/$mediaExtension',
              cacheControl: '9000000',
            ),
          );
          final mediaUrl = storage.getPublicUrl(mediaPath);
          String? firstFrameUrl;
          if (convertedBytes != null) {
            late final firstFramePath = '$postId/video_first_frame_$i';

            await storage.uploadBinary(
              firstFramePath,
              convertedBytes,
              fileOptions: FileOptions(
                contentType: 'video/$mediaExtension',
                cacheControl: '9000000',
              ),
            );
            firstFrameUrl = storage.getPublicUrl(firstFramePath);
          }
          final mediaType =
              isVideo ? VideoMedia.identifier : ImageMedia.identifier;
          if (isVideo) {
            media.add({
              'media_id': uuid.v4(),
              'url': mediaUrl,
              'type': mediaType,
              'blur_hash': blurHash,
              'first_frame_url': firstFrameUrl,
            });
          } else {
            media.add({
              'media_id': uuid.v4(),
              'url': mediaUrl,
              'type': mediaType,
              'blur_hash': blurHash,
              'first_frame_url': firstFrameUrl,
            });
          }
          uploadPost(media: media);
        }
      }
      goHome.call();
      toggleLoadingIndeterminate(enable: false);
      openSnackBar(
        const SnackbarMessage.success(title: 'Successfully Created Post!'),
      );
    } catch (error, stackTrace) {
      toggleLoadingIndeterminate(enable: false);
      logE('Failed to create post', error: error, stackTrace: stackTrace);
      openSnackBar(
        const SnackbarMessage.error(title: 'Failed to create post!'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Post'),
      ),
      bottomNavigationBar: PublishPostButton(
        onShareTap: () => _onShareTap(_captionController.text.trim()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap.v(AppSpacing.sm),
            const Gap.v(AppSpacing.sm),
            CaptionInputField(
              captionController: _captionController,
              caption: _captionController.text.trim(),
              onSubmitted: _onShareTap,
            ),
          ],
        ),
      ),
    );
  }
}

class CaptionInputField extends StatefulWidget {
  const CaptionInputField({
    required this.captionController,
    required this.caption,
    required this.onSubmitted,
    super.key,
  });
  final TextEditingController captionController;
  final String caption;
  final ValueSetter<String> onSubmitted;
  @override
  State<CaptionInputField> createState() => _CaptionInputFieldState();
}

class _CaptionInputFieldState extends State<CaptionInputField> {
  late String _initialCaption;

  @override
  void initState() {
    _initialCaption = widget.caption;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CaptionInputField oldWidget) {
    if (oldWidget.caption != _initialCaption) {
      setState(() => _initialCaption = widget.caption);
    }
    super.didUpdateWidget(oldWidget);
  }

  String _effectiveValue(String? value) =>
      value ?? widget.captionController.text.trim();

  bool _equals(String? value) => _initialCaption == _effectiveValue(value);
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      border: InputBorder.none,
      textController: widget.captionController,
      contentPadding: EdgeInsets.zero,
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      hintText: 'Write Caption...',
      onFieldSubmitted: (value) =>
          _equals(value) ? null : widget.onSubmitted(_effectiveValue(value)),
    );
  }
}

class PublishPostButton extends StatelessWidget {
  const PublishPostButton({required this.onShareTap, super.key});

  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: context.reversedAdaptiveColor,
      padding: EdgeInsets.zero,
      height: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Tappable(
              onTap: onShareTap,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: AppColors.ourColor,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              child: Align(
                child: Text(
                  'Share Post',
                  style: context.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
