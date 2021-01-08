import 'dart:io';

import 'package:ar_translator/translation/text-transl.dart';
import 'package:flutter/material.dart';
import 'detector_painters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageOcr extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImageOcrState();
}

class _ImageOcrState extends State<ImageOcr> {
  PickedFile selectedImage;
  VisionText readTextResult;
  Size selectedImageSize;
  bool renderResults = true;

  File _imageFile;
  //instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  Future _selectImage() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = tempStore;
      _readText();
    });
  }

  Future _readText() async {
    if (selectedImage == null) {
      return;
    }
    FirebaseVisionImage FBImage =
        FirebaseVisionImage.fromFile(File(selectedImage.path));
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(FBImage);

    var decodedImage =
        await decodeImageFromList(File(selectedImage.path).readAsBytesSync());
    Size imageSize =
        Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    print(imageSize);

    setState(() {
      readTextResult = readText;
      selectedImageSize = imageSize;
    });

    var destText = [];
    String destLang = "pl";
    TextTranslator translator = new TextTranslator();

    await translator.init("apikey.json",
        "https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/c6b84156-6dd7-43cc-823d-719270063d12/");
    destText = await translator.translateAll(readTextResult, destLang);

    int i = 0;
    print("Translated text blocks:");
    for (String textBlock in destText) {
      print("$i. $textBlock");
      i++;
    }
  }

  Widget _resultsRenderer() {
    const Text noResultsText = Text('No results!');
    if (readTextResult == null) {
      print(noResultsText);
      return Center(
        child: noResultsText,
      );
    }
    return CustomPaint(
      painter: TextDetectorPainter(selectedImageSize, readTextResult),
    );
  }

  Future _onMenuAction(String option) async {
    if (option == MenuOptions.ReReadText) {
      _readText();
    } else if (option == MenuOptions.Copy) {
      print('Copy');
    } else if (option == MenuOptions.RenderResults) {
      setState(() {
        renderResults = !renderResults;
      });
    } else if (option == MenuOptions.GoBack) {
      Navigator.pop(context);
    } else if (option == MenuOptions.SelectImage) {
      _selectImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Translator'),
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
          child: selectedImage == null
              ? Text('No image selected.')
              : Container(
                  width: 720,
                  height: 1280,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.file(
                        File(selectedImage.path),
                        fit: BoxFit.fill,
                      ), // Bez Box Fit Fill kwadraty nie działają
                      Visibility(
                        visible: renderResults,
                        child: _resultsRenderer(),
                      ),
                    ],
                  ),
                )),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Visibility(
          child: FloatingActionButton(
            onPressed: _selectImage,
            child: Icon(Icons.add_outlined),
            heroTag: null,
          ),
          visible: selectedImage == null,
        ),
        FloatingActionButton(
          child: Icon(Icons.camera_alt_outlined),
          onPressed: () => print("Screenshot"),
          heroTag: null,
        )
      ]),
    );
  }
}

class MenuOptions {
  static const String SelectImage = 'Select Image';
  static const String ReReadText = 'ReRead Text';
  static const String RenderResults = 'Render Results';
  static const String Copy = 'Copy';
  static const String GoBack = 'Go Back';

  static const List<String> choices = <String>[
    SelectImage,
    ReReadText,
    RenderResults,
    Copy,
    GoBack
  ];
}
