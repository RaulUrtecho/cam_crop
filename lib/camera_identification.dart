import 'package:cam_crop/crop_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraIdentification extends StatefulWidget {
  final CameraDescription camera;

  const CameraIdentification({Key key, @required this.camera})
      : super(key: key);

  @override
  CameraIdentificationState createState() => CameraIdentificationState();
}

class CameraIdentificationState extends State<CameraIdentification> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

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
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return Container(
                child: Stack(
                  children: <Widget>[
                    CustomPaint(
                      foregroundPainter: P(),
                      child: CameraPreview(_controller),
                    ),
                    ClipPath(
                      clipper: Clip(),
                      child: CameraPreview(_controller),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 350),
                        child: Text(
                          'Centra tu INE dentro del espacio.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () => _takePhoto(),
      ),
    );
  }

  void _takePhoto() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
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

      // If the picture was taken, display it on a new screen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImage(imagePath: path),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.
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

//1.57
