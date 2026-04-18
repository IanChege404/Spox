import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/ui/liked_songs_screen.dart';
import 'package:spotify_clone/ui/profile_screen.dart';
import 'package:spotify_clone/ui/setting_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  List<SpotifyPlaylist> _playlistsForState(HomeState state) {
    if (state is HomeLoaded) {
      final merged = <SpotifyPlaylist>[
        ...state.userPlaylists,
        ...state.featuredPlaylists,
      ];
      final seen = <String>{};
      return merged.where((playlist) => seen.add(playlist.id)).toList();
    }

    if (state is HomeLoadedGuest) {
      final merged = <SpotifyPlaylist>[
        ...state.featuredPlaylists,
        ...state.categoryPlaylists,
      ];
      final seen = <String>{};
      return merged.where((playlist) => seen.add(playlist.id)).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25, top: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage("images/myImage.png"),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Your Library",
                                  style: TextStyle(
                                    fontFamily: "AB",
                                    fontSize: 24,
                                    color: MyColors.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Image.asset("images/icon_add.png"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: OptionsList(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "images/arrow_component_down.png",
                                    width: 10,
                                    height: 12,
                                  ),
                                  Image.asset(
                                    "images/arrow_component_up.png",
                                    width: 10,
                                    height: 12,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "Recently Played",
                                style: TextStyle(
                                  fontFamily: "AM",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: MyColors.whiteColor,
                                ),
                              ),
                            ],
                          ),
                          Image.asset("images/icon_category.png"),
                        ],
                      ),
                    ),
                  ),
                  const _LikedSongsSection(),
                  const _NewEpisodesSection(),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, homeState) {
                      if (homeState is HomeInitial) {
                        context.read<HomeBloc>().add(const LoadHomeDataEvent());
                      }

                      if (homeState is HomeLoading ||
                          homeState is HomeInitial) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: MyColors.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }

                      final playlists = _playlistsForState(homeState);
                      if (playlists.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'No library content available yet',
                              style: TextStyle(
                                color: MyColors.lightGrey,
                                fontFamily: 'AM',
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList.builder(
                        itemCount: playlists.length.clamp(0, 12),
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _LibraryPlaylistTile(playlist: playlist),
                          );
                        },
                      );
                    },
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 130),
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

class _NewEpisodesSection extends StatelessWidget {
  const _NewEpisodesSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 15),
        child: Row(
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Image.asset("images/new_episods.png"),
                Image.asset("images/icon_bell_fill.png"),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New Episods",
                  style: TextStyle(
                    fontFamily: "AM",
                    fontSize: 15,
                    color: MyColors.whiteColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    Image.asset("images/icon_pin.png"),
                    const SizedBox(width: 5),
                    const Text(
                      "Updated 2 days ago",
                      style: TextStyle(
                        fontFamily: "AM",
                        color: MyColors.lightGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LikedSongsSection extends StatelessWidget {
  const _LikedSongsSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LikedSongsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Image.asset("images/liked_songs.png"),
                  Image.asset("images/icon_heart_white.png"),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Liked Songs",
                    style: TextStyle(
                      fontFamily: "AM",
                      fontSize: 15,
                      color: MyColors.whiteColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Image.asset("images/icon_pin.png"),
                      const SizedBox(width: 5),
                      const Text(
                        "Playlist . 58 songs",
                        style: TextStyle(
                          fontFamily: "AM",
                          color: MyColors.lightGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryPlaylistTile extends StatelessWidget {
  final SpotifyPlaylist playlist;

  const _LibraryPlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 60,
            width: 60,
            child: playlist.imageUrl?.isNotEmpty == true
                ? Image.network(
                    playlist.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: MyColors.darGreyColor,
                      child: const Icon(
                        Icons.music_note,
                        color: MyColors.whiteColor,
                      ),
                    ),
                  )
                : Container(
                    color: MyColors.darGreyColor,
                    child: const Icon(
                      Icons.music_note,
                      color: MyColors.whiteColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'AM',
                  fontSize: 15,
                  color: MyColors.whiteColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Playlist • ${playlist.trackCount} songs',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'AM',
                  fontSize: 13,
                  color: MyColors.lightGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LibraryOptionsChip extends StatelessWidget {
  const LibraryOptionsChip({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    List<String> chipTitle = [
      "Playlists",
      "Artists",
      "Albums",
      "Podcasts & shows"
    ];
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: [
          Container(
            height: 33,
            decoration: BoxDecoration(
              border: Border.all(
                color: MyColors.lightGrey,
                width: 1,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  chipTitle[index],
                  style: const TextStyle(
                    fontFamily: "AM",
                    fontSize: 12,
                    color: MyColors.whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionsList extends StatelessWidget {
  const OptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return LibraryOptionsChip(index: index);
        },
      ),
    );
  }
}
