import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/bloc/album/album_bloc.dart';
import 'package:spotify_clone/bloc/album/album_event.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/bloc/playlist/playlist_bloc.dart';
import 'package:spotify_clone/bloc/playlist/playlist_event.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/ui/albumview_screen.dart';
import 'package:spotify_clone/ui/playlist_search_screen.dart';
import 'package:spotify_clone/ui/setting_screen.dart';
import 'package:spotify_clone/widgets/bottom_player.dart';
import 'package:spotify_clone/widgets/skeleton_loaders.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            BlocProvider<HomeBloc>(
              create: (context) =>
                  locator<HomeBloc>()..add(const LoadHomeDataEvent()),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const SkeletonScrollLoader();
                  } else if (state is HomeError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Failed to load home",
                            style: TextStyle(
                              color: MyColors.whiteColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(const LoadHomeDataEvent());
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  } else if (state is HomeLoaded) {
                    return _HomeContent(
                      featuredPlaylists: state.featuredPlaylists,
                      userPlaylists: state.userPlaylists,
                    );
                  }
                  return const Center(
                    child: Text("No data available"),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: BottomPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<SpotifyPlaylist> featuredPlaylists;
  final List<SpotifyPlaylist> userPlaylists;

  const _HomeContent({
    required this.featuredPlaylists,
    required this.userPlaylists,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomScrollView(
        slivers: [
          const _Header(),
          _FeaturedPlaylists(playlists: featuredPlaylists),
          const _TopMixes(),
          const _RecentPlays(),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPlaylists extends StatelessWidget {
  final List<SpotifyPlaylist> playlists;

  const _FeaturedPlaylists({required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Featured Playlists",
              style: TextStyle(
                fontFamily: "AB",
                color: MyColors.whiteColor,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 199,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: playlists.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final imageUrl = playlist.imageUrl;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to playlist details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Tapped: ${playlist.name}")),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 133,
                          width: 133,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: MyColors.darGreyColor,
                                      child: const Center(
                                        child: Icon(Icons.music_note,
                                            color: MyColors.whiteColor),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: MyColors.darGreyColor,
                                  child: const Center(
                                    child: Icon(Icons.music_note,
                                        color: MyColors.whiteColor),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 133,
                          child: Text(
                            playlist.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: "AB",
                              fontSize: 12,
                              color: MyColors.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPlays extends StatelessWidget {
  const _RecentPlays();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recently played",
              style: TextStyle(
                fontFamily: "AM",
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: MyColors.whiteColor,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 199,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) {
                              var bloc = PlaylistBloc(locator.get());
                              bloc.add(PlaylistFetchEvent("Upbeat"));
                              return bloc;
                            },
                            child: const PlaylistSearchScreen(
                              cover: "Upbeat-Mix.jpg",
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 133,
                          width: 133,
                          child: Image.asset("images/home/Upbeat-Mix.jpg"),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "Upbeat Mix",
                          style: TextStyle(
                            fontFamily: "AB",
                            fontSize: 12,
                            color: MyColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 133,
                        width: 133,
                        child: Image.asset("images/home/Daily-Mix-1.jpg"),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        "Daily Mix 1",
                        style: TextStyle(
                          fontFamily: "AB",
                          fontSize: 12,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) {
                              var bloc = AlbumBloc(locator.get());
                              bloc.add(
                                AlbumListEvent("Travis Scott"),
                              );
                              return bloc;
                            },
                            child: const AlbumViewScreen(),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 133,
                          width: 133,
                          child: Image.asset("images/home/UTOPIA.jpg"),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "UTOPIA",
                          style: TextStyle(
                            fontFamily: "AB",
                            fontSize: 12,
                            color: MyColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
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
                            child: const AlbumViewScreen(),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 133,
                          width: 133,
                          child: Image.asset("images/home/american-dream.jpg"),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "american dream",
                          style: TextStyle(
                            fontFamily: "AB",
                            fontSize: 12,
                            color: MyColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Column(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundImage: AssetImage("images/artists/JID.jpg"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Center(
                        child: Text(
                          "JID",
                          style: TextStyle(
                            fontFamily: "AB",
                            fontSize: 12,
                            color: MyColors.whiteColor,
                          ),
                        ),
                      ),
                    ],
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

class _TopMixes extends StatelessWidget {
  const _TopMixes();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your top mixes",
              style: TextStyle(
                fontFamily: "AB",
                color: MyColors.whiteColor,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 199,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) {
                              var bloc = PlaylistBloc(locator.get());
                              bloc.add(PlaylistFetchEvent('2010'));
                              return bloc;
                            },
                            child: const PlaylistSearchScreen(
                              cover: "2010s-mix.png",
                            ),
                          ),
                        ),
                      );
                    },
                    child: const _MixChip(
                      subtitle: "Travis Scott, Soul Chef, Kanye West and more",
                      image: "2010s-mix.png",
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) {
                              var bloc = PlaylistBloc(locator.get());
                              bloc.add(PlaylistFetchEvent("Chill"));
                              return bloc;
                            },
                            child: const PlaylistSearchScreen(
                                cover: "chill-mix.png"),
                          ),
                        ),
                      );
                    },
                    child: const _MixChip(
                      subtitle: "Talyor Swift, The Beatles and more",
                      image: 'chill-mix.png',
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) {
                              var bloc = PlaylistBloc(locator.get());
                              bloc.add(PlaylistFetchEvent("Upbeat"));
                              return bloc;
                            },
                            child: const PlaylistSearchScreen(
                              cover: "Upbeat-Mix.jpg",
                            ),
                          ),
                        ),
                      );
                    },
                    child: const _MixChip(
                      subtitle: "benny blanco, Darke and more",
                      image: 'Upbeat-Mix.jpg',
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const _MixChip(
                    subtitle: "Baby keem, Travis Scott and Drake",
                    image: "Offset-Mix.jpg",
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) {
                              var bloc = PlaylistBloc(locator.get());
                              bloc.add(PlaylistFetchEvent('Drake mix'));
                              return bloc;
                            },
                            child: const PlaylistSearchScreen(
                              cover: "Drake-Mix.jpg",
                            ),
                          ),
                        ),
                      );
                    },
                    child: const _MixChip(
                      subtitle: "JID, Baby Keem and 21 Savage",
                      image: 'Drake-Mix.jpg',
                    ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("images/myImage.png"),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Good evening",
                      style: TextStyle(
                        fontFamily: "AB",
                        color: MyColors.whiteColor,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('images/icon_bell.png'),
                      Image.asset("images/icon_recent.png"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingScreen(),
                            ),
                          );
                        },
                        child: Image.asset("images/icon_settings.png"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  height: 35,
                  decoration: const BoxDecoration(
                    color: MyColors.darGreyColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(145),
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "Music",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 14,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 35,
                  decoration: const BoxDecoration(
                    color: MyColors.darGreyColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(145),
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "Podcasts",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 14,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 55,
                      width: (MediaQuery.of(context).size.width / 1.77) - 45,
                      decoration: const BoxDecoration(
                        color: MyColors.darGreyColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                height: 55,
                                width: 55,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      "images/liked_songs.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'images/icon_heart_white.png',
                                height: 20,
                                width: 20,
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "Liked Songs",
                            style: TextStyle(
                              fontFamily: "AB",
                              fontSize: 12,
                              color: MyColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _RecentPlaysChip(
                      image: "artists/JID.jpg",
                      title: "JID",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                              child: const AlbumViewScreen(),
                            ),
                          ),
                        );
                      },
                      child: const _RecentPlaysChip(
                        image: "home/american-dream.jpg",
                        title: "american dream",
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
                                bloc.add(AlbumListEvent("Travis Scott"));
                                return bloc;
                              },
                              child: const AlbumViewScreen(),
                            ),
                          ),
                        );
                      },
                      child: const _RecentPlaysChip(
                        image: "home/UTOPIA.jpg",
                        title: "UTOPIA",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) {
                                var bloc = PlaylistBloc(locator.get());
                                bloc.add(PlaylistFetchEvent("Upbeat"));
                                return bloc;
                              },
                              child: const PlaylistSearchScreen(
                                cover: "Upbeat-Mix.jpg",
                              ),
                            ),
                          ),
                        );
                      },
                      child: const _RecentPlaysChip(
                        image: "home/Upbeat-Mix.jpg",
                        title: "Upbeat Mix",
                      ),
                    ),
                    const _RecentPlaysChip(
                      image: "home/Daily-Mix-1.jpg",
                      title: "Daily Mix",
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

class _RecentPlaysChip extends StatelessWidget {
  const _RecentPlaysChip({required this.image, required this.title});
  final String title;
  final String image;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: (MediaQuery.of(context).size.width / 1.77) - 45,
      decoration: const BoxDecoration(
        color: MyColors.darGreyColor,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              image: DecorationImage(
                image: AssetImage(
                  "images/$image",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          AutoSizeText(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontFamily: "AB",
            ),
          )
        ],
      ),
    );
  }
}

class _MixChip extends StatelessWidget {
  const _MixChip({required this.subtitle, required this.image});
  final String subtitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 153,
          width: 153,
          child: Image.asset("images/home/$image"),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 150,
          child: Text(
            subtitle,
            style: const TextStyle(
              fontFamily: "AM",
              fontSize: 12.5,
              color: MyColors.lightGrey,
            ),
          ),
        ),
      ],
    );
  }
}
