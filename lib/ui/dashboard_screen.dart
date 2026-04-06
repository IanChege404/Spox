import 'package:flutter/material.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/ui/equalizer_screen.dart';
import 'package:spotify_clone/ui/home_screen.dart';
import 'package:spotify_clone/ui/library_screen.dart';
import 'package:spotify_clone/ui/offline_screen.dart';
import 'package:spotify_clone/ui/search_category_screen.dart';
import 'package:spotify_clone/ui/stats_screen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        height: 64,
        width: MediaQuery.of(context).size.width,
        color: MyColors.blackColor.withValues(alpha: 0.95),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontFamily: "AM", fontSize: 11),
            selectedItemColor: const Color(0xffE5E5E5),
            unselectedItemColor: MyColors.lightGrey,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('images/icon_home.png'),
                activeIcon: Image.asset('images/icon_home_active.png'),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'images/icon_search_bottomnav.png',
                ),
                activeIcon: Image.asset(
                  'images/icon_search_active.png',
                  color: MyColors.whiteColor,
                ),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'images/icon_library.png',
                  color: MyColors.lightGrey,
                ),
                activeIcon: Image.asset(
                  'images/icon_library_active.png',
                  color: MyColors.whiteColor,
                ),
                label: "Library",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                activeIcon: Icon(Icons.bar_chart),
                label: "Stats",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.equalizer),
                activeIcon: Icon(Icons.equalizer, color: Color(0xff1ED760)),
                label: "EQ",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.download_outlined),
                activeIcon: Icon(Icons.download, color: Color(0xff1ED760)),
                label: "Offline",
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const SearchCategoryScreen(),
          const LibraryScreen(),
          const StatsScreen(),
          const EqualizerScreen(),
          const OfflineScreen(),
        ],
      ),
    );
  }
}
