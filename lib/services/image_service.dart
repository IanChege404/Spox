/// Service for handling image URLs and resolution
/// Supports multiple image sources: Spotify API, local assets, placeholders
/// Spotify URLs are primary - always fresh from Spotify CDN
class ImageService {
  /// Resolve image URL based on input
  /// Supports: Spotify URLs (primary), local assets (fallback)
  /// Returns network URL or asset path for Image widget to use
  static String resolveImageUrl(String? imageInput) {
    if (imageInput == null || imageInput.isEmpty) {
      return _getPlaceholderUrl('No Image');
    }

    // Already a full network URL (Spotify, etc.)
    if (imageInput.startsWith('http://') || imageInput.startsWith('https://')) {
      return imageInput;
    }

    // Local asset path - return as-is for Image.asset() usage
    if (imageInput.startsWith('images/')) {
      return imageInput;
    }

    // Fallback to placeholder
    return _getPlaceholderUrl(imageInput);
  }

  /// Generate placeholder image URL for missing images
  /// Used during loading or when images are unavailable
  static String _getPlaceholderUrl(String label) {
    // Using placeholder.com service for consistent fallbacks
    // Spotify green (#1DB954) background with white text
    final encodedLabel = Uri.encodeComponent(label.replaceAll(' ', '\n'));
    return 'https://via.placeholder.com/300x300/1DB954/FFFFFF?text=$encodedLabel';
  }

  /// Check if URL is a network URL (vs local asset)
  static bool isNetworkUrl(String? imageUrl) {
    if (imageUrl == null) return false;
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  /// Get local asset path (for Image.asset() fallback)
  static String? getLocalAssetPath(String imageInput) {
    if (imageInput.startsWith('images/')) {
      return imageInput;
    }
    
    // Try to map back to asset path
    if (imageInput.contains('/')) {
      return 'images/home/$imageInput';
    }
    
    return null;
  }
}

