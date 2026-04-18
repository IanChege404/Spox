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

  /// Guest user for unauthenticated mode
  factory SpotifyUser.guest() {
    return SpotifyUser(
      id: 'guest',
      displayName: 'Guest User',
      email: null,
      imageUrl: null,
      followers: 0,
    );
  }

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'imageUrl': imageUrl,
      'followers': followers,
    };
  }

  /// Create from JSON map (Hive restoration)
  factory SpotifyUser.fromMap(Map<String, dynamic> map) {
    return SpotifyUser(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? 'Unknown',
      email: map['email'],
      imageUrl: map['imageUrl'],
      followers: map['followers'] ?? 0,
    );
  }
}

/// Search results from Spotify API
class SpotifySearchResults {
  final List<SpotifyTrack> tracks;
  final List<SpotifyAlbum> albums;
  final List<SpotifyArtist> artists;
  final List<SpotifyPlaylist> playlists;

  SpotifySearchResults({
    required this.tracks,
    required this.albums,
    required this.artists,
    required this.playlists,
  });

  factory SpotifySearchResults.fromJson(Map<String, dynamic> json) {
    return SpotifySearchResults(
      tracks: (json['tracks']?['items'] as List?)
              ?.map((t) => SpotifyTrack.fromJson(t))
              .toList() ??
          [],
      albums: (json['albums']?['items'] as List?)
              ?.map((a) => SpotifyAlbum.fromJson(a))
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

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'previewUrl': previewUrl,
      'durationMs': durationMs,
      'popularity': popularity,
      'artists': artists.map((a) => a.toMap()).toList(),
      'imageUrl': imageUrl,
    };
  }

  /// Create from JSON map (Hive restoration)
  factory SpotifyTrack.fromMap(Map<String, dynamic> map) {
    final artistsList = (map['artists'] as List?)
            ?.map((a) => SpotifyArtist.fromMap(a))
            .toList() ??
        [];
    return SpotifyTrack(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      previewUrl: map['previewUrl'],
      durationMs: map['durationMs'] ?? 0,
      popularity: map['popularity'] ?? 0,
      artists: artistsList,
      imageUrl: map['imageUrl'],
    );
  }
}

/// Album from Spotify API
class SpotifyAlbum {
  final String id;
  final String name;
  final String? imageUrl;
  final String? artistName;
  final String? releaseDate;
  final int totalTracks;

  SpotifyAlbum({
    required this.id,
    required this.name,
    this.imageUrl,
    this.artistName,
    this.releaseDate,
    this.totalTracks = 0,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0]['url'];
    }

    final artists = (json['artists'] as List?)?.cast<Map<String, dynamic>>();
    final artistName = (artists != null && artists.isNotEmpty)
        ? (artists.first['name'] ?? 'Unknown') as String
        : null;

    return SpotifyAlbum(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: imageUrl,
      artistName: artistName,
      releaseDate: json['release_date'],
      totalTracks: json['total_tracks'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'artistName': artistName,
      'releaseDate': releaseDate,
      'totalTracks': totalTracks,
    };
  }

  factory SpotifyAlbum.fromMap(Map<String, dynamic> map) {
    return SpotifyAlbum(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      imageUrl: map['imageUrl'],
      artistName: map['artistName'],
      releaseDate: map['releaseDate'],
      totalTracks: map['totalTracks'] ?? 0,
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
  final int popularity;

  SpotifyArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.followers = 0,
    this.genres = const [],
    this.popularity = 0,
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
      popularity: json['popularity'] ?? 0,
    );
  }

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'followers': followers,
      'genres': genres,
      'popularity': popularity,
    };
  }

  /// Create from JSON map (Hive restoration)
  factory SpotifyArtist.fromMap(Map<String, dynamic> map) {
    return SpotifyArtist(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      imageUrl: map['imageUrl'],
      followers: map['followers'] ?? 0,
      genres: List<String>.from(map['genres'] ?? []),
      popularity: map['popularity'] ?? 0,
    );
  }
}

/// Browse Category from Spotify API for Browse tab
class BrowseCategory {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;

  BrowseCategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
  });

  factory BrowseCategory.fromJson(Map<String, dynamic> json) {
    final icons = json['icons'] as List?;
    String? imageUrl;
    if (icons != null && icons.isNotEmpty) {
      imageUrl = icons[0]['url'];
    }

    return BrowseCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: imageUrl,
      description: json['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory BrowseCategory.fromMap(Map<String, dynamic> map) {
    return BrowseCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      imageUrl: map['imageUrl'],
      description: map['description'],
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

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'trackCount': trackCount,
      'ownerName': ownerName,
    };
  }

  /// Create from JSON map (Hive restoration)
  factory SpotifyPlaylist.fromMap(Map<String, dynamic> map) {
    return SpotifyPlaylist(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      description: map['description'],
      imageUrl: map['imageUrl'],
      trackCount: map['trackCount'] ?? 0,
      ownerName: map['ownerName'],
    );
  }
}

/// Guest home page data - public content only (no auth required)
class GuestHomeData {
  final List<SpotifyPlaylist> featuredPlaylists;
  final List<BrowseCategory> browseCategories;
  final List<SpotifyPlaylist> categoryPlaylists;

  GuestHomeData({
    required this.featuredPlaylists,
    required this.browseCategories,
    required this.categoryPlaylists,
  });
}
