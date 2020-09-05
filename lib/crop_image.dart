import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;

class CropImage extends StatefulWidget {
  final String imagePath;

  const CropImage({Key key, this.imagePath}) : super(key: key);

  @override
  _CropImageState createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  imgLib.Image image;
  Image cropped;

  @override
  void initState() {
    image = imgLib.decodeImage(File(widget.imagePath).readAsBytesSync());
    image = imgLib.copyRotate(image, 360); // rotar (orignal queda horizontal)
    print('h: ${image.height} w: ${image.width}');
    int wCard = (image.width * 0.94).toInt();
    int hCard = wCard ~/ 1.57;
    int x = ((image.width / 2) - (wCard / 2)).toInt();
    int y = ((image.height / 2) - (hCard / 2)).toInt();
    // Returned Image has dimensions width, height, starting from the x, y offset from the top-right corner.
    image = imgLib.copyCrop(image, x, y, wCard, hCard);
    cropped = Image.memory(imgLib.encodeJpg(image), fit: BoxFit.contain);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child:
                // Image.file(File(widget.imagePath)),
                Container(width: 280, child: cropped),
          ),
        ),
      ),
    );
  }
}
