import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:cam_crop/camera_identification.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraIdentification(camera: firstCamera), // Pass the camera.
    ),
  );
}
