// ignore_for_file: non_constant_identifier_names, file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:poppycorn/helpers/helpers.dart';

class MyCachedImage extends StatelessWidget {

  final String ImageUrl;
  final double ImageSize;
  final double? ImageHeight;
  final String? fit;

  const MyCachedImage({super.key,required this.ImageUrl,required this.ImageSize, this.ImageHeight, this.fit = 'cover'});

  @override
  Widget build(BuildContext context) {

    return CachedNetworkImage(
      imageUrl: ImageUrl,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorListener: (exception) {
        //print('Error loading image: $exception');
      },
      errorWidget: (context, url, error) => Center(
        child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: jActiveElementsColor,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Image.asset(
              "assets/images/yellowlogo.png",
              width: 20,
            )//Icon(Icons.no_accounts,size: 20,color: jTextColorLight,)
        ),
      ),
      width: ImageSize,
      height: ImageHeight,
      fit: fit == "cover" ? BoxFit.cover : BoxFit.fill,
    );

  }
}

/*

return Container(
            decoration: BoxDecoration(
              color: jActiveElementsColor,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Image.asset(
              "assets/images/yellowlogo.png",
              width: 30,
            )//Icon(Icons.no_accounts,size: 20,color: jTextColorLight,)
        );*/
