import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_crop_utils.dart';

/// Shows a dialog to select image source (camera or gallery), then picks and crops the image.
///
/// - Shows a bottom sheet with camera and gallery options
/// - Applies a circular crop by default (for avatars)
/// - Validates file size and shows appropriate error messages
///
/// Returns a [File] or null if cancelled/failed.
Future<File?> pickAndCropImage({
  required BuildContext context,
  bool isCircular = true,
  int maxSizeBytes = 5 * 1024 * 1024, // 5MB max
}) async {
  // Show source selection dialog
  final ImageSource? source = await _showImageSourceDialog(context);
  if (source == null) return null;

  // Pick and crop with selected source
  return await _pickAndCropImageWithSource(
    context: context,
    source: source,
    isCircular: isCircular,
    maxSizeBytes: maxSizeBytes,
  );
}

/// Shows a bottom sheet dialog to select image source
Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
  return await showModalBottomSheet<ImageSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      context: context,
                      icon: Icons.photo_camera,
                      label: 'Camera',
                      color: Colors.blue,
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceOption(
                      context: context,
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      color: Colors.green,
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Builds a source selection option widget
Widget _buildSourceOption({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

/// Picks an image from the specified source, crops it, and validates it.
///
/// - Shows snackbars on cancel/error
/// - Applies a circular crop by default (for avatars)
/// - Rejects files > 5MB
///
/// Returns a [File] or null.
Future<File?> _pickAndCropImageWithSource({
  required BuildContext context,
  required ImageSource source,
  bool isCircular = true,
  int maxSizeBytes = 5 * 1024 * 1024, // 5MB max
}) async {
  final picker = ImagePicker();

  try {
    // Step 1: Pick image
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selection cancelled')),
        );
      }
      return null;
    }

    // Step 2: Crop image using shared utility
    final cropped = await cropImage(
      File(picked.path),
      context: context,
      isCircular: isCircular,
    );

    if (cropped == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image crop cancelled')),
        );
      }
      return null;
    }

    // Step 3: Validate file size
    if (await cropped.length() > maxSizeBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large. Max 5MB allowed.')),
        );
      }
      return null;
    }

    return cropped;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image error: ${e.toString()}')),
      );
    }
    return null;
  }
}

/// Legacy function for backward compatibility - directly picks from specified source
Future<File?> pickAndCropImageFromSource({
  required BuildContext context,
  ImageSource source = ImageSource.gallery,
  bool isCircular = true,
  int maxSizeBytes = 5 * 1024 * 1024, // 5MB max
}) async {
  return await _pickAndCropImageWithSource(
    context: context,
    source: source,
    isCircular: isCircular,
    maxSizeBytes: maxSizeBytes,
  );
}
