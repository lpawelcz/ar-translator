import 'dart:convert' show json;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:ar_translator/translation/text-transl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutter_ibm_watson/language_translator/LanguageTranslator.dart';
import 'package:flutter_ibm_watson/utils/Language.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';

class TextTransl extends StatefulWidget {
  String apiKeyPath;
  String url;
  VisionText srcText;
  String destLang;

  TextTransl(String apiKeyPath, String url, VisionText srcText, String destLang) {
    this.apiKeyPath = apiKeyPath;
    this.url = url;
    this.srcText = srcText;
    this.destLang = destLang;
    print("TextTransl constructor");
  }

  @override
  State<StatefulWidget> createState() => _TextTranslState();
}

class _TextTranslState extends State<TextTransl>{
  String apiKey;
  String url;
  IamOptions watsonOptions;
  LanguageTranslator watsonTranslator;

  _TextTranslState() {
    print("_TextTranslState constructor");
    getAPIKey(widget.apiKeyPath).then((String apiKeyS) {
      setState(() {
        this.apiKey = apiKeyS;
      });
    });
    print("got API Key: $apiKey");
    this.url = url;
    init(this.apiKey, this.url);
    print("after init");

    setState(() {
      print("begin translate all");
      translateAll(widget.srcText, widget.destLang);
      print("end translate all");
    });
  }

  Future init(apiKey, url) async {
    this.watsonOptions = await IamOptions(iamApiKey: apiKey, url: url).build();
    this.watsonTranslator = new LanguageTranslator(iamOptions: this.watsonOptions);
  }

  Future<String> getJson(apiKeyJsonPath) {
    return rootBundle.loadString(apiKeyJsonPath);
  }

  Future<String> getAPIKey(apiKeyPath) async {
    var apiKeyJSON = json.decode(await getJson(apiKeyPath));
    var apiKey = apiKeyJSON["apikey"];
    return apiKey;
  }

  String processTextBlock(String textBlock) {
    String processedBlockText;

    processedBlockText = textBlock.replaceAll("\n", " ");
    processedBlockText = processedBlockText.replaceAll('"', "\\\"");

    return processedBlockText;
  }

  /*
  Future<String> indentifyLanguage(String textBlock) async {
    IdentifyLanguageResult identifyLanguageResult;

    identifyLanguageResult = await watsonTranslator.identifylanguage(textBlock);

    return identifyLanguageResult.toString();
  }
  */

  Future<String> translateTextBlock(String textBlock, String destLang) async {
    String srcTextBlock;
    IdentifyLanguageResult srcLang;
    TranslationResult destTextBlock;

    srcTextBlock = processTextBlock(textBlock);
    srcLang = await watsonTranslator.identifylanguage(textBlock);
    destTextBlock = await watsonTranslator.translate(srcTextBlock, srcLang.toString(), destLang);

    return destTextBlock.toString();
  }

  translateAll(VisionText srcText, String destLang) {
    var destText = [];

    print("whole text:");
    for (TextBlock block in srcText.blocks) {
      Future <String> destTextBlock;
      destTextBlock = translateTextBlock(block.text, destLang);
      destText.add(destTextBlock);
      print(destTextBlock);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _TextTranslState(),
        ),
    );
  }

}