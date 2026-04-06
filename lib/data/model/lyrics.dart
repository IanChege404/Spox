/// Represents a single lyric line with timestamp
class LyricLine {
  final Duration timestamp;
  final String text;

  LyricLine({
    required this.timestamp,
    required this.text,
  });

  factory LyricLine.fromLrc(String lrcLine) {
    // Parse format: [00:12.34]Lyric text here
    final regex = RegExp(r'\[(\d+):(\d+\.?\d*)\](.*)');
    final match = regex.firstMatch(lrcLine);

    if (match == null) {
      return LyricLine(timestamp: Duration.zero, text: lrcLine);
    }

    final minutes = int.parse(match.group(1)!);
    final seconds = double.parse(match.group(2)!);
    final text = match.group(3)!;

    final totalMilliseconds = (minutes * 60 * 1000 + (seconds * 1000)).toInt();

    return LyricLine(
      timestamp: Duration(milliseconds: totalMilliseconds),
      text: text,
    );
  }

  @override
  String toString() => '[$timestamp] $text';
}

/// Full lyrics content with metadata
class Lyrics {
  final String trackName;
  final String artistName;
  final List<LyricLine> lines;
  final bool isSynced; // True if lines have timestamps, false if plain text

  Lyrics({
    required this.trackName,
    required this.artistName,
    required this.lines,
    this.isSynced = true,
  });

  /// Get the current lyric line based on playback position
  LyricLine? getCurrentLine(Duration position) {
    if (lines.isEmpty) return null;

    // Find the last line that hasn't passed yet
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].timestamp <= position) {
        return lines[i];
      }
    }

    return null;
  }

  /// Get the next lyric line
  LyricLine? getNextLine(Duration position) {
    for (final line in lines) {
      if (line.timestamp > position) {
        return line;
      }
    }
    return null;
  }

  /// Get all lines before the current position
  List<LyricLine> getPassedLines(Duration position) {
    return lines.where((line) => line.timestamp <= position).toList();
  }
}
