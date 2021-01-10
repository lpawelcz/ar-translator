import 'dart:io';
import 'package:ar_translator/translation/text-transl.dart';
import 'package:flutter/material.dart';
import 'detector_painters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:clipboard/clipboard.dart';

class ImageOcr extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImageOcrState();
}

class _ImageOcrState extends State<ImageOcr> {
  PickedFile selectedImage;
  VisionText readTextResult;
  List<dynamic> translatedText;
  Size selectedImageSize;
  bool renderResults = true;
  bool isTextInTranslator = false;

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


    var destText = [];
    String destLang = "pl";
    TextTranslator translator = new TextTranslator();

    await translator.init("apikey.json",
        "https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/c6b84156-6dd7-43cc-823d-719270063d12/");
    destText = await translator.translateAll(readText, destLang);

    int i = 0;
    print("Translated text blocks:");
    for (String textBlock in destText) {
      print("$i. $textBlock");
      i++;
    }

    setState(() {
      readTextResult = readText;
      selectedImageSize = imageSize;
      translatedText = destText;
      isTextInTranslator = true;
    });
  }

  Widget _resultsRenderer() {
    const Text noResultsText = Text('No results!');
    if (readTextResult == null) {
      print(noResultsText);
      return Center(
        child: noResultsText,
      );
    }
    if (translatedText == null) {
      return CustomPaint(
        painter: TextDetectorPainter(
            selectedImageSize, readTextResult, isTextInTranslator),
      );
    } else {
      return CustomPaint(
        painter: TextDetectorPainter.formTextDetectorPainter(selectedImageSize,
            readTextResult, isTextInTranslator, translatedText),
      );
    }
  }

  Future _onMenuAction(String option) async {
    if (option == MenuOptions.ReReadText) {
      _readText();
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

  void _takeScreenshot() async {
    String imgPath = await NativeScreenshot.takeScreenshot();
  }

  void _copyClipboard(BuildContext context) {
    String wholeTranslatedText = "";

    for (String textBlock in translatedText) {
      wholeTranslatedText += textBlock + " ";
    }

    FlutterClipboard.copy(wholeTranslatedText).then((result) {
      final snackBar = SnackBar(
        content: Text('Copied to Clipboard'),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
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
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            child: FloatingActionButton(
              onPressed: _selectImage,
              child: Icon(Icons.add_outlined),
              heroTag: null,
            ),
            visible: selectedImage == null,
          ),
          SizedBox(height: 7),
          Builder(
          builder: (context) {
             return Column(
                children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.save_outlined),
                  heroTag: null,
                  onPressed: () => _copyClipboard(context),
                ),
                ],
              );
          },
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
  static const String SelectImage = 'Select Image';
  static const String ReReadText = 'ReRead Text';
  static const String RenderResults = 'Render Results';
  static const String GoBack = 'Go Back';

  static const List<String> choices = <String>[
    SelectImage,
    ReReadText,
    RenderResults,
    GoBack
  ];
}
