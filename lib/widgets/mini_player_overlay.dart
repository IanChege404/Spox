import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/ui/track_view_screen.dart';
import 'package:spotify_clone/widgets/bottom_player.dart';

/// Draggable mini player overlay that persists across navigation
class MiniPlayerOverlay extends StatefulWidget {
  final Widget child;

  const MiniPlayerOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay>
    with TickerProviderStateMixin {
  /// Offset from bottom of screen (0 = full screen, > 0 = collapsed)
  late AnimationController _animationController;

  /// Whether mini player should be shown
  bool _showMiniPlayer = false;

  /// Y position of mini player (for drag gestures)
  double _miniPlayerPosition = 0;

  /// Height of bottom player widget
  static const double _playerHeight = 80.0;

  /// Height of bottom navigation bar
  static const double _bottomNavHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        // Show mini player when audio is playing or paused
        final isPlayingOrPaused =
            state is AudioPlaying || state is AudioPaused;

        if (isPlayingOrPaused && !_showMiniPlayer) {
          _showMiniPlayer = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _animationController.forward();
          });
        } else if (!isPlayingOrPaused && _showMiniPlayer) {
          _showMiniPlayer = false;
          _animationController.reverse();
        }

        return Stack(
          children: [
            // Main app content
            widget.child,

            // Mini player overlay
            if (_showMiniPlayer)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    bottom: _bottomNavHeight +
                        (_miniPlayerPosition *
                            _animationController.value), // Smooth animation
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          // Update position based on drag
                          _miniPlayerPosition -=
                              details.delta.dy / _playerHeight;
                          _miniPlayerPosition =
                              _miniPlayerPosition.clamp(0.0, 1.0);
                        });
                      },
                      onVerticalDragEnd: (details) {
                        // If dragged more than 20%, expand to full player
                        if (_miniPlayerPosition > 0.2) {
                          _navigateToFullPlayer(context, state);
                        } else {
                          // Snap back to mini player
                          setState(() {
                            _miniPlayerPosition = 0;
                          });
                        }
                      },
                      onTap: () {
                        // Tap mini player to open full screen
                        _navigateToFullPlayer(context, state);
                      },
                      child: Container(
                        height: _playerHeight,
                        color: Colors.transparent,
                        child: Material(
                          color: Colors.transparent,
                          child: BottomPlayer(),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  /// Navigate to full player screen
  void _navigateToFullPlayer(
    BuildContext context,
    AudioPlayerState state,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return TrackViewScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );

    // Reset mini player position when navigating away
    setState(() {
      _miniPlayerPosition = 0;
    });
  }
}
