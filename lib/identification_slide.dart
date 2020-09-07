import 'package:cam_crop/camera_identification.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class IdentificationSlide extends StatefulWidget {
  @override
  _IdentificationSlideState createState() => _IdentificationSlideState();
}

class _IdentificationSlideState extends State<IdentificationSlide> {
  Image cardFront;
  Image cardBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 80),
          Text(
            "Agrega tu identificación",
            style: TextStyle(
                color: Color(0xff3da4ab),
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono'),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            "Parte frontal",
            style: TextStyle(
              color: Color(0xff3da4ab),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () => _openCamera(isFrontSide: true),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  child: cardFront,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: (MediaQuery.of(context).size.width * 0.6 / 1.57),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Parte posterior",
            style: TextStyle(
              color: Color(0xff3da4ab),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () => _openCamera(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  child: cardBack,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: (MediaQuery.of(context).size.width * 0.6 / 1.57),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Asegurate de no tapar la informacion de la tarjeta asi como tratar de tomarla lo mas enfocada/clara posible.",
            style: TextStyle(
                color: Color(0xfffe9c8f),
                fontSize: 20.0,
                fontStyle: FontStyle.italic,
                fontFamily: 'Raleway'),
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Future<void> _openCamera({bool isFrontSide = false}) async {
    availableCameras().then(
      (cameras) async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraIdentification(
              camera: cameras[0],
              onNewPhoto: (newPhoto) {
                isFrontSide
                    ? setState(() => cardFront = newPhoto)
                    : setState(() => cardBack = newPhoto);
              },
            ),
          ),
        );
      },
    );
  }
}
