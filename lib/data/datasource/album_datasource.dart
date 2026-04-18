import 'dart:ui';

import 'package:spotify_clone/core/audio/sample_audio_helper.dart';
import 'package:spotify_clone/data/model/album.dart';
import 'package:spotify_clone/data/model/album_track.dart';

abstract class AlbumDatasource {
  Future<Album> albumList(String singer);
}

/// DEPRECATED: Local hardcoded album data
/// Migration Status: Keep for backward compatibility only
/// New implementations should use FirestoreDataSource instead.
/// All local album data (4 albums, 75 tracks) has been migrated to Firestore.
/// See: lib/core/utils/firestore_seed_data.dart for complete data setup
class AlbumLocalDatasource extends AlbumDatasource {
  @override
  Future<Album> albumList(String singer) async {
    if (singer == "Drake") {
      return Album(
        'For-All-The-Dogs.jpg',
        "For All The Dogs",
        "Drake",
        [
          AlbumTrack("Virginia Beach", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Virginia Beach")),
          AlbumTrack("Amen(feat. Teezo Touchdown)", "Drake, Teezo Touchdown",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("Amen(feat. Teezo Touchdown)")),
          AlbumTrack("Calling For You", "Drake, 21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("Calling For You")),
          AlbumTrack("Fear Of Heights", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Fear Of Heights")),
          AlbumTrack("Daylight", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Daylight")),
          AlbumTrack("First Person Shooter(feat. J.Cole)", "Drake, J.Cole",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "First Person Shooter(feat. J.Cole)")),
          AlbumTrack("IDGAF", "Drake, Yeat",
              audioUrl: SampleAudioHelper.getAudioUrl("IDGAF")),
          AlbumTrack("7969 Santa", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("7969 Santa")),
          AlbumTrack("Slime You Out(feat. SZA)", "Drake, SZA",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("Slime You Out(feat. SZA)")),
          AlbumTrack("Bahamas Promises", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Bahamas Promises")),
          AlbumTrack("Tired Our Best", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Tired Our Best")),
          AlbumTrack("Screw The World - Interlude", "Drake",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("Screw The World - Interlude")),
          AlbumTrack("Drew A Picasso", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Drew A Picasso")),
          AlbumTrack(
              "Members Only(feat. PARTYNESTDOOR)", "Drake, PARTYNEXTDOOR",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "Members Only(feat. PARTYNESTDOOR)")),
          AlbumTrack("What Would Pluto Do", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("What Would Pluto Do")),
          AlbumTrack("All The Parties(feat. Chief Keef)", "Drake, Chief Keef",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "All The Parties(feat. Chief Keef)")),
          AlbumTrack("8am in Charlotte", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("8am in Charlotte")),
          AlbumTrack("BBL Love", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("BBL Love")),
          AlbumTrack("Gently(feat. Bad Bunny)", "Drake, Bad Bunny",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("Gently(feat. Bad Bunny)")),
          AlbumTrack(
              "Rich Baby Daddy(feat. Sexy Red & SZA)", "Drake, Sexy Red, SZA",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "Rich Baby Daddy(feat. Sexy Red & SZA)")),
          AlbumTrack(
              "Another Late Night(feat. Lil Youghty)", "Drake, Lil Youghty",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "Another Late Night(feat. Lil Youghty)")),
          AlbumTrack("Away From Home", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Away From Home")),
          AlbumTrack("Polar Opposites", "Drake",
              audioUrl: SampleAudioHelper.getAudioUrl("Polar Opposites")),
        ],
        "2023",
        "Drake.jpg",
        [
          const Color(0xff7c837b),
          const Color(0xff313330),
          const Color(0xff151515)
        ],
      );
    } else if (singer == "Travis Scott") {
      return Album(
        'UTOPIA.jpg',
        "UTOPIA",
        "Travis Scott",
        [
          AlbumTrack("HYENA", "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("HYENA")),
          AlbumTrack("THANK GOD", "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("THANK GOD")),
          AlbumTrack('MODERN JAM', "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("MODERN JAM")),
          AlbumTrack('MY EYES', "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("MY EYES")),
          AlbumTrack("GOD'S COUNTRY", "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("GOD'S COUNTRY")),
          AlbumTrack('SIRENS', "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("SIRENS")),
          AlbumTrack("MELTDOWN (feat. Drake)", "Travis Scott, Drake",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("MELTDOWN (feat. Drake)")),
          AlbumTrack('FE!N (feat. Playboi Carti)', "Travis Scott, Playboi Cart",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("FE!N (feat. Playboi Carti)")),
          AlbumTrack('DELESTO (ECHOES) (feat Beyonce)', "Travis Scott, Beyonce",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "DELESTO (ECHOES) (feat Beyonce)")),
          AlbumTrack("I KNOW ?", "Travis Scott",
              audioUrl: SampleAudioHelper.getAudioUrl("I KNOW ?")),
          AlbumTrack('TOPIA TWINS (feat. Rob49 & 21 Savage)',
              "Travis Scott, Rob 49, 21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "TOPIA TWINS (feat. Rob49 & 21 Savage)")),
          AlbumTrack('CIRCUS MAXIMUS (feat. The Weekend & Swea Lee)',
              "Travis Scott, The Weekend, Swea Lee",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "CIRCUS MAXIMUS (feat. The Weekend & Swea Lee)")),
          AlbumTrack("PARASAIL (feat. Young Lean, Dave Chappelle)",
              "Young Lean, Dave Chappelle",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "PARASAIL (feat. Young Lean, Dave Chappelle)")),
          AlbumTrack("SKITZO (feat. Young Thug)", "Travis Scott, Young Thug",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("SKITZO (feat. Young Thug)")),
          AlbumTrack("LOST FOREVER (feat. Westside Gunn)",
              "Travis Scott, Westside Gunn",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "LOST FOREVER (feat. Westside Gunn)")),
          AlbumTrack('LOOVE (feat. Kid Cudi)', "Travis Scott, Kid Cudi",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("LOOVE (feat. Kid Cudi)")),
          AlbumTrack("K-POP (feat. Bad Bunny & The Weekend)",
              "Travis Scott, Bad Bunny, The Weekend",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "K-POP (feat. Bad Bunny & The Weekend)")),
          AlbumTrack(
              "TELEKIESIS (feat. SZA & Future)", "Travis Scott, SZA, Future",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "TELEKIESIS (feat. SZA & Future)")),
          AlbumTrack('TIL FUTURE NOTICE (feat. James Blake & 21 Savage)',
              "Travis Scott, James Blake, 21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl(
                  "TIL FUTURE NOTICE (feat. James Blake & 21 Savage)")),
        ],
        "2023",
        "Travis-Scott.jpg",
        [
          const Color(0xff544444),
          const Color(0xff252120),
          const Color(0xff131313)
        ],
      );
    } else if (singer == "Post Malone") {
      return Album(
        'AUSTIN.jpg',
        "AUSTIN",
        "Post Malone",
        [
          AlbumTrack("Don't Understand", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Don't Understand")),
          AlbumTrack("Something Real", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Something Real")),
          AlbumTrack("Chemical", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Chemical")),
          AlbumTrack("Novacandy", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Novacandy")),
          AlbumTrack("Mourning", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Mourning")),
          AlbumTrack("Too Cool To Die", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Too Cool To Die")),
          AlbumTrack("Sign Me Up", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Sign Me Up")),
          AlbumTrack("Socialite", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Socialite")),
          AlbumTrack("Overdrive", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Overdrive")),
          AlbumTrack("Speedometer", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Speedometer")),
          AlbumTrack("Hold My Breath", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Hold My Breath")),
          AlbumTrack("Enough Is Enough", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Enough Is Enough")),
          AlbumTrack("Texas Tea", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Texas Tea")),
          AlbumTrack("Buyer Beware", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Buyer Beware")),
          AlbumTrack("Landmine", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Landmine")),
          AlbumTrack("Green Thumb", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Green Thumb")),
          AlbumTrack("Laught It Off", "Post Malone",
              audioUrl: SampleAudioHelper.getAudioUrl("Laught It Off")),
        ],
        "2023",
        "Post-Malone.jpg",
        [
          const Color(0xff8b9a63),
          const Color(0xff363a2b),
          const Color(0xff151513)
        ],
      );
    } else if (singer == "21 Savage") {
      return Album(
        'american-dream.jpg',
        "american dream",
        "21 Savage",
        [
          AlbumTrack("american dream", "21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("american dream")),
          AlbumTrack("all of me", "21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("all of me")),
          AlbumTrack("redrum", "21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("redrum")),
          AlbumTrack("n.h.i.e", "21 Savage, Doja Cat",
              audioUrl: SampleAudioHelper.getAudioUrl("n.h.i.e")),
          AlbumTrack("sneaky", "21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("sneaky")),
          AlbumTrack("pop ur shit", "21 Savage, Young Thug, Metro Boomin",
              audioUrl: SampleAudioHelper.getAudioUrl("pop ur shit")),
          AlbumTrack("letter to my brudda", "21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("letter to my brudda")),
          AlbumTrack("dangerous", "21 Savage, Lil Durk, Metro Boomin",
              audioUrl: SampleAudioHelper.getAudioUrl("dangerous")),
          AlbumTrack("nee-nah", "21 Savage, Travis Scott, Metro Bommin",
              audioUrl: SampleAudioHelper.getAudioUrl("nee-nah")),
          AlbumTrack("see the real", "21 Savage",
              audioUrl: SampleAudioHelper.getAudioUrl("see the real")),
          AlbumTrack("prove it", "21 Savage, Summer Walker",
              audioUrl: SampleAudioHelper.getAudioUrl("prove it")),
          AlbumTrack("sould've wore a bonnet", "21 Savage, Brent Fiyaz",
              audioUrl:
                  SampleAudioHelper.getAudioUrl("sould've wore a bonnet")),
          AlbumTrack("just like me", "21 Savage, Burna Boy, Metro Boomin",
              audioUrl: SampleAudioHelper.getAudioUrl("just like me")),
          AlbumTrack("red sky", "21 Savage, Tommy Newport, Milkky Ekko",
              audioUrl: SampleAudioHelper.getAudioUrl("red sky")),
          AlbumTrack("dark days", "21 Savage, Mariah the Scientist",
              audioUrl: SampleAudioHelper.getAudioUrl("dark days")),
        ],
        "2023",
        "21-Savage.jpg",
        [
          const Color(0xff747474),
          const Color(0xff343434),
          const Color(0xff121212)
        ],
      );
    } else {
      return Album("", "", "", [], "", "", []);
    }
  }
}
