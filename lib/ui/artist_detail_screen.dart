import 'package:flutter/material.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';
import 'package:spotify_clone/widgets/dynamic_image.dart';

class ArtistDetailScreen extends StatefulWidget {
  final SpotifyArtist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  late final SpotifyRepository _repository;
  late Future<_ArtistDetailData> _future;

  @override
  void initState() {
    super.initState();
    _repository = locator<SpotifyRepository>();
    _future = _loadArtist();
  }

  Future<_ArtistDetailData> _loadArtist() async {
    final artist = await _repository.getArtist(widget.artist.id);
    final topTracks = await _repository.getArtistTopTracks(widget.artist.id);
    return _ArtistDetailData(artist: artist, topTracks: topTracks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: FutureBuilder<_ArtistDetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: MyColors.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load artist details\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final artist = data.artist;
          final genres = artist.genres.take(4).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 360,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(artist.name),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (artist.imageUrl != null)
                        DynamicImage(
                          imageUrl: artist.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: Colors.grey[900]),
                      Container(color: Colors.black.withValues(alpha: 0.5)),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Artist',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                artist.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${artist.followers.toString()} followers',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (genres.isNotEmpty) ...[
                        const Text(
                          'Genres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: genres
                              .map(
                                (genre) => Chip(
                                  label: Text(genre),
                                  backgroundColor: MyColors.primaryColor
                                      .withValues(alpha: 0.18),
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Text(
                        'Top tracks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (data.topTracks.isEmpty)
                        Text(
                          'No top tracks available',
                          style: TextStyle(color: Colors.grey[400]),
                        )
                      else
                        ...data.topTracks.take(10).map(
                              (track) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: DynamicImage(
                                        imageUrl: track.imageUrl ?? '',
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                        backgroundColor: Colors.grey[900],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            track.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            track.artists
                                                .map((a) => a.name)
                                                .join(', '),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.play_circle_fill,
                                      color: MyColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _ArtistDetailData {
  final SpotifyArtist artist;
  final List<SpotifyTrack> topTracks;

  _ArtistDetailData({required this.artist, required this.topTracks});
}
