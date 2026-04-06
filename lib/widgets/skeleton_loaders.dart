import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader for song cards
class SongCardSkeleton extends StatelessWidget {
  const SongCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Album art placeholder
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Song info placeholder
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 16),
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 150,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for album cards
class AlbumCardSkeleton extends StatelessWidget {
  final double width;

  const AlbumCardSkeleton({
    Key? key,
    this.width = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album art placeholder
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // Album name placeholder
          Container(
            width: width,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          // Artist name placeholder
          Container(
            width: width * 0.7,
            height: 10,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for artist cards
class ArtistCardSkeleton extends StatelessWidget {
  final double size;

  const ArtistCardSkeleton({
    Key? key,
    this.size = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Artist avatar placeholder
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          // Artist name placeholder
          Container(
            width: size,
            height: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for playlist cards
class PlaylistCardSkeleton extends StatelessWidget {
  final double width;

  const PlaylistCardSkeleton({
    Key? key,
    this.width = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist art placeholder
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // Playlist name placeholder
          Container(
            width: width,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          // Owner placeholder
          Container(
            width: width * 0.6,
            height: 10,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Full screen skeleton loader for scrollable content
class SkeletonScrollLoader extends StatelessWidget {
  final int itemCount;
  final SkeletonType type;

  const SkeletonScrollLoader({
    Key? key,
    this.itemCount = 5,
    this.type = SkeletonType.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        switch (type) {
          case SkeletonType.song:
            return const SongCardSkeleton();
          case SkeletonType.album:
            return Padding(
              padding: const EdgeInsets.all(16),
              child: AlbumCardSkeleton(),
            );
          case SkeletonType.artist:
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ArtistCardSkeleton(),
            );
          case SkeletonType.playlist:
            return Padding(
              padding: const EdgeInsets.all(16),
              child: PlaylistCardSkeleton(),
            );
        }
      },
    );
  }
}

enum SkeletonType { song, album, artist, playlist }
