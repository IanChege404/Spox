import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify_clone/services/image_service.dart';

/// Utility class for extracting dominant colors from images
class ColorExtractor {
  /// Extract dominant color from an image URL
  ///
  /// Returns a Future that resolves to a Color extracted from the image.
  /// If extraction fails, defaults to a dark grey color.
  static Future<Color> getDominantColor(String imageUrl) async {
    try {
      final provider = _imageProvider(imageUrl);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        provider,
      );
      return paletteGenerator.dominantColor?.color ?? Colors.grey[900]!;
    } catch (e) {
      print('Error extracting dominant color: $e');
      return Colors.grey[900]!;
    }
  }

  /// Extract vibrant color from an image URL
  ///
  /// Returns a Future that resolves to a vibrant Color from the image.
  /// If extraction fails, defaults to a dark grey color.
  static Future<Color> getVibrantColor(String imageUrl) async {
    try {
      final provider = _imageProvider(imageUrl);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        provider,
      );
      return paletteGenerator.vibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          Colors.grey[900]!;
    } catch (e) {
      print('Error extracting vibrant color: $e');
      return Colors.grey[900]!;
    }
  }

  /// Extract a palette of colors from an image URL
  ///
  /// Returns a Future that resolves to a PaletteGenerator containing
  /// multiple colors extracted from the image.
  static Future<PaletteGenerator?> getPalette(String imageUrl) async {
    try {
      final provider = _imageProvider(imageUrl);
      return await PaletteGenerator.fromImageProvider(
        provider,
      );
    } catch (e) {
      print('Error extracting palette: $e');
      return null;
    }
  }

  /// Create a gradient using dominant and vibrant colors
  ///
  /// Useful for dynamic theme backgrounds that match album art
  static Future<LinearGradient> getGradient(String imageUrl) async {
    try {
      final palette = await getPalette(imageUrl);
      if (palette == null) {
        return LinearGradient(
          colors: [Colors.grey[900]!, Colors.grey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }

      final dominantColor = palette.dominantColor?.color ?? Colors.grey[900]!;
      final vibrantColor =
          palette.vibrantColor?.color ?? palette.dominantColor?.color;

      return LinearGradient(
        colors: vibrantColor != null
            ? [dominantColor, vibrantColor]
            : [dominantColor, dominantColor.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } catch (e) {
      print('Error creating gradient: $e');
      return LinearGradient(
        colors: [Colors.grey[900]!, Colors.grey[800]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  static ImageProvider _imageProvider(String imageUrl) {
    final resolvedUrl = ImageService.resolveImageUrl(imageUrl);
    if (ImageService.isNetworkUrl(resolvedUrl)) {
      return NetworkImage(resolvedUrl);
    }
    return AssetImage(resolvedUrl);
  }
}
