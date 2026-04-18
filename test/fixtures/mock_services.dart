import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:spotify_clone/services/hive_service.dart';

// SpotifyAuthService Mock
class MockSpotifyAuthService extends Mock implements SpotifyAuthService {}

// HiveService Mock
class MockHiveService extends Mock implements HiveService {}
