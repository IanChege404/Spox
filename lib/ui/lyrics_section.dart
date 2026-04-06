import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_state.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:animations/animations.dart';
import 'package:spotify_clone/ui/lyrics_screen.dart';

class LyricsSection extends StatelessWidget {
  const LyricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff2c7c93),
            Color(0xff215260),
            Color(0xff141517),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              OpenContainer(
                openElevation: 0.0,
                closedElevation: 0.0,
                transitionDuration: const Duration(milliseconds: 400),
                middleColor: Colors.transparent,
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                closedBuilder: (context, action) {
                  return const _LyricsSection();
                },
                openBuilder: (context, action) {
                  return const LyricsScreen();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricsSection extends StatelessWidget {
  const _LyricsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 30),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xff2b8094),
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 33,
            left: 15,
            child: Text(
              "Lyrics",
              style: TextStyle(
                fontFamily: "AM",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MyColors.whiteColor,
              ),
            ),
          ),
          Positioned(
            top: 33,
            right: 15,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: MyColors.darGreyColor.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Text(
                        "MORE",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 10,
                          color: MyColors.whiteColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset("images/icon_bigger_size.png"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 15,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 47),
              child: Container(
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 1),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/share.png',
                          height: 10,
                          width: 10,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "SHARE",
                          style: TextStyle(
                            fontFamily: "AM",
                            fontSize: 10,
                            color: MyColors.whiteColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 30),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.22,
              width: MediaQuery.of(context).size.width,
              child: BlocBuilder<LyricsBloc, LyricsState>(
                builder: (context, state) {
                  if (state is LyricsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: MyColors.whiteColor,
                      ),
                    );
                  } else if (state is LyricsLoaded) {
                    final lyrics = state.lyrics;
                    if (lyrics.lines.isEmpty) {
                      return const Center(
                        child: Text(
                          "No lyrics available",
                          style: TextStyle(
                            color: MyColors.whiteColor,
                            fontFamily: "AM",
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    // Display lyrics with current line highlighted
                    return SingleChildScrollView(
                      child: Column(
                        children: lyrics.lines.asMap().entries.map((entry) {
                          final isCurrentLine = entry.value ==
                              lyrics.getCurrentLine(state.currentPosition);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              entry.value.text,
                              style: TextStyle(
                                color: isCurrentLine
                                    ? Colors.yellow
                                    : MyColors.whiteColor,
                                fontFamily: "AM",
                                fontWeight: isCurrentLine
                                    ? FontWeight.w800
                                    : FontWeight.w400,
                                fontSize: isCurrentLine ? 18 : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else if (state is LyricsNotFound) {
                    return const Center(
                      child: Text(
                        "No lyrics found",
                        style: TextStyle(
                          color: MyColors.whiteColor,
                          fontFamily: "AM",
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else if (state is LyricsError) {
                    return Center(
                      child: Text(
                        "Error loading lyrics",
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontFamily: "AM",
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // Initial state: show placeholder
                  return const Center(
                    child: Text(
                      "Play a song to see lyrics",
                      style: TextStyle(
                        color: MyColors.whiteColor,
                        fontFamily: "AM",
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
