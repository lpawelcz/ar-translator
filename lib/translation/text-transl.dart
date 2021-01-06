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

class TextTransl {
  String apiKey;
  String url;
  IamOptions watsonOptions;
  LanguageTranslator watsonTranslator;

  TextTransl(String apiKeyPath, String url) {
    init(apiKeyPath, url);
    print("after init");
  }

  Future init(apiKeyPath, url) async {
    this.apiKey = await getAPIKey(apiKeyPath);
    print("got API Key: ${this.apiKey}");
    this.url = url;
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

  Future<String> translateTextBlock(String textBlock, String destLang) async {
    String srcTextBlock;
    IdentifyLanguageResult srcLang;
    TranslationResult destTextBlock;

    print("raw text block: $textBlock");
    srcTextBlock = processTextBlock(textBlock);
    print("processed text block: $srcTextBlock");
    //srcLang = await watsonTranslator.identifylanguage(srcTextBlock);
    print("srcLang: $srcLang");
    //destTextBlock = await watsonTranslator.translate(srcTextBlock, srcLang.toString(), destLang);
    destTextBlock = await watsonTranslator.translate(srcTextBlock, "en", destLang);
    print("destTextBlock: $destTextBlock");

    return destTextBlock.toString();
  }

  translateAll(VisionText srcText, String destLang) {
    var destText = [];

    print("whole text:");
    for (TextBlock block in srcText.blocks) {
      Future <String> destTextBlock;
      destTextBlock = translateTextBlock(block.text, destLang);
      destText.add(destTextBlock);
    }
  }

}