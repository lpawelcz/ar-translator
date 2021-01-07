import 'dart:typed_data';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'detector_painters.dart';

List<CameraDescription> cameras;

class LiveOcr extends StatefulWidget {
  @override
  _LiveOcrState createState() => _LiveOcrState();
}

class _LiveOcrState extends State<LiveOcr> {
  CameraController camController;
  bool camMounted = false;
  bool renderResults = true;

  VisionText readTextResult;
  Size cameraSize;


  final int cameraDirectionBack = 0;
  final int cameraDirectionFront = 1;

  int cameraDirection;
  bool isDetecting = false;


  @override
  void initState() {
    super.initState();
    cameraDirection = cameraDirectionBack;
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (camController == null || !camController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      camController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (camController != null) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    if (camController != null) {
      await camController.dispose();
    }

    camController = CameraController(cameras[cameraDirection], ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    camController.addListener(() {
      if (mounted) setState(() {});
      if (camController.value.hasError) {
        print('Camera error ${camController.value.errorDescription}');
      }
    });

    try {
      camController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          camMounted = true;
          cameraSize = Size(
            camController.value.previewSize.height,
            camController.value.previewSize.width,
          );
        });

        camController.startImageStream((CameraImage image) {
          if (isDetecting) return;

          print("Detectomg!!!");

          isDetecting = true;

          _readText(image).then((dynamic results){
            setState(() {
              readTextResult = results;
              isDetecting = false;
            });
          });
        }).whenComplete(() => isDetecting = false);
      });
    } on CameraException catch (e) {
    print(e);
    }
  }

  static FirebaseVisionImageMetadata _buildMetaData(
      CameraImage image,
      ImageRotation rotation,
      ) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes.map(
            (Plane plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  static ImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }


  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future _readText(CameraImage image) async {
    FirebaseVisionImage FBImage =
    FirebaseVisionImage
        .fromBytes(
        _concatenatePlanes(image.planes),
        _buildMetaData(image, _rotationIntToImageRotation(cameras[cameraDirection].sensorOrientation)));
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    return recognizeText.processImage(FBImage);
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
    await camController.stopImageStream();
    camController.dispose();
    if(cameraDirection == cameraDirectionBack){
      cameraDirection = cameraDirectionFront;
    }else{
      cameraDirection = cameraDirectionBack;
    }
    setState(() {
      camMounted = false;
    });
    await _initializeCamera();
    setState(() {
      camMounted = true;
    });
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
          child: (camMounted == false && camController == null)
              ? Text('Camera not Initialized')
              : Container(
              color: Colors.black,
              child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(camController),
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

  @override
  void dispose() {
    camController.stopImageStream();
    camController?.dispose();
    super.dispose();
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