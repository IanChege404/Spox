import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/ui/search_screen.dart';
import 'package:spotify_clone/widgets/bottom_player.dart';

class SearchCategoryScreen extends StatefulWidget {
  const SearchCategoryScreen({super.key});

  @override
  State<SearchCategoryScreen> createState() => _SearchCategoryScreenState();
}

class _SearchCategoryScreenState extends State<SearchCategoryScreen> {
  String? scanResault;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Search",
                            style: TextStyle(
                              fontFamily: "AB",
                              fontSize: 25,
                              color: MyColors.whiteColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              barcodeScanner();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         const ScanSpotifyCodeScreen(),
                              //   ),
                              // );
                            },
                            child: Image.asset("images/icon_camera.png"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _SearchBox(),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 17, bottom: 17),
                      child: Text(
                        "Your top genres",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ImageContainer(title: "", image: "pop.png"),
                        _ImageContainer(title: "", image: "indie.png"),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 25, bottom: 10),
                      child: Text(
                        "Popular podcast categories",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width / 1.75) -
                                      50,
                              height: 100,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    "images/news&politics.png",
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              top: 10,
                              left: 10,
                              child: SizedBox(
                                width: 72,
                                child: Text(
                                  "News & Politics",
                                  style: TextStyle(
                                    fontFamily: "AB",
                                    fontSize: 16,
                                    color: MyColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const _ImageContainer(
                            title: "Comdey", image: "comedy.png"),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 25, bottom: 10),
                      child: Text(
                        "Browse all",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ImageContainer(
                            title: "2023 Wrapped", image: "2023_wrapped.png"),
                        _ImageContainer(
                            title: "Podcasts", image: "podcasts.png"),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ImageContainer(
                              title: "Made for you", image: "made_for_you.png"),
                          _ImageContainer(title: "Charts", image: "charts.png"),
                        ],
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 130),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 64),
              child: BottomPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  Future barcodeScanner() async {
    try {
      final controller = MobileScannerController();
      var scanResult = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SizedBox(
          height: 400,
          child: Stack(
            children: [
              MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    String? scannedValue = barcodes.first.rawValue;
                    Navigator.pop(context, scannedValue ?? '-1');
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, '-1'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (mounted && scanResult != null && scanResult != '-1') {
        setState(() {
          this.scanResault = scanResult;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          scanResault = "Failed to scan barcode: $e";
        });
      }
    }
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 46,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: MyColors.whiteColor,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Image.asset("images/icon_search_black.png"),
                const SizedBox(width: 15),
                const Text(
                  "What do you want to listen to?",
                  style: TextStyle(
                    fontFamily: "AB",
                    color: MyColors.darGreyColor,
                    fontSize: 15,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageContainer extends StatelessWidget {
  const _ImageContainer({required this.title, required this.image});
  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: (MediaQuery.of(context).size.width / 1.75) - 50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/$image"),
              fit: BoxFit.cover,
            ),
            color: Colors.red,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "AB",
              fontSize: 16,
              color: MyColors.whiteColor,
            ),
          ),
        ),
      ],
    );
  }
}
