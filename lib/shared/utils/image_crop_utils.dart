import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

/// Crops the given [imageFile] using platform-native UI.
///
/// - If [isCircular] is true, displays a circular crop overlay.
/// - Uses a square aspect ratio (recommended for avatars).
/// - Applies consistent toolbar theming and sizing.
/// - Returns a new cropped [File], or null if user cancels.
Future<File?> cropImage(
  File imageFile, {
  required BuildContext context,
  bool isCircular = true,
}) async {
  final cropped = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    // Use platform-specific UI with theme-aware settings
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Theme.of(context).colorScheme.primary,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        cropStyle: isCircular ? CropStyle.circle : CropStyle.rectangle,
      ),
      IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: true,
        cropStyle: isCircular ? CropStyle.circle : CropStyle.rectangle,
      ),
      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
      ),
    ],
  );

  // Return a new file or null if cancelled
  if (cropped == null) return null;
  return File(cropped.path);
}
