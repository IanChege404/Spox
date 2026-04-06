import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/constants/constants.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DownloadBloc>().add(const LoadDownloadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      appBar: AppBar(
        backgroundColor: MyColors.blackColor,
        elevation: 0,
        title: const Text(
          'Downloads',
          style: TextStyle(color: MyColors.whiteColor, fontFamily: 'AM'),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state is DownloadInitial) {
            return const Center(
              child: CircularProgressIndicator(color: MyColors.greenColor),
            );
          }
          if (state is DownloadsLoaded) {
            final allTracks = state.tracks.values.toList();
            if (allTracks.isEmpty) {
              return const _EmptyDownloadsView();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allTracks.length,
              itemBuilder: (context, index) {
                final track = allTracks[index];
                return _DownloadTile(track: track);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyDownloadsView extends StatelessWidget {
  const _EmptyDownloadsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_outlined, size: 72, color: MyColors.lightGrey),
          const SizedBox(height: 16),
          const Text(
            'No downloads yet',
            style: TextStyle(
              color: MyColors.whiteColor,
              fontFamily: 'AM',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Download songs from the player to\nlisten offline.',
            style: TextStyle(
              color: MyColors.lightGrey,
              fontFamily: 'AM',
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final DownloadedTrack track;

  const _DownloadTile({required this.track});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: MyColors.darGreyColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: track.albumArt != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      track.albumArt!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.music_note,
                        color: MyColors.lightGrey,
                      ),
                    ),
                  )
                : const Icon(Icons.music_note, color: MyColors.lightGrey),
          ),
          const SizedBox(width: 12),
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.trackName,
                  style: const TextStyle(
                    color: MyColors.whiteColor,
                    fontFamily: 'AM',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.artist,
                  style: const TextStyle(
                    color: MyColors.lightGrey,
                    fontFamily: 'AM',
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (track.status == DownloadStatus.downloading) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: track.progress,
                    backgroundColor: MyColors.darGreyColor,
                    color: MyColors.greenColor,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status icon
          _StatusIcon(track: track),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final DownloadedTrack track;

  const _StatusIcon({required this.track});

  @override
  Widget build(BuildContext context) {
    switch (track.status) {
      case DownloadStatus.downloading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: MyColors.greenColor,
          ),
        );
      case DownloadStatus.downloaded:
        return GestureDetector(
          onTap: () => context
              .read<DownloadBloc>()
              .add(RemoveDownloadEvent(track.trackId)),
          child: const Icon(Icons.check_circle, color: MyColors.greenColor),
        );
      case DownloadStatus.notDownloaded:
        return const SizedBox.shrink();
    }
  }
}
