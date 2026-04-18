import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotify_clone/services/image_service.dart';

/// Widget that intelligently loads images from multiple sources
/// Handles network images with caching + local asset fallbacks
class DynamicImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const DynamicImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // Resolve to ensure we have proper URL
    final resolvedUrl = ImageService.resolveImageUrl(imageUrl);

    // Network URL - use cached image loading
    if (ImageService.isNetworkUrl(resolvedUrl)) {
      return CachedNetworkImage(
        imageUrl: resolvedUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: backgroundColor ?? const Color(0xFF282828),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1DB954),
                ),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    }

    // Local asset - use Image.asset() with error fallback
    return Image.asset(
      resolvedUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? const Color(0xFF282828),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF666666),
          size: 32,
        ),
      ),
    );
  }
}
