import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

/// Display a photo from a base64 data URL or file path.
/// Use this everywhere instead of Image.file() or Image.memory() directly.
class WinePhoto extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const WinePhoto({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (ImageUtils.isDataUrl(path)) {
      final bytes = ImageUtils.dataUrlToBytes(path);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (_, __, ___) => _fallback(),
      );
    }
    // Non-data URL (legacy file path on mobile) — show broken placeholder
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: width ?? 80,
      height: height ?? 80,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery, returns bytes
  static Future<PhotoPickResult?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return null;
      final bytes = await image.readAsBytes();
      return PhotoPickResult(bytes: bytes, name: image.name);
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<PhotoPickResult>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      final results = <PhotoPickResult>[];
      for (final image in images) {
        final bytes = await image.readAsBytes();
        results.add(PhotoPickResult(bytes: bytes, name: image.name));
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Compress image bytes: resize to maxWidth, JPEG quality
  static Uint8List compressBytes(Uint8List input, {int maxWidth = 800, int quality = 80}) {
    try {
      final img.Image? decoded = img.decodeImage(input);
      if (decoded == null) return input;

      img.Image resized;
      if (decoded.width > maxWidth) {
        final scale = maxWidth / decoded.width;
        final newHeight = (decoded.height * scale).round();
        resized = img.copyResize(decoded, width: maxWidth, height: newHeight);
      } else if (decoded.height > maxWidth) {
        final scale = maxWidth / decoded.height;
        final newWidth = (decoded.width * scale).round();
        resized = img.copyResize(decoded, width: newWidth, height: maxWidth);
      } else {
        resized = decoded;
      }

      return img.encodeJpg(resized, quality: quality);
    } catch (e) {
      return input;
    }
  }

  /// Convert bytes to base64 data URL string (for DB storage)
  static String bytesToDataUrl(Uint8List bytes) {
    final base64Str = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Str';
  }

  /// Decode a stored data URL back to bytes
  static Uint8List dataUrlToBytes(String dataUrl) {
    final parts = dataUrl.split(',');
    if (parts.length < 2) return Uint8List(0);
    return base64Decode(parts[1]);
  }

  /// Check if a stored photo path is a data URL (new) or file path (legacy mobile)
  static bool isDataUrl(String path) {
    return path.startsWith('data:');
  }
}

/// Result of picking an image
class PhotoPickResult {
  final Uint8List bytes;
  final String name;

  const PhotoPickResult({required this.bytes, required this.name});
}
