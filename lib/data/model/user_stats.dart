/// Statistics data for the Wrapped/Stats page
class UserStats {
  final int totalMinutesListened;
  final String topArtist;
  final List<StatTrack> topTracks;
  final List<StatArtist> topArtists;
  final List<StatAlbum> topAlbums;
  final DateTime generatedAt;

  UserStats({
    required this.totalMinutesListened,
    required this.topArtist,
    required this.topTracks,
    required this.topArtists,
    required this.topAlbums,
    required this.generatedAt,
  });

  /// Calculate completion percentage (for visualization)
  int calculateCompletionPercentage() {
    // Example: estimate based on data quality
    int score = 0;
    if (totalMinutesListened > 0) score += 20;
    if (topArtist.isNotEmpty) score += 20;
    if (topTracks.isNotEmpty) score += 20;
    if (topArtists.isNotEmpty) score += 20;
    if (topAlbums.isNotEmpty) score += 20;
    return score;
  }

  /// Get greeting based on minutes listened
  String getGreeting() {
    if (totalMinutesListened < 60) return 'You\'re just starting out! 🎶';
    if (totalMinutesListened < 300) return 'You\'re building your library. 🎧';
    if (totalMinutesListened < 1000) return 'You\'re a serious listener! 🔥';
    if (totalMinutesListened < 5000) return 'Music is your passion! 🎵';
    return 'You ARE music! 👑';
  }
}

/// Top track in statistics
class StatTrack {
  final String trackName;
  final String artistName;
  final int playCount;
  final int totalMinutesListened;
  final String? albumArt;

  StatTrack({
    required this.trackName,
    required this.artistName,
    required this.playCount,
    required this.totalMinutesListened,
    this.albumArt,
  });
}

/// Top artist in statistics
class StatArtist {
  final String name;
  final int playCount;
  final int totalMinutesListened;
  final String? image;

  StatArtist({
    required this.name,
    required this.playCount,
    required this.totalMinutesListened,
    this.image,
  });
}

/// Top album in statistics
class StatAlbum {
  final String name;
  final String artistName;
  final int playCount;
  final String? albumArt;

  StatAlbum({
    required this.name,
    required this.artistName,
    required this.playCount,
    this.albumArt,
  });
}

/// Time period for statistics
enum StatsPeriod {
  week,
  month,
  allTime,
}

extension StatsPeriodExtension on StatsPeriod {
  String get displayName {
    switch (this) {
      case StatsPeriod.week:
        return 'This Week';
      case StatsPeriod.month:
        return 'This Month';
      case StatsPeriod.allTime:
        return 'All Time';
    }
  }

  Duration get duration {
    final now = DateTime.now();
    switch (this) {
      case StatsPeriod.week:
        return Duration(days: 7);
      case StatsPeriod.month:
        return Duration(days: 30);
      case StatsPeriod.allTime:
        return now.difference(DateTime(2000)); // Far past
    }
  }
}
