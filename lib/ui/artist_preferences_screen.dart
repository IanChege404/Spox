import 'package:flutter/material.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/data/datasource/artist_datasource.dart';
import 'package:spotify_clone/data/model/artist.dart';
import 'package:spotify_clone/services/firebase_service.dart';
import 'package:spotify_clone/services/hive_service.dart';

class ArtistPreferencesScreen extends StatefulWidget {
  const ArtistPreferencesScreen({super.key});

  @override
  State<ArtistPreferencesScreen> createState() =>
      _ArtistPreferencesScreenState();
}

class _ArtistPreferencesScreenState extends State<ArtistPreferencesScreen> {
  late final ArtistDatasource _artistDatasource;
  late final FirebaseService _firebaseService;
  late final HiveService _hiveService;

  final Set<String> _selectedArtistNames = {};
  List<Artist> _artists = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const int _maxSelections = 5;

  @override
  void initState() {
    super.initState();
    _artistDatasource = locator<ArtistDatasource>();
    _firebaseService = locator<FirebaseService>();
    _hiveService = locator<HiveService>();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    try {
      final artists = await _artistDatasource.getArtistList();
      if (!mounted) return;
      setState(() {
        _artists = artists;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load artists: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleArtist(Artist artist) {
    final artistName = artist.artistName ?? 'Unknown';
    setState(() {
      if (_selectedArtistNames.contains(artistName)) {
        _selectedArtistNames.remove(artistName);
      } else if (_selectedArtistNames.length < _maxSelections) {
        _selectedArtistNames.add(artistName);
      }
    });
  }

  Future<void> _savePreferences() async {
    if (_selectedArtistNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one artist')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final selectedArtists = _artists
          .where((artist) => _selectedArtistNames.contains(artist.artistName))
          .toList();

      await _hiveService.saveSelectedArtists(
        selectedArtists
            .map(
              (artist) => {
                'artistName': artist.artistName,
                'artistImage': artist.artistImage,
              },
            )
            .toList(),
      );

      await _firebaseService.saveArtistPreferences(selectedArtists);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not save preferences: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      appBar: AppBar(
        backgroundColor: MyColors.blackColor,
        foregroundColor: Colors.white,
        title: const Text('Choose your artists'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: MyColors.primaryColor),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pick up to $_maxSelections artists you like',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This helps personalize your home feed and recommendations.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_selectedArtistNames.length} / $_maxSelections selected',
                              style: const TextStyle(
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _artists.length,
                          itemBuilder: (context, index) {
                            final artist = _artists[index];
                            final name = artist.artistName ?? 'Unknown';
                            final selected =
                                _selectedArtistNames.contains(name);

                            return GestureDetector(
                              onTap: () => _toggleArtist(artist),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? MyColors.primaryColor
                                          .withValues(alpha: 0.18)
                                      : Colors.grey[900],
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected
                                        ? MyColors.primaryColor
                                        : Colors.grey[800]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 42,
                                      backgroundColor: Colors.grey[850],
                                      backgroundImage:
                                          artist.artistImage != null
                                              ? AssetImage(
                                                  'images/artists/${artist.artistImage}',
                                                )
                                              : null,
                                      child: artist.artistImage == null
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                      selected
                                          ? Icons.check_circle
                                          : Icons.add_circle_outline,
                                      color: selected
                                          ? MyColors.primaryColor
                                          : Colors.grey[500],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _savePreferences,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.primaryColor,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
