// Update your FullScreenImageViewer to accept isNetworkImage parameter
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: isNetworkImage
            ? CachedNetworkImage(imageUrl: imagePath, fit: BoxFit.contain)
            : Image.file(File(imagePath), fit: BoxFit.contain),
      ),
    );
  }
}
