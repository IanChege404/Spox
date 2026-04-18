import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/search/search_event.dart';
import 'package:spotify_clone/bloc/search/search_state.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/ui/artist_detail_screen.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/widgets/album_chip.dart';
import 'package:spotify_clone/widgets/artist_chip.dart';
import 'package:spotify_clone/widgets/dynamic_image.dart';
import 'package:spotify_clone/widgets/skeleton_loaders.dart';
import 'package:spotify_clone/widgets/song_chip.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  List<String> _recentSearches() {
    return locator<HiveService>().getRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            slivers: [
              const _SearchBox(),
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    final recent = _recentSearches();

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 20),
                          child: Text(
                            'Recent searches',
                            style: TextStyle(
                              fontFamily: 'AM',
                              fontWeight: FontWeight.w400,
                              color: MyColors.whiteColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        if (recent.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'No recent searches yet',
                              style: TextStyle(
                                fontFamily: 'AM',
                                color: MyColors.lightGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ...recent.map(
                          (query) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  size: 18,
                                  color: MyColors.lightGrey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<SearchBloc>()
                                          .add(SearchQueryEvent(query));
                                    },
                                    child: Text(
                                      query,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'AM',
                                        color: MyColors.whiteColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await locator<HiveService>()
                                        .removeRecentSearch(query);
                                    if (!context.mounted) return;
                                    context
                                        .read<SearchBloc>()
                                        .add(const SearchClearEvent());
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: MyColors.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (recent.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () async {
                                await locator<HiveService>()
                                    .clearRecentSearches();
                                if (!context.mounted) return;
                                context
                                    .read<SearchBloc>()
                                    .add(const SearchClearEvent());
                              },
                              child: const Text(
                                'Clear all',
                                style: TextStyle(
                                  fontFamily: 'AM',
                                  color: MyColors.lightGrey,
                                ),
                              ),
                            ),
                          ),
                      ]),
                    );
                  }

                  if (state is SearchLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: SizedBox(
                          height: 520,
                          child: SkeletonScrollLoader(
                            itemCount: 6,
                            type: SkeletonType.song,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is SearchEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.music_note_outlined,
                                size: 48,
                                color: MyColors.darGreyColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontFamily: 'AM',
                                  fontSize: 16,
                                  color: MyColors.lightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is SearchError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(
                                  fontFamily: 'AM',
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is SearchLoaded) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        if (state.tracks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              'Songs (${state.tracks.length})',
                              style: const TextStyle(
                                fontFamily: 'AM',
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.tracks.isNotEmpty)
                          ...state.tracks.take(5).map((track) {
                            final singerName =
                                track.artists.map((a) => a.name).join(', ');
                            return SongChip(
                              image: '',
                              singerName: singerName,
                              songTitle: track.name,
                              size: 47,
                              isDeletable: false,
                            );
                          }),
                        if (state.albums.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              'Albums (${state.albums.length})',
                              style: const TextStyle(
                                fontFamily: 'AM',
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.albums.isNotEmpty)
                          ...state.albums
                              .take(5)
                              .map((album) => _SearchAlbumTile(album: album)),
                        if (state.artists.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              'Artists (${state.artists.length})',
                              style: const TextStyle(
                                fontFamily: 'AM',
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.artists.isNotEmpty)
                          ...state.artists.take(5).map((artist) {
                            return ArtistChip(
                              image: artist.imageUrl ?? 'Doja-Cat.jpg',
                              name: artist.name,
                              radius: 23,
                              isDeletable: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistDetailScreen(
                                      artist: artist,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        if (state.playlists.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              'Playlists (${state.playlists.length})',
                              style: const TextStyle(
                                fontFamily: 'AM',
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.playlists.isNotEmpty)
                          ...state.playlists.take(5).map((playlist) {
                            return AlbumChip(
                              image: playlist.imageUrl ?? '',
                              albumName: playlist.name,
                              artistName: playlist.ownerName ?? 'Spotify',
                              size: 47,
                              isDeletable: false,
                            );
                          }),
                        const SizedBox(height: 80),
                      ]),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width - 102.5,
              decoration: const BoxDecoration(
                color: Color(0xff282828),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Image.asset(
                      'images/icon_search_transparent.png',
                      color: MyColors.whiteColor,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (query) {
                          if (query.isNotEmpty) {
                            context
                                .read<SearchBloc>()
                                .add(SearchQueryEvent(query));
                          } else {
                            context
                                .read<SearchBloc>()
                                .add(const SearchClearEvent());
                          }
                        },
                        style: const TextStyle(
                          fontFamily: 'AM',
                          fontSize: 16,
                          color: MyColors.whiteColor,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 10, left: 15),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontFamily: 'AM',
                            color: MyColors.whiteColor,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              style: BorderStyle.none,
                              width: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'AM',
                  color: MyColors.whiteColor,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAlbumTile extends StatelessWidget {
  const _SearchAlbumTile({required this.album});

  final SpotifyAlbum album;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                height: 47,
                width: 47,
                child: DynamicImage(
                  imageUrl: album.imageUrl ?? '',
                  fit: BoxFit.cover,
                  backgroundColor: const Color(0xff282828),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: const TextStyle(
                      fontFamily: 'AM',
                      fontSize: 15,
                      color: MyColors.whiteColor,
                    ),
                  ),
                  Text(
                    'Album . ${album.artistName ?? 'Unknown'}',
                    style: const TextStyle(
                      fontFamily: 'AM',
                      fontSize: 13,
                      color: MyColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.album_outlined, color: MyColors.lightGrey, size: 18),
        ],
      ),
    );
  }
}
