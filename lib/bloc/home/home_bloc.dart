import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';

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
  final SpotifyUser? currentUser;

  const HomeLoaded({
    required this.featuredPlaylists,
    required this.userPlaylists,
    this.currentUser,
  });

  @override
  List<Object?> get props => [featuredPlaylists, userPlaylists, currentUser];
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

  HomeBloc({required SpotifyRepository spotifyRepository})
      : _spotifyRepository = spotifyRepository,
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
      // Fetch featured playlists and user playlists in parallel
      final results = await Future.wait([
        _spotifyRepository.getFeaturedPlaylists(limit: 20),
        _spotifyRepository.getUserPlaylists(limit: 20),
        _spotifyRepository.getCurrentUserProfile(),
      ]);

      final featuredPlaylists = results[0] as List<SpotifyPlaylist>;
      final userPlaylists = results[1] as List<SpotifyPlaylist>;
      final currentUser = results[2] as SpotifyUser;

      emit(HomeLoaded(
        featuredPlaylists: featuredPlaylists,
        userPlaylists: userPlaylists,
        currentUser: currentUser,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data: ${e.toString()}'));
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
