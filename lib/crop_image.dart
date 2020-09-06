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
    // The camera plugin produces images in landscape mode always
    bool rotateBack = false;
    if (image.width > image.height) {
      image = imgLib.copyRotate(image, 90); // rotar
      rotateBack = true;
    }
    print('h: ${image.height} w: ${image.width}');
    int wCard = (image.width * 0.94).toInt();
    int hCard = wCard ~/ 1.57;
    int x = ((image.width / 2) - (wCard / 2)).toInt();
    int y = ((image.height / 2) - (hCard / 2)).toInt();
    image = imgLib.copyCrop(image, x, y, wCard, hCard);
    if (rotateBack) {
      image = imgLib.copyRotate(image, -90); // rotar
    }
    cropped = Image.memory(imgLib.encodeJpg(image), fit: BoxFit.contain);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: Container(width: 280, child: cropped)),
      ),
    );
  }
}
