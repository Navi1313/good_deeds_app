// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// AvatarImagePicker displays a rectangular container image with rounded edges
/// that can be uploaded from the device.
///
/// Tapping the image opens an image picker to select a new image.
/// Provides option to compress images before uploading.
class BgImage extends StatefulWidget {
  const BgImage({
    this.compress = true,
    this.radius = 64,
    this.addButtonRadius = 18,
    this.placeholderSize = 54,
    this.withPlaceholder = true,
    this.onUpload,
    super.key,
  });

  final void Function(Uint8List, File)? onUpload;
  final bool compress;
  final double radius;
  final double addButtonRadius;
  final double placeholderSize;
  final bool withPlaceholder;

  @override
  State<BgImage> createState() => _BgImageState();
}

class _BgImageState extends State<BgImage> {
   Uint8List? imageBytes;
  /// Picks an image from the device's gallery or camera and passes the image
  /// bytes and file to the provided callback.
  ///
  /// Handles compressing the image before returning it.
  Future<void> _pickImage(BuildContext context) async {
    final file = await PickImage().pickImage(
      context,
      pickAvatar: true,
      source: ImageSource.both,
    );
    if (file == null) return;

    final selectedFile = file.selectedFiles.firstOrNull;
    if (selectedFile == null) return;
    final compressed =
        await ImageCompress.compressFile(selectedFile.selectedFile);
    final compressedFile = compressed == null ? null : File(compressed.path);
    final newFile = compressedFile ?? selectedFile.selectedFile;
    final compressedBytes = compressedFile == null
        ? null
        : await PickImage().imageBytes(file: compressedFile);
    final bytes = compressedBytes ?? selectedFile.selectedByte;
    widget.onUpload?.call(bytes, newFile);
  }

  @override
  Widget build(BuildContext context) => Tappable.faded(
      onTap: () => _pickImage.call(context),
      child: Stack(
        children: [
          // Main Container for image with circular edges
          Container(
            height: MediaQuery.of(context).size.height /
                5.5, // 1/5.5th screen height
            width: double.infinity, // Full width of screen
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(30), // Circular from edges
              image: imageBytes != null
                  ? DecorationImage(
                      image: MemoryImage(imageBytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageBytes == null && widget.withPlaceholder
                ? Assets.icons.bgimg.svg(
                    width: AppSpacing.xxxlg,
                    fit: BoxFit.fitWidth,
                  )
                // size: placeholderSize,
                // color: Colors.white,
                : null,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.ourColor,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: context.reversedAdaptiveColor,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: AppSize.iconSizeSmall,
              ),
            ),
          ),
        ],
      ),
    );
}
