import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';

import 'detector_painters.dart';

class LiveOcr extends StatefulWidget {
  @override
  _LiveOcrState createState() => _LiveOcrState();
}

class _LiveOcrState extends State<LiveOcr> {
  bool renderResults = true;

  final _scanKey = GlobalKey<CameraMlVisionState>();

  VisionText readTextResult;
  Size cameraSize;

  ResolutionPreset resolutionPreset = ResolutionPreset.high;

  TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

  final CameraLensDirection cameraDirectionBack = CameraLensDirection.back;
  final CameraLensDirection cameraDirectionFront = CameraLensDirection.front;

  CameraLensDirection cameraDirection;


  @override
  void initState() {
    super.initState();
    cameraDirection = cameraDirectionBack;
  }


  Future _readText(VisionText text) async {
    Size imageSize = Size(
      _scanKey.currentState.cameraValue.previewSize.height,
      _scanKey.currentState.cameraValue.previewSize.width,
    );

    setState(() {
      readTextResult = text;
      cameraSize = imageSize;
    });
  }


  Future _onMenuAction(String option) async {
    if(option == MenuOptions.Copy){
      print('Copy');
    }else if(option == MenuOptions.RenderResults){
      setState(() {
        renderResults = !renderResults;
      });
    }else if(option == MenuOptions.GoBack){
      Navigator.pop(context);
    }else if(option == MenuOptions.ChangeCamera){
      _changeCamera();
    }
  }

  Future _changeCamera() async {
    if(cameraDirection == cameraDirectionBack){
      setState(() {
        cameraDirection = cameraDirectionFront;
      });
    }else{
      setState(() {
        cameraDirection = cameraDirectionBack;
      });
    }
  }

  Widget _resultsRenderer() {
    const Text noResultsText = Text('No results!');
    if (readTextResult == null) {
      print(noResultsText);
      return Center(child: noResultsText,);
    }

    print("RESULTSSSSS COUNT: " + readTextResult.blocks.length.toString());

    return CustomPaint(
      painter: TextDetectorPainter(cameraSize, readTextResult),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Translator'),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _onMenuAction,
              itemBuilder: (BuildContext context){
                return MenuOptions.choices.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              }
          )
        ],
      ),
      body: Center(
          child: Container(
              color: Colors.black,
              child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraMlVision<VisionText>(
                  key: _scanKey,
                  detector: textRecognizer.processImage,
                  onResult: _readText,
                  resolution: resolutionPreset,
                  cameraLensDirection: cameraDirection,
                  onDispose: () {
                    textRecognizer.close();
                    },
                ),
                Visibility(
                  visible: renderResults,
                  child: _resultsRenderer(),
                ),
              ],
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeCamera,
        child: Icon(Icons.camera),
      ),
    );
  }
}

class MenuOptions{
  static const String ChangeCamera = 'ChangeCamera';
  static const String RenderResults = 'Render Results';
  static const String Copy = 'Copy';
  static const String GoBack = 'Go Back';

  static const List<String> choices = <String>[
    ChangeCamera,
    RenderResults,
    Copy,
    GoBack
  ];
}