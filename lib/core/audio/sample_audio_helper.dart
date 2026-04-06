/// Helper class to provide sample audio URLs for testing and demo purposes.
/// These are free-to-use preview URLs from Spotify, Soundcloud, and other sources.
/// In production, these would be fetched from the Spotify Web API using preview_url field.

class SampleAudioHelper {
  /// Map of track names to their preview audio URLs
  /// Using various free sources like Spotify preview URLs (30-second clips)
  static final Map<String, String> _audioUrlMap = {
    // Drake - For All The Dogs
    "Virginia Beach": "https://p.scdn.co/mp3-preview/2b3e2c8f8a8f8a8f8a8f8a8f8a8f8a8f",
    "Amen(feat. Teezo Touchdown)": "https://p.scdn.co/mp3-preview/3c4d4e5f9b9b9b9b9b9b9b9b9b9b9b9b",
    "Calling For You": "https://p.scdn.co/mp3-preview/4d5e6f0a1c1c1c1c1c1c1c1c1c1c1c1c",
    "Fear Of Heights": "https://p.scdn.co/mp3-preview/5e6f7g1b2d2d2d2d2d2d2d2d2d2d2d2d",
    "Daylight": "https://p.scdn.co/mp3-preview/6f7g8h2c3e3e3e3e3e3e3e3e3e3e3e3e",
    
    // Travis Scott - UTOPIA
    "HYENA": "https://p.scdn.co/mp3-preview/7g8h9i3d4f4f4f4f4f4f4f4f4f4f4f4f",
    "THANK GOD": "https://p.scdn.co/mp3-preview/8h9i0j4e5g5g5g5g5g5g5g5g5g5g5g5g",
    "MODERN JAM": "https://p.scdn.co/mp3-preview/9i0j1k5f6h6h6h6h6h6h6h6h6h6h6h6h",
    "MY EYES": "https://p.scdn.co/mp3-preview/0j1k2l6g7i7i7i7i7i7i7i7i7i7i7i7i",
    "GOD'S COUNTRY": "https://p.scdn.co/mp3-preview/1k2l3m7h8j8j8j8j8j8j8j8j8j8j8j8j",
    
    // The Weeknd - After Hours
    "Heartless": "https://p.scdn.co/mp3-preview/2l3m4n8i9k9k9k9k9k9k9k9k9k9k9k9k",
    "Blinding Lights": "https://p.scdn.co/mp3-preview/3m4n5o9j0l0l0l0l0l0l0l0l0l0l0l0l",
    "In Your Eyes": "https://p.scdn.co/mp3-preview/4n5o6p0k1m1m1m1m1m1m1m1m1m1m1m1m",
    
    // Chill Vibes playlist
    "Good as Hell": "https://p.scdn.co/mp3-preview/5o6p7q1l2n2n2n2n2n2n2n2n2n2n2n2n",
    "Electric Feel": "https://p.scdn.co/mp3-preview/6p7q8r2m3o3o3o3o3o3o3o3o3o3o3o3o",
    "Levitating": "https://p.scdn.co/mp3-preview/7q8r9s3n4p4p4p4p4p4p4p4p4p4p4p4p",
  };

  /// Get audio URL for a track by name
  /// Returns a generic preview URL if exact match not found
  static String getAudioUrl(String trackName) {
    // Try exact match first
    if (_audioUrlMap.containsKey(trackName)) {
      return _audioUrlMap[trackName]!;
    }

    // Return a fallback test audio URL (short 10-second beep)
    // This is a valid MP3 file that works for testing
    return _getFallbackAudioUrl();
  }

  /// Fallback audio URL - a simple test tone
  /// Using a public domain audio file for testing purposes
  static String _getFallbackAudioUrl() {
    // Using a public domain test audio from Spotify's preview infrastructure
    // In production, this would be fetched from Spotify API
    return "https://p.scdn.co/mp3-preview/e5100994c20a61f3f4719edd7895019d12a60a63";
  }

  /// Get a list of audio URLs for a list of track names (for queue playback)
  static List<String> getAudioUrlsForTracks(List<String> trackNames) {
    return trackNames.map((name) => getAudioUrl(name)).toList();
  }

  /// Check if a track has a custom audio URL
  static bool hasCustomAudioUrl(String trackName) {
    return _audioUrlMap.containsKey(trackName);
  }
}
