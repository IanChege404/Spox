import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Each restricted section in the guest home screen
abstract class RestrictedSection {
  static const String likedSongs = 'liked_songs';
  static const String yourMixes = 'your_mixes';
  static const String recentlyPlayed = 'recently_played';
  static const String yourLibrary = 'your_library';
  static const String profile = 'profile';

  static const List<String> all = [
    likedSongs,
    yourMixes,
    recentlyPlayed,
    yourLibrary,
    profile,
  ];

  static String getDisplayName(String section) {
    switch (section) {
      case likedSongs:
        return 'Liked Songs';
      case yourMixes:
        return 'Your Mixes';
      case recentlyPlayed:
        return 'Recently Played';
      case yourLibrary:
        return 'Your Library';
      case profile:
        return 'Profile';
      default:
        return 'Feature';
    }
  }

  static String getMessage(String section) {
    switch (section) {
      case likedSongs:
        return 'Keep your favorite tracks in one place';
      case yourMixes:
        return 'Get AI-curated mixes based on your taste';
      case recentlyPlayed:
        return 'See what you\'ve been listening to';
      case yourLibrary:
        return 'Manage all your saved content';
      case profile:
        return 'View and edit your profile';
      default:
        return 'This feature requires you to sign in';
    }
  }
}

/// Guest access state
abstract class GuestAccessState extends Equatable {
  const GuestAccessState();

  @override
  List<Object?> get props => [];
}

class GuestAccessInitial extends GuestAccessState {
  const GuestAccessInitial();
}

/// Emitted when a guest tries to access a restricted section
class ShowRestrictedModal extends GuestAccessState {
  final String section;
  final String title;
  final String message;

  const ShowRestrictedModal({
    required this.section,
    required this.title,
    required this.message,
  });

  @override
  List<Object?> get props => [section, title, message];
}

/// Emitted when guest should navigate to login
class NavigateToLogin extends GuestAccessState {
  final String? fromSection;

  const NavigateToLogin({this.fromSection});

  @override
  List<Object?> get props => [fromSection];
}

/// CUBiT to manage guest access attempts and modal display
class GuestAccessCubit extends Cubit<GuestAccessState> {
  GuestAccessCubit() : super(const GuestAccessInitial());

  /// Handle guest attempting to access restricted section
  void onRestrictedSectionTapped(String section) {
    final title = RestrictedSection.getDisplayName(section);
    final message = RestrictedSection.getMessage(section);

    emit(ShowRestrictedModal(
      section: section,
      title: title,
      message: message,
    ));
  }

  /// Handle guest attempting access to liked songs
  void onLikedSongsTapped() {
    onRestrictedSectionTapped(RestrictedSection.likedSongs);
  }

  /// Handle guest attempting access to your mixes
  void onYourMixesTapped() {
    onRestrictedSectionTapped(RestrictedSection.yourMixes);
  }

  /// Handle guest attempting access to recently played
  void onRecentlyPlayedTapped() {
    onRestrictedSectionTapped(RestrictedSection.recentlyPlayed);
  }

  /// Handle guest attempting access to library
  void onYourLibraryTapped() {
    onRestrictedSectionTapped(RestrictedSection.yourLibrary);
  }

  /// Handle guest attempting access to profile
  void onProfileTapped() {
    onRestrictedSectionTapped(RestrictedSection.profile);
  }

  /// User confirmed they want to sign in
  void signInPressed(String? fromSection) {
    emit(NavigateToLogin(fromSection: fromSection));
  }

  /// Dismiss the modal (user cancelled)
  void dismissModal() {
    emit(const GuestAccessInitial());
  }
}
