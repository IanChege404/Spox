import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_event.dart';
import 'package:spotify_clone/bloc/queue/queue_state.dart' as queue_state;
import 'package:spotify_clone/constants/constants.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      appBar: AppBar(
        backgroundColor: MyColors.blackColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Up Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<QueueBloc, queue_state.QueueState>(
        builder: (context, state) {
          if (state is queue_state.QueueEmpty) {
            return const Center(
              child: Text(
                'Queue is empty',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          if (state is queue_state.QueueLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        // Shuffle button
                        _ControlButton(
                          icon: Icons.shuffle,
                          label: 'Shuffle',
                          isActive: state.isShuffle,
                          onPressed: () {
                            context
                                .read<QueueBloc>()
                                .add(const ToggleShuffleEvent());
                          },
                        ),
                        const SizedBox(width: 12),

                        // Repeat button
                        _ControlButton(
                          icon: _getRepeatIcon(state.repeatMode),
                          label: _getRepeatLabel(state.repeatMode),
                          isActive:
                              state.repeatMode != queue_state.RepeatMode.off,
                          onPressed: () {
                            context
                                .read<QueueBloc>()
                                .add(const CycleRepeatModeEvent());
                          },
                        ),
                        const Spacer(),

                        // Clear queue button
                        IconButton(
                          icon: const Icon(Icons.clear_all,
                              color: Colors.red, size: 24),
                          onPressed: () {
                            context
                                .read<QueueBloc>()
                                .add(const ClearQueueEvent());
                          },
                          tooltip: 'Clear Queue',
                        ),
                      ],
                    ),
                  ),

                  // Queue list
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        context.read<QueueBloc>().add(
                              ReorderQueueEvent(
                                oldIndex: oldIndex,
                                newIndex: newIndex,
                              ),
                            );
                      },
                      children: [
                        for (int i = 0; i < state.queue.length; i++)
                          _QueueItemTile(
                            key: ValueKey(state.queue[i]),
                            song: state.queue[i],
                            index: i,
                            isCurrentlyPlaying: i == state.currentIndex,
                            onTap: () {
                              // Play the tapped song from queue
                              final track = state.queue[i];
                              if (track.audioUrl != null &&
                                  track.audioUrl!.isNotEmpty) {
                                context.read<AudioPlayerBloc>().add(
                                      PlaySongEvent(
                                        audioUrl: track.audioUrl!,
                                        songTitle: track.trackName,
                                        artist: track.singers,
                                        albumArt:
                                            '', // Could pass album from context
                                        queueTracks: state.queue,
                                        startIndex: i,
                                      ),
                                    );
                              }
                            },
                            onRemove: () {
                              context.read<QueueBloc>().add(
                                    RemoveFromQueueEvent(i),
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: MyColors.primaryColor),
          );
        },
      ),
    );
  }

  IconData _getRepeatIcon(queue_state.RepeatMode mode) {
    switch (mode) {
      case queue_state.RepeatMode.off:
        return Icons.repeat;
      case queue_state.RepeatMode.all:
        return Icons.repeat;
      case queue_state.RepeatMode.one:
        return Icons.repeat_one;
    }
  }

  String _getRepeatLabel(queue_state.RepeatMode mode) {
    switch (mode) {
      case queue_state.RepeatMode.off:
        return 'Repeat';
      case queue_state.RepeatMode.all:
        return 'Repeat All';
      case queue_state.RepeatMode.one:
        return 'Repeat One';
    }
  }
}

/// Control button widget for shuffle/repeat
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? MyColors.primaryColor
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[400],
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual queue item tile
class _QueueItemTile extends StatelessWidget {
  final int index;
  final dynamic song;
  final bool isCurrentlyPlaying;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _QueueItemTile({
    required Key key,
    required this.index,
    required this.song,
    required this.isCurrentlyPlaying,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: key,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? MyColors.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: isCurrentlyPlaying
              ? Border.all(color: MyColors.primaryColor, width: 1.5)
              : null,
        ),
        child: ListTile(
          leading: ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            song.trackName ?? 'Unknown Song',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
                  isCurrentlyPlaying ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            song.singers ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          trailing: SizedBox(
            width: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCurrentlyPlaying)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.music_note,
                      color: MyColors.primaryColor,
                      size: 18,
                    ),
                  ),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          minTileHeight: 56,
        ),
      ),
    );
  }
}
