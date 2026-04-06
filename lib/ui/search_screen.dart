import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/album/album_bloc.dart';
import 'package:spotify_clone/bloc/album/album_event.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/search/search_event.dart';
import 'package:spotify_clone/bloc/search/search_state.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/ui/albumview_screen.dart';
import 'package:spotify_clone/widgets/album_chip.dart';
import 'package:spotify_clone/widgets/artist_chip.dart';
import 'package:spotify_clone/widgets/song_chip.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
                  // Show recent searches initially
                  if (state is SearchInitial) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 20),
                          child: Text(
                            "Recent searches",
                            style: TextStyle(
                              fontFamily: "AM",
                              fontWeight: FontWeight.w400,
                              color: MyColors.whiteColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) {
                                    var bloc = AlbumBloc(locator.get());
                                    bloc.add(AlbumListEvent("Post Malone"));
                                    return bloc;
                                  },
                                  child: AlbumViewScreen(),
                                ),
                              ),
                            );
                          },
                          child: const AlbumChip(
                            image: "AUSTIN.jpg",
                            albumName: "AUSTIN",
                            artistName: "Post Malone",
                            size: 47,
                            isDeletable: true,
                          ),
                        ),
                        const ArtistChip(
                          image: 'Doja-Cat.jpg',
                          name: "Doja Cat",
                          radius: 23,
                          isDeletable: true,
                        ),
                        const SongChip(
                          image: "UTOPIA.jpg",
                          singerName: 'Travis Scott',
                          songTitle: "MY EYES",
                          size: 47,
                          isDeletable: true,
                        ),
                        const ArtistChip(
                          image: "Lil-Wayne.jpg",
                          name: "Lil Wayne",
                          radius: 23,
                          isDeletable: true,
                        ),
                        const ArtistChip(
                          image: "Megan-Thee-Stallion.jpg",
                          name: "Megan Thee Stallion",
                          radius: 23,
                          isDeletable: true,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) {
                                    var bloc = AlbumBloc(locator.get());
                                    bloc.add(AlbumListEvent("21 Savage"));
                                    return bloc;
                                  },
                                  child: AlbumViewScreen(),
                                ),
                              ),
                            );
                          },
                          child: const AlbumChip(
                            image: "american-dream.jpg",
                            albumName: "american dream",
                            artistName: "21 Savage",
                            size: 47,
                            isDeletable: true,
                          ),
                        ),
                        const SongChip(
                          image: "For-All-The-Dogs.jpg",
                          singerName: 'Drake',
                          songTitle: "IDGAF",
                          size: 47,
                          isDeletable: true,
                        ),
                        const ArtistChip(
                          image: "Taylor-Swift.jpg",
                          name: "Taylor Swift",
                          radius: 23,
                          isDeletable: true,
                        ),
                        const SongChip(
                          image: "AUSTIN.jpg",
                          singerName: 'Post Malone',
                          songTitle: "Laugh It Off",
                          size: 47,
                          isDeletable: true,
                        ),
                      ]),
                    );
                  }

                  // Show loading skeleton
                  if (state is SearchLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              MyColors.whiteColor),
                        ),
                      ),
                    );
                  }

                  // Show empty state
                  if (state is SearchEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.music_note_outlined,
                                size: 48,
                                color: MyColors.darGreyColor,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No results found",
                                style: TextStyle(
                                  fontFamily: "AM",
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

                  // Show error state
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
                                  fontFamily: "AM",
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

                  // Show actual search results
                  if (state is SearchLoaded) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Tracks section
                        if (state.songs.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              "Songs (${state.songs.length})",
                              style: const TextStyle(
                                fontFamily: "AM",
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.songs.isNotEmpty)
                          ...state.songs.take(5).map((track) {
                            final trackName = track.trackName;
                            final singerName = track.singers;

                            return SongChip(
                              image: '',
                              singerName: singerName,
                              songTitle: trackName,
                              size: 47,
                              isDeletable: false,
                            );
                          }).toList(),

                        // Albums section
                        if (state.albums.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              "Albums (${state.albums.length})",
                              style: const TextStyle(
                                fontFamily: "AM",
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.albums.isNotEmpty)
                          ...state.albums.take(5).map((album) {
                            final albumName = album.albumName;
                            final artistName = album.singerName;

                            return AlbumChip(
                              image: album.albumImage,
                              albumName: albumName,
                              artistName: artistName,
                              size: 47,
                              isDeletable: false,
                            );
                          }).toList(),

                        // Artists section
                        if (state.artists.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              "Artists (${state.artists.length})",
                              style: const TextStyle(
                                fontFamily: "AM",
                                fontWeight: FontWeight.bold,
                                color: MyColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (state.artists.isNotEmpty)
                          ...state.artists.take(5).map((artist) {
                            final artistName = artist.artistName ?? 'Unknown';
                            return ArtistChip(
                              image: artist.artistImage ?? 'Doja-Cat.jpg',
                              name: artistName,
                              radius: 23,
                              isDeletable: false,
                            );
                          }).toList(),

                        const SizedBox(height: 80),
                      ]),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Container(),
                  );
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
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Image.asset(
                      "images/icon_search_transparent.png",
                      color: MyColors.whiteColor,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (query) {
                          // Dispatch search event - debounce is handled in SearchBloc
                          if (query.isNotEmpty) {
                            context
                                .read<SearchBloc>()
                                .add(SearchQueryEvent(query));
                          }
                        },
                        style: const TextStyle(
                          fontFamily: "AM",
                          fontSize: 16,
                          color: MyColors.whiteColor,
                        ),
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 10, left: 15),
                          hintText: "Search",
                          hintStyle: const TextStyle(
                            fontFamily: "AM",
                            color: MyColors.whiteColor,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
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
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                    fontFamily: "AM", color: MyColors.whiteColor, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
