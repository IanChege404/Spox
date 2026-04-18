import 'package:flutter/material.dart';
import 'package:spotify_clone/constants/constants.dart';

class ArtistChip extends StatelessWidget {
  const ArtistChip(
      {super.key,
      required this.image,
      required this.name,
      required this.radius,
      required this.isDeletable,
      this.onTap});
  final String image;
  final String name;
  final double radius;
  final bool isDeletable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: radius,
                    backgroundImage: image.startsWith('http')
                        ? NetworkImage(image)
                        : AssetImage("images/artists/$image") as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: "AM",
                          fontSize: 15,
                          color: MyColors.whiteColor,
                        ),
                      ),
                      const Text(
                        "Artist",
                        style: TextStyle(
                          fontFamily: "AM",
                          fontSize: 13,
                          color: MyColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: isDeletable,
                child: Image.asset(
                  'images/icon_back.png',
                  height: 14,
                  width: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
