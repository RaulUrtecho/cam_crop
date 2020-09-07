import 'dart:async';

import 'package:cam_crop/identification_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: IdentificationSlide()),
  );
}
