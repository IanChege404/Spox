import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_clone/services/image_service.dart';

/// Utility to seed Firestore with initial data - COMPLETE MIGRATION
/// This file contains ALL local data migrated from hardcoded datasources
/// Run this once to populate your Firestore database
///
/// Version tracking prevents re-seeding on every app launch
class FirestoreSeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current seed data version - increment when data changes
  /// Used to prevent unnecessary re-seeding and support data updates
  static const int _seedVersion = 1;

  /// Seed all collections with complete data
  static Future<void> seedAllData() async {
    print(
        'Starting Firestore seed data - COMPLETE MIGRATION (v$_seedVersion)...');

    try {
      // Check current seed version to avoid redundant seeding
      if (await _isSeedDataCurrent()) {
        print('✓ Seed data already up-to-date (v$_seedVersion)');
        return;
      }

      await seedPlaylists();
      await seedAlbums();
      await seedArtists();
      await seedPodcasts();
      await seedHomeScreenConfig();
      await updateCollectionMetadata();
      print('✓ All data seeded successfully!');
    } catch (e) {
      print('✗ Error seeding data: $e');
      rethrow;
    }
  }

  /// Check if seed data is current version
  /// Returns true if metadata indicates data is already seeded at current version
  static Future<bool> _isSeedDataCurrent() async {
    try {
      final doc =
          await _firestore.collection('_metadata').doc('seed_version').get();
      if (doc.exists) {
        final currentVersion = doc.data()?['version'] as int? ?? 0;
        return currentVersion >= _seedVersion;
      }
      return false;
    } catch (e) {
      print('Warning: Could not check seed version: $e');
      return false;
    }
  }

  /// Update metadata to track seed data version
  static Future<void> updateCollectionMetadata() async {
    final metadata = {
      'seed_version': _seedVersion,
      'last_seeded': FieldValue.serverTimestamp(),
      'app_version': '1.0.0',
    };

    await _firestore
        .collection('_metadata')
        .doc('seed_version')
        .set(metadata, SetOptions(merge: true));
    print('  ✓ Updated metadata: seed_version=$_seedVersion');
  }

  // ============================================================================
  // PLAYLISTS
  // ============================================================================

  static Future<void> seedPlaylists() async {
    print('Seeding playlists...');

    final playlists = [
      {
        'id': '2010s',
        'name': '2010s Mix',
        'description': 'The biggest hits from the 2010s',
        'coverUrl': ImageService.resolveImageUrl('images/home/2010s-Mix.jpg'),
        'trackCount': 15,
        'ownerName': 'Spotify',
        'isPlayable': true,
      },
      {
        'id': 'chill',
        'name': 'Chill Mix',
        'description': 'Smooth vibes for relaxation',
        'coverUrl': ImageService.resolveImageUrl('images/home/Chill-Mix.jpg'),
        'trackCount': 14,
        'ownerName': 'Spotify',
        'isPlayable': true,
      },
      {
        'id': 'upbeat',
        'name': 'Upbeat Mix',
        'description': 'High energy tracks to keep you moving',
        'coverUrl': ImageService.resolveImageUrl('images/home/Upbeat-Mix.jpg'),
        'trackCount': 15,
        'ownerName': 'Spotify',
        'isPlayable': true,
      },
      {
        'id': 'drake-mix',
        'name': 'Drake Mix',
        'description': 'Drake\'s greatest hits and features',
        'coverUrl': ImageService.resolveImageUrl('images/home/Drake-Mix.jpg'),
        'trackCount': 15,
        'ownerName': 'Spotify',
        'isPlayable': true,
      },
    ];

    for (var playlist in playlists) {
      await _firestore
          .collection('playlists')
          .doc(playlist['id'] as String)
          .set(playlist);
      print('  ✓ Created playlist: ${playlist['name']}');
    }

    // Seed playlist tracks
    await seedPlaylistTracks();
  }

  static Future<void> seedPlaylistTracks() async {
    print('Seeding playlist tracks...');

    // Drake Mix tracks (15 tracks)
    final drakeTracks = [
      {'name': 'One Dance', 'artist': 'Drake', 'position': 0},
      {'name': 'Money Trees', 'artist': 'Kendrick Lamar', 'position': 1},
      {'name': 'God\'s Plan', 'artist': 'Drake', 'position': 2},
      {
        'name': 'Low Life (feat. The Weeknd)',
        'artist': 'Future, The Weeknd',
        'position': 3
      },
      {
        'name': 'WAIT FOR U (feat. Drake & Tems)',
        'artist': 'Future, Drake, Tems',
        'position': 4
      },
      {'name': 'Break from Toronto', 'artist': 'PARTYNEXTDOOR', 'position': 5},
      {'name': 'In My Feelings', 'artist': 'Drake', 'position': 6},
      {
        'name': 'Ric Flair Drip (with Metro Boomin)',
        'artist': 'Offset, Metro Boomin',
        'position': 7
      },
      {'name': 'Nice For What', 'artist': 'Drake', 'position': 8},
      {'name': 'Lovin On Me', 'artist': 'Jack Harlow', 'position': 9},
      {'name': 'Best I Ever Had', 'artist': 'Drake', 'position': 10},
      {'name': 'redrum', 'artist': '21 Savage', 'position': 11},
      {'name': 'Trophies', 'artist': 'Young Money', 'position': 12},
      {
        'name': 'Surround Sound (feat. 21 Savage & Baby Tate)',
        'artist': 'JID, 21 Savage, Baby Tate',
        'position': 13
      },
      {'name': 'IDGAF (feat. Yeat)', 'artist': 'Drake, Yeat', 'position': 14},
    ];

    for (var track in drakeTracks) {
      await _firestore
          .collection('playlists')
          .doc('drake-mix')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Seeded ${drakeTracks.length} tracks for Drake Mix');

    // Chill Mix tracks (14 tracks)
    final chillTracks = [
      {
        'name': 'Shut up My Moms Calling',
        'artist': 'Hotel Ugly',
        'position': 0
      },
      {'name': 'Stick Season', 'artist': 'Noah Kahan', 'position': 1},
      {'name': 'Dark Red', 'artist': 'Steve Lacy', 'position': 2},
      {'name': 'Sunset Lover', 'artist': 'Petit Biscuit', 'position': 3},
      {'name': 'Hex', 'artist': '80purppp', 'position': 4},
      {'name': 'Japanese Denim', 'artist': 'Daniel Caesar', 'position': 5},
      {'name': 'Yebba\'s Heartbreak', 'artist': 'Drake', 'position': 6},
      {'name': 'Location', 'artist': 'Khalid', 'position': 7},
      {'name': 'Ivy', 'artist': 'Frank Ocean', 'position': 8},
      {'name': 'act ii: date @ 8', 'artist': '4batz', 'position': 9},
      {
        'name': 'Get You (feat. Kali Uchis)',
        'artist': 'Daniel Caesar',
        'position': 10
      },
      {'name': 'comethru', 'artist': 'Jeremy Zucker', 'position': 11},
      {'name': 'Come Back to Earth', 'artist': 'Mac Miller', 'position': 12},
      {'name': 'Some', 'artist': 'Steve Lacy', 'position': 13},
    ];

    for (var track in chillTracks) {
      await _firestore
          .collection('playlists')
          .doc('chill')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Seeded ${chillTracks.length} tracks for Chill Mix');

    // Upbeat Mix tracks (15 tracks)
    final upbeatTracks = [
      {
        'name': 'Calm Down (with Selena Gomez)',
        'artist': 'Rema, Selena Gomez',
        'position': 0
      },
      {'name': 'Feather', 'artist': 'Sabrina Carpenter', 'position': 1},
      {'name': 'I\'m Good (Blue)', 'artist': 'David Guetta', 'position': 2},
      {
        'name': 'Uptown Funk (feat. Bruno Mars)',
        'artist': 'Mark Ronson, Bruno Mars',
        'position': 3
      },
      {'name': 'High Hopes', 'artist': 'Panic! At The Disco', 'position': 4},
      {'name': 'Cake By The Ocean', 'artist': 'DNCE', 'position': 5},
      {
        'name': 'Better When I\'m Dancin\'',
        'artist': 'Meghan Trainor',
        'position': 6
      },
      {
        'name': 'What You Know',
        'artist': 'Two Door Cinema Club',
        'position': 7
      },
      {
        'name': 'Walking On Sunshine',
        'artist': 'Katrina & The Waves',
        'position': 8
      },
      {'name': 'Shut Up and Dance', 'artist': 'WALK THE MOON', 'position': 9},
      {
        'name': 'Feliz, Alegre e Forte',
        'artist': 'Marisa Monte',
        'position': 10
      },
      {'name': 'Lil Boo Thang', 'artist': 'Paul Russell', 'position': 11},
      {'name': 'Classic', 'artist': 'MKTO', 'position': 12},
      {'name': 'Me Levanté', 'artist': 'Dave Bolaño', 'position': 13},
      {'name': 'Feel It Still', 'artist': 'Portugal. The Man', 'position': 14},
    ];

    for (var track in upbeatTracks) {
      await _firestore
          .collection('playlists')
          .doc('upbeat')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Seeded ${upbeatTracks.length} tracks for Upbeat Mix');

    // 2010s Mix tracks (15 tracks)
    final twoThousandsTracks = [
      {'name': 'Love You So', 'artist': 'The Walters', 'position': 0},
      {
        'name': 'See You Again (feat. Kali Uchis)',
        'artist': 'Tyler, The Creator',
        'position': 1
      },
      {
        'name': 'Sunflower - Spider-Man: Into the Spider-Verse',
        'artist': 'Post Malone',
        'position': 2
      },
      {'name': 'Cruel Summer', 'artist': 'Taylor Swift', 'position': 3},
      {'name': 'The Night We Met', 'artist': 'Lord Huron', 'position': 4},
      {'name': 'Starboy', 'artist': 'The Weeknd', 'position': 5},
      {'name': 'No Role Modelz', 'artist': 'J. Cole', 'position': 6},
      {'name': 'One Dance', 'artist': 'Drake', 'position': 7},
      {'name': 'Pink + White', 'artist': 'Frank Ocean', 'position': 8},
      {'name': 'Lover', 'artist': 'Taylor Swift', 'position': 9},
      {'name': 'Perfect', 'artist': 'Ed Sheeran', 'position': 10},
      {'name': 'Dandelions', 'artist': 'Ruth B.', 'position': 11},
      {'name': 'Dark Red', 'artist': 'Steve Lacy', 'position': 12},
      {'name': 'Not Allowed', 'artist': 'TV Girl', 'position': 13},
      {
        'name': 'Evergreen',
        'artist': 'Richy Mitch & The Coal Miners',
        'position': 14
      },
    ];

    for (var track in twoThousandsTracks) {
      await _firestore
          .collection('playlists')
          .doc('2010s')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Seeded ${twoThousandsTracks.length} tracks for 2010s Mix');
  }

  // ============================================================================
  // ALBUMS
  // ============================================================================

  static Future<void> seedAlbums() async {
    print('Seeding albums...');

    // Drake - For All The Dogs
    final drakeTracks = [
      {'name': 'Virginia Beach', 'artists': 'Drake', 'position': 0},
      {
        'name': 'Amen(feat. Teezo Touchdown)',
        'artists': 'Drake, Teezo Touchdown',
        'position': 1
      },
      {'name': 'Calling For You', 'artists': 'Drake, 21 Savage', 'position': 2},
      {'name': 'Fear Of Heights', 'artists': 'Drake', 'position': 3},
      {'name': 'Daylight', 'artists': 'Drake', 'position': 4},
      {
        'name': 'First Person Shooter(feat. J.Cole)',
        'artists': 'Drake, J.Cole',
        'position': 5
      },
      {'name': 'IDGAF', 'artists': 'Drake, Yeat', 'position': 6},
      {'name': '7969 Santa', 'artists': 'Drake', 'position': 7},
      {
        'name': 'Slime You Out(feat. SZA)',
        'artists': 'Drake, SZA',
        'position': 8
      },
      {'name': 'Bahamas Promises', 'artists': 'Drake', 'position': 9},
      {'name': 'Tired Our Best', 'artists': 'Drake', 'position': 10},
      {
        'name': 'Screw The World - Interlude',
        'artists': 'Drake',
        'position': 11
      },
      {'name': 'Drew A Picasso', 'artists': 'Drake', 'position': 12},
      {
        'name': 'Members Only(feat. PARTYNEXTDOOR)',
        'artists': 'Drake, PARTYNEXTDOOR',
        'position': 13
      },
      {'name': 'What Would Pluto Do', 'artists': 'Drake', 'position': 14},
      {
        'name': 'All The Parties(feat. Chief Keef)',
        'artists': 'Drake, Chief Keef',
        'position': 15
      },
      {'name': '8am in Charlotte', 'artists': 'Drake', 'position': 16},
      {'name': 'BBL Love', 'artists': 'Drake', 'position': 17},
      {
        'name': 'Gently(feat. Bad Bunny)',
        'artists': 'Drake, Bad Bunny',
        'position': 18
      },
      {
        'name': 'Rich Baby Daddy(feat. Sexy Red & SZA)',
        'artists': 'Drake, Sexy Red, SZA',
        'position': 19
      },
      {
        'name': 'Another Late Night(feat. Lil Youghty)',
        'artists': 'Drake, Lil Youghty',
        'position': 20
      },
      {'name': 'Away From Home', 'artists': 'Drake', 'position': 21},
      {'name': 'Polar Opposites', 'artists': 'Drake', 'position': 22},
    ];

    await _firestore.collection('albums').doc('drake-for-all-the-dogs').set({
      'id': 'drake-for-all-the-dogs',
      'name': 'For All The Dogs',
      'artist': 'Drake',
      'coverUrl': ImageService.resolveImageUrl(
          'images/artists/Drake-For-All-The-Dogs.jpg'),
      'year': '2023',
      'trackCount': drakeTracks.length,
      'isPlayable': true,
    });

    for (var track in drakeTracks) {
      await _firestore
          .collection('albums')
          .doc('drake-for-all-the-dogs')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Created album: For All The Dogs (${drakeTracks.length} tracks)');

    // Travis Scott - UTOPIA
    final travisTracks = [
      {'name': 'HYENA', 'artists': 'Travis Scott', 'position': 0},
      {'name': 'THANK GOD', 'artists': 'Travis Scott', 'position': 1},
      {'name': 'MODERN JAM', 'artists': 'Travis Scott', 'position': 2},
      {'name': 'MY EYES', 'artists': 'Travis Scott', 'position': 3},
      {'name': 'GOD\'S COUNTRY', 'artists': 'Travis Scott', 'position': 4},
      {'name': 'SIRENS', 'artists': 'Travis Scott', 'position': 5},
      {
        'name': 'MELTDOWN (feat. Drake)',
        'artists': 'Travis Scott, Drake',
        'position': 6
      },
      {
        'name': 'FE!N (feat. Playboi Carti)',
        'artists': 'Travis Scott, Playboi Carti',
        'position': 7
      },
      {
        'name': 'DELESTO (ECHOES) (feat Beyonce)',
        'artists': 'Travis Scott, Beyonce',
        'position': 8
      },
      {'name': 'I KNOW ?', 'artists': 'Travis Scott', 'position': 9},
      {
        'name': 'TOPIA TWINS (feat. Rob49 & 21 Savage)',
        'artists': 'Travis Scott, Rob 49, 21 Savage',
        'position': 10
      },
      {
        'name': 'CIRCUS MAXIMUS (feat. The Weekend & Swea Lee)',
        'artists': 'Travis Scott, The Weekend, Swea Lee',
        'position': 11
      },
      {
        'name': 'PARASAIL (feat. Young Lean, Dave Chappelle)',
        'artists': 'Young Lean, Dave Chappelle',
        'position': 12
      },
      {
        'name': 'SKITZO (feat. Young Thug)',
        'artists': 'Travis Scott, Young Thug',
        'position': 13
      },
      {
        'name': 'LOST FOREVER (feat. Westside Gunn)',
        'artists': 'Travis Scott, Westside Gunn',
        'position': 14
      },
      {
        'name': 'LOOVE (feat. Kid Cudi)',
        'artists': 'Travis Scott, Kid Cudi',
        'position': 15
      },
      {
        'name': 'K-POP (feat. Bad Bunny & The Weekend)',
        'artists': 'Travis Scott, Bad Bunny, The Weekend',
        'position': 16
      },
      {
        'name': 'TELEKIESIS (feat. SZA & Future)',
        'artists': 'Travis Scott, SZA, Future',
        'position': 17
      },
      {
        'name': 'TIL FUTURE NOTICE (feat. James Blake & 21 Savage)',
        'artists': 'Travis Scott, James Blake, 21 Savage',
        'position': 18
      },
    ];

    await _firestore.collection('albums').doc('travis-scott-utopia').set({
      'id': 'travis-scott-utopia',
      'name': 'UTOPIA',
      'artist': 'Travis Scott',
      'coverUrl': ImageService.resolveImageUrl(
          'images/artists/Travis-Scott-Utopia.jpg'),
      'year': '2023',
      'trackCount': travisTracks.length,
      'isPlayable': true,
    });

    for (var track in travisTracks) {
      await _firestore
          .collection('albums')
          .doc('travis-scott-utopia')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Created album: UTOPIA (${travisTracks.length} tracks)');

    // Post Malone - AUSTIN
    final postTracks = [
      {'name': 'Don\'t Understand', 'artists': 'Post Malone', 'position': 0},
      {'name': 'Something Real', 'artists': 'Post Malone', 'position': 1},
      {'name': 'Chemical', 'artists': 'Post Malone', 'position': 2},
      {'name': 'Novacandy', 'artists': 'Post Malone', 'position': 3},
      {'name': 'Mourning', 'artists': 'Post Malone', 'position': 4},
      {'name': 'Too Cool To Die', 'artists': 'Post Malone', 'position': 5},
      {'name': 'Sign Me Up', 'artists': 'Post Malone', 'position': 6},
      {'name': 'Socialite', 'artists': 'Post Malone', 'position': 7},
      {'name': 'Overdrive', 'artists': 'Post Malone', 'position': 8},
      {'name': 'Speedometer', 'artists': 'Post Malone', 'position': 9},
      {'name': 'Hold My Breath', 'artists': 'Post Malone', 'position': 10},
      {'name': 'Enough Is Enough', 'artists': 'Post Malone', 'position': 11},
      {'name': 'Texas Tea', 'artists': 'Post Malone', 'position': 12},
      {'name': 'Buyer Beware', 'artists': 'Post Malone', 'position': 13},
      {'name': 'Landmine', 'artists': 'Post Malone', 'position': 14},
      {'name': 'Green Thumb', 'artists': 'Post Malone', 'position': 15},
      {'name': 'Laught It Off', 'artists': 'Post Malone', 'position': 16},
    ];

    await _firestore.collection('albums').doc('post-malone-austin').set({
      'id': 'post-malone-austin',
      'name': 'AUSTIN',
      'artist': 'Post Malone',
      'coverUrl':
          ImageService.resolveImageUrl('images/artists/Post-Malone-Austin.jpg'),
      'year': '2023',
      'trackCount': postTracks.length,
      'isPlayable': true,
    });

    for (var track in postTracks) {
      await _firestore
          .collection('albums')
          .doc('post-malone-austin')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Created album: AUSTIN (${postTracks.length} tracks)');

    // 21 Savage - american dream
    final savageTracks = [
      {'name': 'american dream', 'artists': '21 Savage', 'position': 0},
      {'name': 'all of me', 'artists': '21 Savage', 'position': 1},
      {'name': 'redrum', 'artists': '21 Savage', 'position': 2},
      {'name': 'n.h.i.e', 'artists': '21 Savage, Doja Cat', 'position': 3},
      {'name': 'sneaky', 'artists': '21 Savage', 'position': 4},
      {
        'name': 'pop ur shit',
        'artists': '21 Savage, Young Thug, Metro Boomin',
        'position': 5
      },
      {'name': 'letter to my brudda', 'artists': '21 Savage', 'position': 6},
      {
        'name': 'dangerous',
        'artists': '21 Savage, Lil Durk, Metro Boomin',
        'position': 7
      },
      {
        'name': 'nee-nah',
        'artists': '21 Savage, Travis Scott, Metro Boomin',
        'position': 8
      },
      {'name': 'see the real', 'artists': '21 Savage', 'position': 9},
      {
        'name': 'prove it',
        'artists': '21 Savage, Summer Walker',
        'position': 10
      },
      {
        'name': 'sould\'ve wore a bonnet',
        'artists': '21 Savage, Brent Fiyaz',
        'position': 11
      },
      {
        'name': 'just like me',
        'artists': '21 Savage, Burna Boy, Metro Boomin',
        'position': 12
      },
      {
        'name': 'red sky',
        'artists': '21 Savage, Tommy Newport, Milkky Ekko',
        'position': 13
      },
      {
        'name': 'dark days',
        'artists': '21 Savage, Mariah the Scientist',
        'position': 14
      },
    ];

    await _firestore.collection('albums').doc('21-savage-american-dream').set({
      'id': '21-savage-american-dream',
      'name': 'american dream',
      'artist': '21 Savage',
      'coverUrl': ImageService.resolveImageUrl(
          'images/artists/21-Savage-American-Dream.jpg'),
      'year': '2023',
      'trackCount': savageTracks.length,
      'isPlayable': true,
    });

    for (var track in savageTracks) {
      await _firestore
          .collection('albums')
          .doc('21-savage-american-dream')
          .collection('tracks')
          .doc('${track['position']}')
          .set(track);
    }
    print('  ✓ Created album: american dream (${savageTracks.length} tracks)');
  }

  // ============================================================================
  // ARTISTS
  // ============================================================================

  static Future<void> seedArtists() async {
    print('Seeding artists...');

    final artists = [
      {
        'id': '21-savage',
        'name': '21 Savage',
        'imageUrl':
            ImageService.resolveImageUrl('images/artists/21-Savage.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 30000000,
        'popularity': 92,
      },
      {
        'id': 'adele',
        'name': 'Adele',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Adele.jpg'),
        'genres': ['pop', 'soul'],
        'followers': 50000000,
        'popularity': 95,
      },
      {
        'id': 'cardi-b',
        'name': 'Cardi B',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Cardi-B.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 28000000,
        'popularity': 90,
      },
      {
        'id': 'dababy',
        'name': 'DaBaby',
        'imageUrl': ImageService.resolveImageUrl('images/artists/DaBaby.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 25000000,
        'popularity': 88,
      },
      {
        'id': 'doja-cat',
        'name': 'Doja Cat',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Doja-Cat.jpg'),
        'genres': ['hip-hop', 'pop'],
        'followers': 40000000,
        'popularity': 91,
      },
      {
        'id': 'drake',
        'name': 'Drake',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Drake.jpg'),
        'genres': ['hip-hop', 'rap', 'canadian-hip-hop'],
        'followers': 69000000,
        'popularity': 94,
      },
      {
        'id': 'eminem',
        'name': 'Eminem',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Eminem.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 56000000,
        'popularity': 93,
      },
      {
        'id': 'future',
        'name': 'Future',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Future.jpg'),
        'genres': ['hip-hop', 'rap', 'trap'],
        'followers': 32000000,
        'popularity': 89,
      },
      {
        'id': 'j-cole',
        'name': 'J Cole',
        'imageUrl': ImageService.resolveImageUrl('images/artists/J-Cole.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 35000000,
        'popularity': 90,
      },
      {
        'id': 'ice-cube',
        'name': 'Ice Cube',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Ice-Cube.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 20000000,
        'popularity': 85,
      },
      {
        'id': 'jay-z',
        'name': 'Jay Z',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Jay-Z.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 48000000,
        'popularity': 92,
      },
      {
        'id': 'jid',
        'name': 'JID',
        'imageUrl': ImageService.resolveImageUrl('images/artists/JID.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 18000000,
        'popularity': 87,
      },
      {
        'id': 'kanye-west',
        'name': 'Kanye West',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Kanye-West.jpg'),
        'genres': ['hip-hop', 'rap', 'producer'],
        'followers': 33000000,
        'popularity': 88,
      },
      {
        'id': 'kendrick-lamar',
        'name': 'Kendrick Lamar',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Kendrick-Lamar.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 30000000,
        'popularity': 92,
      },
      {
        'id': 'lil-baby',
        'name': 'Lil Baby',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Lil-Baby.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 29000000,
        'popularity': 90,
      },
      {
        'id': 'lil-wayne',
        'name': 'Lil Wayne',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Lil-Wayne.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 32000000,
        'popularity': 89,
      },
      {
        'id': 'megan-thee-stallion',
        'name': 'Megan Thee Stallion',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Megan-Thee-Stallion.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 27000000,
        'popularity': 88,
      },
      {
        'id': 'metro-boomin',
        'name': 'Metro Boomin',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Metro-Boomin.jpg'),
        'genres': ['hip-hop', 'producer'],
        'followers': 22000000,
        'popularity': 86,
      },
      {
        'id': 'nicki-minaj',
        'name': 'Nicki Minaj',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Nicki-Minaj.jpg'),
        'genres': ['hip-hop', 'rap', 'pop'],
        'followers': 46000000,
        'popularity': 91,
      },
      {
        'id': 'post-malone',
        'name': 'Post Malone',
        'imageUrl':
            ImageService.resolveImageUrl('images/artists/Post-Malone.jpg'),
        'genres': ['hip-hop', 'rap', 'pop'],
        'followers': 37000000,
        'popularity': 90,
      },
      {
        'id': 'selena-gomez',
        'name': 'Selena Gomez',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Selena-Gomez.jpg'),
        'genres': ['pop'],
        'followers': 45000000,
        'popularity': 89,
      },
      {
        'id': 'snoop-dogg',
        'name': 'Snoop Dogg',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Snoop-Dogg.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 38000000,
        'popularity': 87,
      },
      {
        'id': 'taylor-swift',
        'name': 'Taylor Swift',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Taylor-Swift.jpg'),
        'genres': ['pop', 'country-pop'],
        'followers': 92000000,
        'popularity': 96,
      },
      {
        'id': 'travis-scott',
        'name': 'Travis Scott',
        'imageUrl':
            ImageService.resolveImageUrl('images/artists/Travis-Scott.jpg'),
        'genres': ['hip-hop', 'rap', 'trap'],
        'followers': 27000000,
        'popularity': 91,
      },
      {
        'id': 'tyler-the-creator',
        'name': 'Tyler The Creator',
        'imageUrl': ImageService.resolveImageUrl('images/artists/Tyler-The-Creator.jpg'),
        'genres': ['hip-hop', 'rap'],
        'followers': 24000000,
        'popularity': 89,
      },
    ];

    for (var artist in artists) {
      await _firestore
          .collection('artists')
          .doc(artist['id'] as String)
          .set(artist);
      print('  ✓ Created artist: ${artist['name']}');
    }
  }

  // ============================================================================
  // PODCASTS
  // ============================================================================

  static Future<void> seedPodcasts() async {
    print('Seeding podcasts...');

    final podcasts = [
      {
        'id': 'joe-rogan',
        'name': 'The Joe Rogan Experience',
        'coverUrl': ImageService.resolveImageUrl('images/home/Joe-Rogan.jpg'),
        'description': 'Long-form conversations with celebrities and creators',
      },
      {
        'id': 'iced-coffee-hour',
        'name': 'The Iced Coffee Hour',
        'coverUrl': ImageService.resolveImageUrl('images/home/Iced-Coffee-Hour.jpg'),
        'description': 'Casual conversations over coffee',
      },
      {
        'id': 'startalk',
        'name': 'StarTalk Radio',
        'coverUrl': ImageService.resolveImageUrl('images/home/StarTalk.jpg'),
        'description': 'Cosmic perspective on science and pop culture',
      },
      {
        'id': 'shxts-ngigs',
        'name': 'ShxtsNGigs',
        'coverUrl': ImageService.resolveImageUrl('images/home/ShxtsNGigs.jpg'),
        'description': 'Entertainment and lifestyle discussions',
      },
      {
        'id': 'podcast-p',
        'name': 'Podcast P',
        'coverUrl': ImageService.resolveImageUrl('images/home/Podcast-P.jpg'),
        'description': 'Popular podcast series',
      },
      {
        'id': 'nfr-podcast',
        'name': 'NFR Podcast',
        'coverUrl': ImageService.resolveImageUrl('images/home/NFR-Podcast.jpg'),
        'description': 'Music and cultural commentary',
      },
      {
        'id': 'modern-wisdom',
        'name': 'Modern Wisdom',
        'coverUrl': ImageService.resolveImageUrl('images/home/Modern-Wisdom.jpg'),
        'description':
            'Interviews with experts on psychology, health, and technology',
      },
      {
        'id': 'huberman-lab',
        'name': 'Huberman Lab',
        'coverUrl': ImageService.resolveImageUrl('images/home/Huberman-Lab.jpg'),
        'description':
            'Science and science-based tools for everyday life and performance',
      },
      {
        'id': 'fresh-fit',
        'name': 'Fresh&Fit Podcast',
        'coverUrl': ImageService.resolveImageUrl('images/home/Fresh-Fit.jpg'),
        'description': 'Health, fitness, and lifestyle advice',
      },
      {
        'id': 'distractible',
        'name': 'Distractible',
        'coverUrl': ImageService.resolveImageUrl('images/home/Distractible.jpg'),
        'description': 'Humorous stories and discussions',
      },
      {
        'id': 'jordan-peterson',
        'name': 'The Jordan B. Peterson Podcast',
        'coverUrl': ImageService.resolveImageUrl('images/home/Jordan-Peterson.jpg'),
        'description': 'In-depth conversations on psychology and philosophy',
      },
      {
        'id': 'american-english',
        'name': 'American English Podcast',
        'coverUrl': ImageService.resolveImageUrl('images/home/American-English.jpg'),
        'description': 'English language learning through real conversations',
      },
      {
        'id': 'comedy-is-joke',
        'name': 'COMEDY IS JOKE',
        'coverUrl': ImageService.resolveImageUrl('images/home/Comedy-Is-Joke.jpg'),
        'description': 'Comedy and humor podcast series',
      },
      {
        'id': 'bad-friends',
        'name': 'Bad Friends Podcast',
        'coverUrl': ImageService.resolveImageUrl('images/home/Bad-Friends.jpg'),
        'description': 'Comedians sharing hilarious stories and banter',
      },
      {
        'id': 'hotboxin',
        'name': 'Hotboxin',
        'coverUrl': ImageService.resolveImageUrl('images/home/Hotboxin.jpg'),
        'description': 'Comedy and entertainment discussions',
      },
    ];

    for (var podcast in podcasts) {
      await _firestore
          .collection('podcasts')
          .doc(podcast['id'] as String)
          .set(podcast);
      print('  ✓ Created podcast: ${podcast['name']}');
    }
  }

  // ============================================================================
  // HOME SCREEN CONFIG
  // ============================================================================

  static Future<void> seedHomeScreenConfig() async {
    print('Seeding home screen configuration...');

    final config = {
      'topMixes': [
        {'title': 'Drake Mix', 'playlistId': 'drake-mix', 'position': 0},
        {'title': '2010s Mix', 'playlistId': '2010s', 'position': 1},
        {'title': 'Upbeat Mix', 'playlistId': 'upbeat', 'position': 2},
        {'title': 'Chill Mix', 'playlistId': 'chill', 'position': 3},
      ],
      'recentPlays': [
        'drake-for-all-the-dogs',
        'travis-scott-utopia',
        'post-malone-austin',
        '21-savage-american-dream',
      ],
      'featuredArtists': [
        'drake',
        'taylor-swift',
        'eminem',
        'travis-scott',
        'kendrick-lamar',
        'post-malone',
        'the-weeknd',
        'j-cole',
      ],
      'featuredPodcasts': [
        'joe-rogan',
        'huberman-lab',
        'startalk',
        'modern-wisdom',
        'jordan-peterson',
      ],
      'featuredAlbums': [
        'drake-for-all-the-dogs',
        'travis-scott-utopia',
        'post-malone-austin',
        '21-savage-american-dream',
      ],
    };

    await _firestore.collection('config').doc('homeScreenSections').set(config);
    print('  ✓ Created home screen configuration');
  }

  /// Clear all Firestore collections (use with caution!)
  static Future<void> clearAllData() async {
    print('WARNING: Clearing all Firestore collections...');

    try {
      // Clear playlists and their tracks
      final playlistsSnapshot = await _firestore.collection('playlists').get();
      for (var doc in playlistsSnapshot.docs) {
        final tracksSnapshot = await doc.reference.collection('tracks').get();
        for (var trackDoc in tracksSnapshot.docs) {
          await trackDoc.reference.delete();
        }
        await doc.reference.delete();
      }

      // Clear other collections
      for (var collection in ['artists', 'podcasts', 'config', 'metadata']) {
        final snapshot = await _firestore.collection(collection).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      print('✓ All data cleared');
    } catch (e) {
      print('✗ Error clearing data: $e');
      rethrow;
    }
  }
}
