import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_event.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_state.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/widgets/dynamic_image.dart';
import 'package:spotify_clone/ui/listening_on_screen.dart';
import 'package:spotify_clone/ui/track_view_screen.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        // Get display values from state
        String songTitle = 'No song playing';
        String artist = 'Unknown artist';
        String albumArt = 'images/home/AUSTIN.jpg';
        bool isPlaying = false;
        Duration currentDuration = Duration.zero;
        Duration totalDuration = Duration.zero;

        if (state is AudioPlaying) {
          songTitle = state.songTitle;
          artist = state.artist;
          albumArt = state.albumArt;
          currentDuration = state.current;
          totalDuration = state.total;
          isPlaying = true;
        } else if (state is AudioPaused) {
          songTitle = state.songTitle;
          artist = state.artist;
          albumArt = state.albumArt;
          currentDuration = state.current;
          totalDuration = state.total;
          isPlaying = false;
        } else if (state is AudioLoading) {
          songTitle = state.songTitle;
          isPlaying = false;
        } else if (state is AudioCompleted) {
          songTitle = state.songTitle;
          isPlaying = false;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 59,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 83, 83, 83),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 250),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const TrackViewScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                );
                                final slideAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, 0.08),
                                  end: Offset.zero,
                                ).animate(curvedAnimation);

                                return FadeTransition(
                                  opacity: curvedAnimation,
                                  child: SlideTransition(
                                    position: slideAnimation,
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          ),
                          child: Row(
                            children: [
                              Hero(
                                tag: _miniPlayerHeroTag(albumArt),
                                child: Container(
                                  height: 37,
                                  width: 37,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: DynamicImage(
                                      imageUrl: albumArt,
                                      fit: BoxFit.cover,
                                      width: 37,
                                      height: 37,
                                      backgroundColor: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    height: 20,
                                    child: Text(
                                      songTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "AM",
                                        color: MyColors.whiteColor,
                                        fontSize: 13.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    artist,
                                    style: const TextStyle(
                                      fontFamily: "AM",
                                      fontSize: 12,
                                      color: MyColors.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 103,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ListeningOn(),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'images/icon_listen.png',
                                  color:
                                      const Color.fromARGB(255, 190, 190, 190),
                                  height: 24,
                                  width: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.headphones,
                                      size: 24,
                                      color: const Color.fromARGB(
                                          255, 190, 190, 190),
                                    );
                                  },
                                ),
                              ),
                              BlocBuilder<LikedSongsBloc, LikedSongsState>(
                                builder: (context, likedState) {
                                  final currentSong = (state is AudioPlaying)
                                      ? AlbumTrack(
                                          state.songTitle,
                                          state.artist,
                                          albumImage: state.albumArt,
                                        )
                                      : (state is AudioPaused)
                                          ? AlbumTrack(
                                              state.songTitle,
                                              state.artist,
                                              albumImage: state.albumArt,
                                            )
                                          : null;

                                  final isLiked = currentSong != null &&
                                      likedState is LikedSongsLoaded &&
                                      likedState.isSongLiked(currentSong);

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 7),
                                    child: GestureDetector(
                                      onTap: currentSong == null
                                          ? null
                                          : () {
                                              context
                                                  .read<LikedSongsBloc>()
                                                  .add(
                                                    ToggleLikeEvent(
                                                      song: currentSong,
                                                      albumImage: currentSong
                                                              .albumImage ??
                                                          albumArt,
                                                    ),
                                                  );
                                            },
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            isLiked
                                                ? 'images/icon_heart_filled.png'
                                                : 'images/icon_heart.png',
                                            height: 22,
                                            width: 22,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.grey,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 22,
                                                color: isLiked
                                                    ? Colors.red
                                                    : Colors.grey,
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 9),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  if (isPlaying) {
                                    context.read<AudioPlayerBloc>().add(
                                          const PauseSongEvent(),
                                        );
                                  } else {
                                    context.read<AudioPlayerBloc>().add(
                                          const ResumeSongEvent(),
                                        );
                                  }
                                },
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: isPlaying
                                      ? Image.asset(
                                          'images/icon_play.png',
                                          color: MyColors.whiteColor,
                                        )
                                      : Row(
                                          children: [
                                            Container(
                                              height: 17,
                                              width: 5,
                                              color: MyColors.whiteColor,
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 17,
                                              width: 5,
                                              color: MyColors.whiteColor,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: SliderComponentShape.noThumb,
                      trackShape: const RectangularSliderTrackShape(),
                      trackHeight: 3,
                    ),
                    child: SizedBox(
                      height: 8,
                      child: Slider(
                        activeColor: const Color.fromARGB(255, 230, 229, 229),
                        inactiveColor: MyColors.lightGrey,
                        value: totalDuration.inMilliseconds > 0
                            ? currentDuration.inMilliseconds /
                                totalDuration.inMilliseconds
                            : 0.0,
                        onChanged: (newValue) {
                          final seekDuration = Duration(
                            milliseconds:
                                (newValue * totalDuration.inMilliseconds)
                                    .toInt(),
                          );
                          context.read<AudioPlayerBloc>().add(
                                SeekToEvent(seekDuration),
                              );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _miniPlayerHeroTag(String albumArt) {
  final resolved = albumArt.isEmpty ? 'images/home/AUSTIN.jpg' : albumArt;
  return 'mini-player-art-$resolved';
}
