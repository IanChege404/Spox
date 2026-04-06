import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search for songs, artists, albums, playlists by query
class SearchQueryEvent extends SearchEvent {
  final String query;

  const SearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to clear search results
class SearchClearEvent extends SearchEvent {
  const SearchClearEvent();
}
