import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_event.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_state.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/widgets/dynamic_image.dart';

enum _LikedSongsSort { dateLiked, artist, title }

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  _LikedSongsSort _sortBy = _LikedSongsSort.dateLiked;

  void _sortSongs(List<AlbumTrack> songs) {
    switch (_sortBy) {
      case _LikedSongsSort.artist:
        songs.sort((a, b) =>
            a.singers.toLowerCase().compareTo(b.singers.toLowerCase()));
        break;
      case _LikedSongsSort.title:
        songs.sort((a, b) =>
            a.trackName.toLowerCase().compareTo(b.trackName.toLowerCase()));
        break;
      case _LikedSongsSort.dateLiked:
        songs.sort(
          (a, b) => (b.likedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.likedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<LikedSongsBloc, LikedSongsState>(
            builder: (context, state) {
              final songs = <AlbumTrack>[];
              if (state is LikedSongsLoaded) {
                songs.addAll(state.likedSongs);
                _sortSongs(songs);
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Liked Songs',
                            style: TextStyle(
                              fontFamily: 'AB',
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<_LikedSongsSort>(
                            icon: const Icon(Icons.sort, color: Colors.white),
                            color: const Color(0xff1F1F1F),
                            initialValue: _sortBy,
                            onSelected: (value) {
                              setState(() {
                                _sortBy = value;
                              });
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _LikedSongsSort.dateLiked,
                                child: Text('Sort: Date liked',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              PopupMenuItem(
                                value: _LikedSongsSort.artist,
                                child: Text('Sort: Artist',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              PopupMenuItem(
                                value: _LikedSongsSort.title,
                                child: Text('Sort: Song title',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        '${songs.length} songs saved to your personal library',
                        style: const TextStyle(
                          fontFamily: 'AM',
                          color: MyColors.lightGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (state is LikedSongsLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1DB954),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (songs.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.favorite_border,
                                  color: MyColors.lightGrey, size: 42),
                              SizedBox(height: 14),
                              Text(
                                'No liked songs yet',
                                style: TextStyle(
                                  fontFamily: 'AM',
                                  color: MyColors.whiteColor,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the heart on a track to save it here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'AM',
                                  color: MyColors.lightGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 52,
                                  width: 52,
                                  child: DynamicImage(
                                    imageUrl: song.albumImage ?? '',
                                    fit: BoxFit.cover,
                                    backgroundColor: const Color(0xff282828),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.trackName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'AM',
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        song.singers,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'AM',
                                          color: MyColors.lightGrey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.read<LikedSongsBloc>().add(
                                          RemoveLikeEvent(song: song),
                                        );
                                  },
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 120),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
