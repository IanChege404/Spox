import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/core/audio/sample_audio_helper.dart';
import 'package:spotify_clone/data/model/podcast.dart';
import 'package:spotify_clone/data/repository/podcast_repository.dart';
import 'package:spotify_clone/widgets/dynamic_image.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final PodcastRepository _repository = locator<PodcastRepository>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _query = '';

  static const List<String> _categories = [
    'All',
    'True Crime',
    'Tech',
    'Comedy',
    'Education',
    'Health',
    'Business',
  ];

  String _categorizePodcast(String name) {
    final value = name.toLowerCase();
    if (value.contains('crime')) return 'True Crime';
    if (value.contains('lab') ||
        value.contains('tech') ||
        value.contains('startalk')) return 'Tech';
    if (value.contains('comedy') ||
        value.contains('bad friends') ||
        value.contains('distractible')) {
      return 'Comedy';
    }
    if (value.contains('english') ||
        value.contains('peterson') ||
        value.contains('wisdom')) {
      return 'Education';
    }
    if (value.contains('huberman') ||
        value.contains('fit') ||
        value.contains('hotbox')) {
      return 'Health';
    }
    if (value.contains('rogan') ||
        value.contains('podcast p') ||
        value.contains('nfr')) {
      return 'Business';
    }
    return 'Tech';
  }

  List<Podcast> _filterPodcasts(List<Podcast> podcasts) {
    return podcasts.where((podcast) {
      final matchesCategory = _selectedCategory == 'All' ||
          _categorizePodcast(podcast.name) == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          podcast.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openEpisodeDetail(Podcast podcast) {
    final episodeTitle = '${podcast.name} • Latest Episode';
    final audioUrl = SampleAudioHelper.getAudioUrl(podcast.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                podcast.name,
                style: const TextStyle(
                  fontFamily: 'AB',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                episodeTitle,
                style: const TextStyle(
                  fontFamily: 'AM',
                  color: MyColors.lightGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AudioPlayerBloc>().add(
                          PlaySongEvent(
                            audioUrl: audioUrl,
                            songTitle: episodeTitle,
                            artist: podcast.name,
                            albumArt: podcast.image,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Episode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: SafeArea(
        child: FutureBuilder<List<Podcast>>(
          future: _repository.getPodcastList(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                ),
              );
            }

            final filtered = _filterPodcasts(snapshot.data!);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 14),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Podcasts',
                            style: TextStyle(
                              fontFamily: 'AB',
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search podcasts',
                        hintStyle: const TextStyle(color: MyColors.lightGrey),
                        filled: true,
                        fillColor: const Color(0xff282828),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final selected = category == _selectedCategory;
                            return ChoiceChip(
                              label: Text(category),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              selectedColor: const Color(0xFF1DB954),
                              labelStyle: TextStyle(
                                color: selected ? Colors.black : Colors.white,
                              ),
                              backgroundColor: const Color(0xff2A2A2A),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: _categories.length,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 18, bottom: 100),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final podcast = filtered[index];
                          return GestureDetector(
                            onTap: () => _openEpisodeDetail(podcast),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: DynamicImage(
                                      imageUrl: podcast.image,
                                      fit: BoxFit.cover,
                                      backgroundColor: const Color(0xff282828),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  podcast.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'AM',
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 220,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
