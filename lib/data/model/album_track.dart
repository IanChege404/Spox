class AlbumTrack {
  String trackName;
  String singers;
  String? audioUrl; // Optional preview audio URL
  String? albumImage;
  DateTime? likedAt;

  AlbumTrack(
    this.trackName,
    this.singers, {
    this.audioUrl,
    this.albumImage,
    this.likedAt,
  });
}
