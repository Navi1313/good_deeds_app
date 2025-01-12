// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// AvatarImagePicker displays a circular avatar image that can be uploaded
/// from the device.
///
/// Tapping the avatar opens an image picker to select a new image.
/// Provides option to compress images before uploading.
class AvatarImagePicker extends StatefulWidget {
  const AvatarImagePicker({
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
  State<AvatarImagePicker> createState() => _AvatarImagePickerState();
}

class _AvatarImagePickerState extends State<AvatarImagePicker> {

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

    setState(() =>
      imageBytes = bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => _pickImage.call(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey.shade500,
            backgroundImage:
                imageBytes == null ? null : MemoryImage(imageBytes!),
            child: imageBytes != null
                ? null
                : widget.withPlaceholder
                    ? Icon(
                        Icons.person,
                        size: widget.placeholderSize,
                      )
                    : null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
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
}
