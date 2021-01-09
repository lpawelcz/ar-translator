import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';
import 'detector_painters.dart';
import 'package:native_screenshot/native_screenshot.dart';

class LiveOcr extends StatefulWidget {
  @override
  _LiveOcrState createState() => _LiveOcrState();
}

class _LiveOcrState extends State<LiveOcr> {
  bool renderResults = true;

  final _scanKey = GlobalKey<CameraMlVisionState>();

  VisionText readTextResult;
  Size cameraSize;
  List<dynamic> translatedText;
  bool isTextInTranslator = false;

  ResolutionPreset resolutionPreset = ResolutionPreset.high;

  TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

  @override
  void initState() {
    super.initState();
  }

  Future _readText(VisionText text) async {
    Size imageSize = Size(
      _scanKey.currentState.cameraValue.previewSize.height,
      _scanKey.currentState.cameraValue.previewSize.width,
    );

    readTextResult = text;
    cameraSize = imageSize;

    var destText = [];
    String destLang = "pl";

    if (!isTextInTranslator) {
      TextTranslator translator = new TextTranslator();

      isTextInTranslator = true;

      CameraMlVision<VisionText>(
        key: _scanKey,
        detector: textRecognizer.processImage,
        onResult: null,
        resolution: resolutionPreset,
        cameraLensDirection: CameraLensDirection.back,
        onDispose: () {
          textRecognizer.close();
        },
      );

      await translator.init("apikey.json",
          "https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/c6b84156-6dd7-43cc-823d-719270063d12/");
      destText = await translator.translateAll(text, destLang);

      CameraMlVision<VisionText>(
        key: _scanKey,
        detector: textRecognizer.processImage,
        onResult: _readText,
        resolution: resolutionPreset,
        cameraLensDirection: CameraLensDirection.back,
        onDispose: () {
          textRecognizer.close();
        },
      );

  Future _onMenuAction(String option) async {
    if (option == MenuOptions.Copy) {
      print('Copy');
    } else if (option == MenuOptions.RenderResults) {
      setState(() {
        renderResults = !renderResults;
      });
    } else if (option == MenuOptions.GoBack) {
      Navigator.pop(context);
    }
  }

  Widget _resultsRenderer() {
    const Text noResultsText = Text('Loading...');
    if (readTextResult == null) {
      print(noResultsText);
      return Center(
        child: noResultsText,
      );
    }

    print("RESULTSSSSS COUNT: " + readTextResult.blocks.length.toString());

    if (translatedText == null) {
      return CustomPaint(
        painter:
            TextDetectorPainter(cameraSize, readTextResult, isTextInTranslator),
      );
    } else if (!isTextInTranslator) {
      if (translatedText.isNotEmpty) {
        return CustomPaint(
          painter: TextDetectorPainter.formTextDetectorPainter(
              cameraSize, readTextResult, isTextInTranslator, translatedText),
        );
      } else {
        return CustomPaint(
          painter: TextDetectorPainter(
              cameraSize, readTextResult, isTextInTranslator),
        );
      }
    } else {
      return CustomPaint(
        painter:
            TextDetectorPainter(cameraSize, readTextResult, isTextInTranslator),
      );
    }
  }

  void _takeScreenshot() async {
    String imgPath = await NativeScreenshot.takeScreenshot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Translator'),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _onMenuAction,
              itemBuilder: (BuildContext context) {
                return MenuOptions.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              })
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
                cameraLensDirection: CameraLensDirection.back,
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
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => print("save to clipboard"),
            child: Icon(Icons.save_outlined),
            heroTag: null,
          ),
          SizedBox(height: 7),
          FloatingActionButton(
            onPressed: () {
              _takeScreenshot();
            },
            child: Icon(Icons.add_a_photo_outlined),
            heroTag: null,
          )
        ],
      ),
    );
  }
}

class MenuOptions {
  static const String RenderResults = 'Render Results';
  static const String Copy = 'Copy';
  static const String GoBack = 'Go Back';

  static const List<String> choices = <String>[RenderResults, Copy, GoBack];
}
