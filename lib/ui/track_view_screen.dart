import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_event.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_state.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_event.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/core/utils/color_extractor.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/ui/listening_on_screen.dart';
import 'package:spotify_clone/ui/lyrics_section.dart';
import 'package:spotify_clone/ui/queue_screen.dart';
import 'package:spotify_clone/ui/song_control_screen.dart';
import 'package:spotify_clone/widgets/stream_buttons.dart';
import 'package:spotify_clone/widgets/video_player.dart';

class TrackViewScreen extends StatefulWidget {
  const TrackViewScreen({super.key});

  @override
  State<TrackViewScreen> createState() => _TrackViewScreenState();
}

class _TrackViewScreenState extends State<TrackViewScreen> {
  bool isOnPlaying = true;
  bool isSwitchedToNextTab = false;
  bool shadowSwitcher = false;
  double _currentNumber = 25;
  Color _dominantColor = MyColors.blackColor;
  bool _isSleepTimerActive = false;
  Duration _sleepTimerRemaining = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioPlayerBloc, AudioPlayerState>(
      listener: (context, state) {
        // Extract dominant color when a song starts playing
        if (state is AudioPlaying) {
          _extractDominantColor(state.albumArt);
          
          // Fetch lyrics for the currently playing song
          context.read<LyricsBloc>().add(
            FetchLyricsEvent(
              trackName: state.songTitle,
              artistName: state.artist,
            ),
          );
        }
        
        // Sync lyrics position with playback
        if (state is AudioPlaying) {
          // Dispatch position update to keep lyrics in sync
          context.read<LyricsBloc>().add(
            UpdateLyricsPositionEvent(state.current),
          );
        }
        
        // Listen to sleep timer state changes
        if (state is SleepTimerActive) {
          setState(() {
            _isSleepTimerActive = true;
            _sleepTimerRemaining = state.remainingTime;
          });
        } else if (state is SleepTimerCancelled) {
          setState(() {
            _isSleepTimerActive = false;
            _sleepTimerRemaining = Duration.zero;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Animated background with dominant color
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _dominantColor,
                    _dominantColor.withValues(alpha: 0.3),
                    MyColors.blackColor,
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.decelerate,
                  switchOutCurve: Curves.decelerate,
                  child: (isSwitchedToNextTab)
                      ? const LyricsSection(
                          key: Key("1"),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              shadowSwitcher = !shadowSwitcher;
                            });
                          },
                          child: Stack(
                            children: [
                              const BackVideoPlayer(
                                key: Key("2"),
                              ),
                              Container(
                                color: (!shadowSwitcher)
                                    ? MyColors.blackColor
                                        .withValues(alpha: 0.45)
                                    : Colors.transparent,
                              ),
                              Positioned(
                                left: 25,
                                bottom: 70,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: (shadowSwitcher) ? 1 : 0,
                                  child: const Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundImage: AssetImage(
                                            'images/artists/Post-Malone.jpg'),
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        "by Post Malone",
                                        style: TextStyle(
                                          fontFamily: "AM",
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const _Header(),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  top: (isSwitchedToNextTab)
                      ? (MediaQuery.of(context).size.height * 0.6)
                      : (MediaQuery.of(context).size.height * 0.5),
                  right: 0,
                  left: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: (shadowSwitcher) ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: (isSwitchedToNextTab) ? 0 : 1,
                                child: SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: Center(
                                    child: Image.asset(
                                      "images/home/AUSTIN.jpg",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            left: 0,
                            top: 125,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AnimatedPadding(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.only(
                                      top: (isSwitchedToNextTab) ? 50 : 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              95,
                                          height: 30,
                                          child: const Text(
                                            "Enough is Enough",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "AM",
                                              color: MyColors.whiteColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        "Post Malne",
                                        style: TextStyle(
                                          fontFamily: "AM",
                                          fontSize: 14,
                                          color: MyColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      opacity: (isSwitchedToNextTab) ? 0 : 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SongControlScreen(
                                                      trackName:
                                                          "Enough is Enough",
                                                      color: Color(0xff8b9a63),
                                                      singer: "Post Malone",
                                                      albumImage: "AUSTIN.jpg"),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      opacity: (isSwitchedToNextTab) ? 0 : 1,
                                      child: Image.asset(
                                        'images/share.png',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 205,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AnimatedPadding(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: EdgeInsets.only(
                                          top: (isSwitchedToNextTab) ? 40 : 0),
                                      child: BlocBuilder<AudioPlayerBloc,
                                          AudioPlayerState>(
                                        builder: (context, state) {
                                          bool isPlaying =
                                              state is AudioPlaying;
                                          return GestureDetector(
                                            onTap: () {
                                              if (isPlaying) {
                                                context
                                                    .read<AudioPlayerBloc>()
                                                    .add(
                                                      const PauseSongEvent(),
                                                    );
                                                setState(() {
                                                  isOnPlaying = false;
                                                });
                                              } else {
                                                context
                                                    .read<AudioPlayerBloc>()
                                                    .add(
                                                      const ResumeSongEvent(),
                                                    );
                                                setState(() {
                                                  isOnPlaying = true;
                                                });
                                              }
                                            },
                                            child: isPlaying
                                                ? const PauseButton(
                                                    iconWidth: 2.5,
                                                    height: 40,
                                                    iconHeight: 14,
                                                    width: 40,
                                                    color: MyColors.whiteColor,
                                                  )
                                                : const PlayButton(
                                                    height: 40,
                                                    width: 40,
                                                    color: MyColors.whiteColor,
                                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      opacity: (isSwitchedToNextTab) ? 0 : 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          context
                                              .read<AudioPlayerBloc>()
                                              .add(const SkipPreviousEvent());
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: MyColors.blackColor
                                                .withValues(alpha: 0.3),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              "images/icon_back_song.png",
                                              height: 16,
                                              width: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      opacity: (isSwitchedToNextTab) ? 0 : 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          context
                                              .read<AudioPlayerBloc>()
                                              .add(const SkipNextEvent());
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: MyColors.blackColor
                                                .withValues(alpha: 0.3),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              "images/icon_next_song.png",
                                              height: 16,
                                              width: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity: (isSwitchedToNextTab) ? 0 : 1,
                                  child: BlocBuilder<LikedSongsBloc,
                                      LikedSongsState>(
                                    builder: (context, likedState) {
                                      return BlocBuilder<AudioPlayerBloc,
                                          AudioPlayerState>(
                                        builder: (context, audioState) {
                                          // Get current song info
                                          String songTitle = '';
                                          String artist = '';
                                          String albumArt = '';

                                          if (audioState is AudioPlaying) {
                                            songTitle = audioState.songTitle;
                                            artist = audioState.artist;
                                            albumArt = audioState.albumArt;
                                          }

                                          // Check if song is liked
                                          bool isLiked = false;
                                          if (likedState is LikedSongsLoaded) {
                                            isLiked = likedState.likedSongs.any(
                                              (song) =>
                                                  song.trackName == songTitle,
                                            );
                                          }

                                          return GestureDetector(
                                            onTap: () {
                                              if (songTitle.isNotEmpty) {
                                                final song = AlbumTrack(
                                                    songTitle, artist);
                                                context
                                                    .read<LikedSongsBloc>()
                                                    .add(
                                                      ToggleLikeEvent(
                                                        song: song,
                                                        albumImage: albumArt,
                                                      ),
                                                    );
                                              }
                                            },
                                            child: AnimatedScale(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              scale: isLiked ? 1.15 : 1.0,
                                              curve: Curves.elasticOut,
                                              child: isLiked
                                                  ? Image.asset(
                                                      'images/icon_heart_filled.png',
                                                      height: 22,
                                                      width: 22,
                                                      color: Colors.red,
                                                    )
                                                  : Image.asset(
                                                      'images/icon_heart.png',
                                                      height: 22,
                                                      width: 22,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 260,
                            right: 0,
                            left: 0,
                            child: AnimatedPadding(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.only(
                                  left: (isSwitchedToNextTab) ? 50 : 0),
                              child: Column(
                                children: [
                                  SliderTheme(
                                    data: const SliderThemeData(
                                      trackHeight: 2,
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 6.0),
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 0.0),
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: MediaQuery.of(context).size.width,
                                      child: BlocBuilder<AudioPlayerBloc,
                                          AudioPlayerState>(
                                        builder: (context, state) {
                                          double maxValue = 100;
                                          double currentValue = _currentNumber;

                                          // Get actual duration and position from BLoC state
                                          if (state is AudioPlaying) {
                                            final totalSeconds = state
                                                .total.inSeconds
                                                .toDouble();
                                            final currentSeconds = state
                                                .current.inSeconds
                                                .toDouble();

                                            if (totalSeconds > 0) {
                                              maxValue = totalSeconds;
                                              currentValue = currentSeconds;
                                            }
                                          } else if (state is AudioPaused) {
                                            final totalSeconds = state
                                                .total.inSeconds
                                                .toDouble();
                                            final currentSeconds = state
                                                .current.inSeconds
                                                .toDouble();

                                            if (totalSeconds > 0) {
                                              maxValue = totalSeconds;
                                              currentValue = currentSeconds;
                                            }
                                          }

                                          return Slider(
                                            min: 0,
                                            max: maxValue,
                                            activeColor: const Color.fromARGB(
                                                255, 230, 229, 229),
                                            inactiveColor: const Color.fromARGB(
                                                255, 148, 147, 147),
                                            value: currentValue,
                                            onChanged: (newValue) {
                                              setState(() {
                                                _currentNumber = newValue;
                                              });
                                              // Dispatch seek event
                                              context
                                                  .read<AudioPlayerBloc>()
                                                  .add(
                                                    SeekToEvent(
                                                      Duration(
                                                          seconds:
                                                              newValue.toInt()),
                                                    ),
                                                  );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _CurrentPositionTime(),
                                        _TotalDurationTime(),
                                      ],
                                    ),
                                  ),
                                  // Sleep timer display
                                  if (_isSleepTimerActive)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<AudioPlayerBloc>().add(
                                              const CancelSleepTimerEvent());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: MyColors.blackColor
                                                .withValues(alpha: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _dominantColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.timer,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _formatSleepTimerTime(
                                                    _sleepTimerRemaining),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "AM",
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isOnPlaying = !isOnPlaying;
                          isSwitchedToNextTab = !isSwitchedToNextTab;
                        });
                      },
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              (isOnPlaying) ? Colors.white : Colors.transparent,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Playing",
                              style: TextStyle(
                                fontFamily: "AM",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    (isOnPlaying) ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isOnPlaying = !isOnPlaying;
                          isSwitchedToNextTab = !isSwitchedToNextTab;
                          shadowSwitcher = false;
                        });
                      },
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: (!isOnPlaying)
                              ? Colors.white
                              : Colors.transparent,
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Lyrics",
                            style: TextStyle(
                              fontFamily: "AM",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color:
                                  (!isOnPlaying) ? Colors.black : Colors.white,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extract dominant color from album art
  Future<void> _extractDominantColor(String imageUrl) async {
    try {
      final color = await ColorExtractor.getDominantColor(imageUrl);
      if (mounted) {
        setState(() {
          _dominantColor = color;
        });
      }
    } catch (e) {
      print('Error extracting color: $e');
    }
  }

  /// Format sleep timer remaining time as MM:SS
  String _formatSleepTimerTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Widget to display the current position time from AudioPlayerBloc
class _CurrentPositionTime extends StatelessWidget {
  const _CurrentPositionTime();

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          String timeStr = "0:00";
          if (state is AudioPlaying) {
            timeStr = _formatDuration(state.current);
          } else if (state is AudioPaused) {
            timeStr = _formatDuration(state.current);
          }
          return Text(
            timeStr,
            style: const TextStyle(
              fontFamily: "AM",
              fontSize: 12,
              color: Color.fromARGB(255, 230, 229, 229),
            ),
          );
        },
      ),
    );
  }
}

/// Widget to display the total duration time from AudioPlayerBloc
class _TotalDurationTime extends StatelessWidget {
  const _TotalDurationTime();

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          String timeStr = "0:00";
          if (state is AudioPlaying) {
            timeStr = _formatDuration(state.total);
          } else if (state is AudioPaused) {
            timeStr = _formatDuration(state.total);
          }
          return Text(
            timeStr,
            style: const TextStyle(
              fontFamily: "AM",
              fontSize: 12,
              color: Color.fromARGB(255, 230, 229, 229),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              // Queue / Up Next button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const QueueScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;

                        final tween = Tween(begin: begin, end: end);
                        final offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Icon(
                  Icons.queue_music,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              // Listening on button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ListeningOn(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;

                        final tween = Tween(begin: begin, end: end);
                        final offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Image.asset(
                  'images/icon_listen.png',
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
