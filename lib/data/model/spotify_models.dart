/// User profile from Spotify API
class SpotifyUser {
  final String id;
  final String displayName;
  final String? email;
  final String? imageUrl;
  final int followers;

  SpotifyUser({
    required this.id,
    required this.displayName,
    this.email,
    this.imageUrl,
    this.followers = 0,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    return SpotifyUser(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? 'Unknown',
      email: json['email'],
      imageUrl: imageUrl,
      followers: json['followers']?['total'] ?? 0,
    );
  }
}

/// Search results from Spotify API
class SpotifySearchResults {
  final List<SpotifyTrack> tracks;
  final List<SpotifyArtist> artists;
  final List<SpotifyPlaylist> playlists;

  SpotifySearchResults({
    required this.tracks,
    required this.artists,
    required this.playlists,
  });

  factory SpotifySearchResults.fromJson(Map<String, dynamic> json) {
    return SpotifySearchResults(
      tracks: (json['tracks']?['items'] as List?)
              ?.map((t) => SpotifyTrack.fromJson(t))
              .toList() ??
          [],
      artists: (json['artists']?['items'] as List?)
              ?.map((a) => SpotifyArtist.fromJson(a))
              .toList() ??
          [],
      playlists: (json['playlists']?['items'] as List?)
              ?.map((p) => SpotifyPlaylist.fromJson(p))
              .toList() ??
          [],
    );
  }
}

/// Track from Spotify API
class SpotifyTrack {
  final String id;
  final String name;
  final String? previewUrl;
  final int durationMs;
  final int popularity;
  final List<SpotifyArtist> artists;
  final String? imageUrl;

  SpotifyTrack({
    required this.id,
    required this.name,
    this.previewUrl,
    required this.durationMs,
    this.popularity = 0,
    this.artists = const [],
    this.imageUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final images = json['album']?['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    final artists = (json['artists'] as List?)
            ?.map((a) => SpotifyArtist.fromJson(a))
            .toList() ??
        [];

    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      previewUrl: json['preview_url'],
      durationMs: json['duration_ms'] ?? 0,
      popularity: json['popularity'] ?? 0,
      artists: artists,
      imageUrl: imageUrl,
    );
  }
}

/// Artist from Spotify API
class SpotifyArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final int followers;
  final List<String> genres;

  SpotifyArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.followers = 0,
    this.genres = const [],
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    final genres = (json['genres'] as List?)?.cast<String>() ?? [];

    return SpotifyArtist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: imageUrl,
      followers: json['followers']?['total'] ?? 0,
      genres: genres,
    );
  }
}

/// Playlist from Spotify API
class SpotifyPlaylist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int trackCount;
  final String? ownerName;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.trackCount = 0,
    this.ownerName,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    return SpotifyPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'],
      imageUrl: imageUrl,
      trackCount: json['tracks']?['total'] ?? 0,
      ownerName: json['owner']?['display_name'],
    );
  }
}
