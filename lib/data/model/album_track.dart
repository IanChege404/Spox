class AlbumTrack {
  String trackName;
  String singers;
  String? audioUrl; // Optional preview audio URL

  AlbumTrack(
    this.trackName,
    this.singers, {
    this.audioUrl,
  });
}
