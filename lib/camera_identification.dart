import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imgLib;

class CameraIdentification extends StatefulWidget {
  final CameraDescription camera;
  final ValueSetter<Image> onNewPhoto;

  const CameraIdentification(
      {Key key, @required this.camera, @required this.onNewPhoto})
      : super(key: key);

  @override
  CameraIdentificationState createState() => CameraIdentificationState();
}

class CameraIdentificationState extends State<CameraIdentification> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  imgLib.Image image;
  Image photo;
  bool isPhotoTaken = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double textHeigth = MediaQuery.of(context).size.height * 0.1;
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: SafeArea(
        child: isPhotoTaken
            ? Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: textHeigth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Guardar foto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: textHeigth),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        child: photo,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height:
                            (MediaQuery.of(context).size.width * 0.8 / 1.57),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 36,
                              ),
                              onPressed: () {
                                setState(() => isPhotoTaken = false);
                              },
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 36,
                              ),
                              onPressed: () {
                                widget.onNewPhoto(photo);
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      children: <Widget>[
                        Container(color: Colors.black),
                        CustomPaint(
                          foregroundPainter: P(),
                          child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: CameraPreview(_controller)),
                        ),
                        ClipPath(
                          clipper: Clip(),
                          child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: CameraPreview(_controller)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: textHeigth),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Centra tu INE dentro del espacio.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isPhotoTaken
          ? null
          : FloatingActionButton(
              child: Icon(Icons.camera_alt),
              onPressed: () => _takePhoto(),
            ),
    );
  }

  void _takePhoto() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);
      //------------CROP---------
      image = imgLib.decodeImage(File(path).readAsBytesSync());
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
      photo = Image.memory(imgLib.encodeJpg(image), fit: BoxFit.contain);
      setState(() => isPhotoTaken = true);
    } catch (e) {
      print(e);
    }
  }
}

class P extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.5), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double wCard = size.width * 0.94;
    double hCard = (wCard / 1.57);
    double left = (size.width / 2) - (wCard / 2);
    double top = (size.height / 2) - (hCard / 2);

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, wCard, hCard),
        Radius.circular(10),
      ));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => true;
}
