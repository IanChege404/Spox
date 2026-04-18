import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<SpotifyPlaylist> featuredPlaylists;
  final List<SpotifyPlaylist> userPlaylists;
  final SpotifyUser currentUser;

  const HomeLoaded({
    required this.featuredPlaylists,
    required this.userPlaylists,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [featuredPlaylists, userPlaylists, currentUser];
}

/// Guest home state - public content only (featured playlists, categories)
class HomeLoadedGuest extends HomeState {
  final List<SpotifyPlaylist> featuredPlaylists;
  final List<BrowseCategory> browseCategories;
  final List<SpotifyPlaylist> categoryPlaylists;
  final SpotifyUser currentUser;

  const HomeLoadedGuest({
    required this.featuredPlaylists,
    required this.browseCategories,
    required this.categoryPlaylists,
    required this.currentUser,
  });

  @override
  List<Object?> get props =>
      [featuredPlaylists, browseCategories, categoryPlaylists, currentUser];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// BLoC for home screen data management
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SpotifyRepository _spotifyRepository;
  final SpotifyAuthService _authService;
  final HiveService _hiveService;

  HomeBloc({
    required SpotifyRepository spotifyRepository,
    required SpotifyAuthService authService,
    required HiveService hiveService,
  })  : _spotifyRepository = spotifyRepository,
        _authService = authService,
        _hiveService = hiveService,
        super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      // Check if user is authenticated
      if (_authService.isAuthenticated) {
        // Load authenticated user home data
        await _loadAuthenticatedHomeData(emit);
      } else {
        // Load guest home data (public endpoints only)
        await _loadGuestHomeData(emit);
      }
    } catch (e) {
      print('[HomeBloc] Error loading home data: $e');
      // Fallback to guest content on any error
      try {
        await _loadGuestHomeData(emit);
      } catch (fallbackError) {
        print('[HomeBloc] Fallback also failed: $fallbackError');
        emit(const HomeError('Failed to load home screen'));
      }
    }
  }

  /// Load authenticated user's home data (user playlists + featured playlists)
  Future<void> _loadAuthenticatedHomeData(Emitter<HomeState> emit) async {
    try {
      // Fetch user profile
      final userProfile = await _spotifyRepository.getCurrentUserProfile();

      // Fetch featured playlists
      final featuredPlaylists =
          await _spotifyRepository.getFeaturedPlaylists(limit: 20);

      final filteredFeaturedPlaylists = _filterPlaylistsByArtistPreferences(
        featuredPlaylists,
        _hiveService.getSelectedArtists(),
      );

      // Fetch user's own playlists
      final userPlaylists =
          await _spotifyRepository.getUserPlaylists(limit: 20);

      print(
          '[HomeBloc] ✓ Loaded authenticated user home: ${filteredFeaturedPlaylists.length} featured playlists, ${userPlaylists.length} user playlists');

      // Emit authenticated loaded state with user data
      emit(HomeLoaded(
        featuredPlaylists: filteredFeaturedPlaylists,
        userPlaylists: userPlaylists,
        currentUser: userProfile,
      ));

      print('[HomeBloc] ✓ Authenticated home screen data loaded successfully');
    } catch (e) {
      print('[HomeBloc] Error loading authenticated home data: $e');
      rethrow;
    }
  }

  List<SpotifyPlaylist> _filterPlaylistsByArtistPreferences(
    List<SpotifyPlaylist> playlists,
    List<Map<String, dynamic>> selectedArtists,
  ) {
    if (selectedArtists.isEmpty) return playlists;

    final preferredNames = selectedArtists
        .map((artist) => (artist['artistName'] ?? artist['name'] ?? '')
            .toString()
            .toLowerCase())
        .where((name) => name.isNotEmpty)
        .toList();

    if (preferredNames.isEmpty) return playlists;

    final filtered = playlists.where((playlist) {
      final haystack =
          '${playlist.name} ${playlist.description ?? ''} ${playlist.ownerName ?? ''}'
              .toLowerCase();
      return preferredNames.any(haystack.contains);
    }).toList();

    return filtered.isNotEmpty ? filtered : playlists;
  }

  /// Load public guest home data (featured playlists, categories)
  Future<void> _loadGuestHomeData(Emitter<HomeState> emit) async {
    try {
      // Load guest home data (public endpoints only)
      // This includes featured playlists, categories, and category playlists
      final guestHomeData =
          await _spotifyRepository.getGuestHomeData(limit: 20);

      final guestUser = SpotifyUser.guest();

      print(
          '[HomeBloc] ✓ Loaded guest home data: ${guestHomeData.featuredPlaylists.length} featured playlists, ${guestHomeData.browseCategories.length} categories');

      // Emit guest loaded state with all public data
      emit(HomeLoadedGuest(
        featuredPlaylists: guestHomeData.featuredPlaylists,
        browseCategories: guestHomeData.browseCategories,
        categoryPlaylists: guestHomeData.categoryPlaylists,
        currentUser: guestUser,
      ));

      print('[HomeBloc] ✓ Guest home screen data loaded successfully');
    } catch (e) {
      print('[HomeBloc] Error loading guest home data: $e');
      // Fallback with empty data but still emit guest state
      emit(HomeLoadedGuest(
        featuredPlaylists: [],
        browseCategories: [],
        categoryPlaylists: [],
        currentUser: SpotifyUser.guest(),
      ));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Refresh by loading again
    await _onLoadHomeData(const LoadHomeDataEvent(), emit);
  }
}
