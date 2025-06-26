import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_crop_utils.dart';

/// Picks an image from gallery or camera, crops it, and validates it.
///
/// - Shows snackbars on cancel/error.
/// - Applies a circular crop by default (for avatars).
/// - Rejects files > 5MB.
///
/// Returns a [File] or null.
Future<File?> pickAndCropImage({
  required BuildContext context,
  ImageSource source = ImageSource.gallery,
  bool isCircular = true,
  int maxSizeBytes = 5 * 1024 * 1024, // 5MB max
}) async {
  final picker = ImagePicker();

  try {
    // Step 1: Pick image
    final picked = await picker.pickImage(source: source);
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selection cancelled')),
      );
      return null;
    }

    // Step 2: Crop image using shared utility
    final cropped = await cropImage(
      File(picked.path),
      context: context,
      isCircular: isCircular,
    );

    if (cropped == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image crop cancelled')),
      );
      return null;
    }

    // Step 3: Validate file size
    if (await cropped.length() > maxSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image too large. Max 5MB allowed.')),
      );
      return null;
    }

    return cropped;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image error: ${e.toString()}')),
    );
    return null;
  }
}
