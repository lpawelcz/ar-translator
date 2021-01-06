import 'dart:io';

import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:ar_translator/translation/text-transl.dart';
import 'package:flutter/material.dart';
import 'detector_painters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutter_ibm_watson/language_translator/LanguageTranslator.dart';
import 'package:flutter_ibm_watson/utils/Language.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';

class ImageOcr extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImageOcrState();
}

class _ImageOcrState extends State<ImageOcr> {
  PickedFile selectedImage;
  VisionText readTextResult;
  Size selectedImageSize;
  bool renderResults = true;
  final LanguageIdentifier languageIdentifier = FirebaseLanguage.instance.languageIdentifier();
  final LanguageTranslator plToEng = FirebaseLanguage.instance.languageTranslator(SupportedLanguages.Polish, SupportedLanguages.English);


  Future selectImage() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = tempStore;
      readText();
    });
  }

  Future readText() async {
    if(selectedImage==null){
      return;
    }
    FirebaseVisionImage FBImage = FirebaseVisionImage.fromFile(File(selectedImage.path));
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(FBImage);

    var decodedImage = await decodeImageFromList(File(selectedImage.path).readAsBytesSync());
    Size imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    print(imageSize);

    setState(() {
      readTextResult = readText;
      selectedImageSize = imageSize;
    });

    TextTransl translator = new TextTransl("apikey.json", "https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/c6b84156-6dd7-43cc-823d-719270063d12/", readTextResult, "pl");

/*
    IamOptions options = await IamOptions(iamApiKey: "vkXBrIrcqFyoG5W98eAKpjrlhCtrSzbmAm-blnF8Sgyh", url: "https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/c6b84156-6dd7-43cc-823d-719270063d12/").build();
    LanguageTranslator service = new LanguageTranslator(iamOptions: options);

    var destText = [];
    var srcRawText = [];
    var srcProcessedText = [];
    var srcLang = [];

    for (TextBlock block in readText.blocks) {
      String rawBlockText = block.text;
      String processedBlockText = block.text.replaceAll("\n", " ");
      processedBlockText = processedBlockText.replaceAll('"', "\\\"");
      IdentifyLanguageResult identifyLanguageResult = await service.identifylanguage(processedBlockText);
      TranslationResult translationResults = await service.translate(processedBlockText, identifyLanguageResult.toString(), Language.POLISH);
      destText.add(translationResults.toString());
      srcRawText.add(rawBlockText);
      srcProcessedText.add(processedBlockText);
      srcLang.add(identifyLanguageResult);
    }

    print("All together now:");
    int i = 0;
    for (String translation in destText) {
      print("Raw source blockText: ${srcRawText[i]}");
      print("Processed source blockText: ${srcProcessedText[i]}");
      print("Source language: ${srcLang[i]}");
      print("Destination blockText: ${destText[i]}");
      i++;
    }
    */

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        final List<LanguageLabel> labels = await languageIdentifier.processText(line.text);
        for (LanguageLabel label in labels) {
          final String lngcode = label.languageCode;
          final double confidence = label.confidence;
          print(line.text + " --- " + lngcode.toString() + " || " + confidence.toString());
          if(lngcode != "und"){
            var transl = await plToEng.processText(line.text);
            print("TRANSLATED: " + transl.toString());
          }
        }
      }
    }
  }


  Widget _resultsRenderer() {
    const Text noResultsText = Text('No results!');
    if (readTextResult == null) {
      print(noResultsText);
      return noResultsText;
    }
    return CustomPaint(
      painter: TextDetectorPainter(selectedImageSize, readTextResult),
    );
  }

  Future onMenuAction(String option) async {
    if(option == MenuOptions.ReReadText){
      readText();
    }else if(option == MenuOptions.Copy){
      print('Copy');
    }else if(option == MenuOptions.RenderResults){
      setState(() {
        renderResults = !renderResults;
      });
    }else if(option == MenuOptions.GoBack){
      Navigator.pop(context);
    }else if(option == MenuOptions.SelectImage){
      selectImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Photo Translator'),
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: onMenuAction,
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
          child: selectedImage == null
              ? Text('No image selected.')
              : Container(
              width: 720,
              height: 1280,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(File(selectedImage.path),fit: BoxFit.fill,) , // Bez Box Fit Fill kwadraty nie działają
                  Visibility(
                    visible: renderResults,
                    child: _resultsRenderer(),
                  ),
                ],
              ),
            )
        ),
        floatingActionButton: Visibility(
          child: FloatingActionButton(
            onPressed: selectImage,
            child: Icon(Icons.add_outlined),
          ),
          visible: selectedImage==null,
        ),
    );
  }
}

class MenuOptions{
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