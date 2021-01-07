import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_ibm_watson/language_translator/LanguageTranslator.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';

class TextTranslator {
  String apiKey;
  String url;
  IamOptions watsonOptions;
  LanguageTranslator watsonTranslator;

  Future init(apiKeyPath, url) async {
    this.apiKey = await getAPIKey(apiKeyPath);
    this.url = url;
    this.watsonOptions =
        await IamOptions(iamApiKey: apiKey, url: this.url).build();
    this.watsonTranslator =
        new LanguageTranslator(iamOptions: this.watsonOptions);
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

    // Get rid of newlines
    processedBlockText = textBlock.replaceAll("\n", " ");
    // Escape backslashes
    processedBlockText = processedBlockText.replaceAll('\\', "\\\\");
    // Escape quotation marks
    processedBlockText = processedBlockText.replaceAll('"', "\\\"");

    return processedBlockText;
  }

  Future<String> translateTextBlock(String textBlock, String destLang) async {
    String srcTextBlock;
    IdentifyLanguageResult srcLang;
    TranslationResult destTextBlock;

    srcTextBlock = processTextBlock(textBlock);
    srcLang = await watsonTranslator.identifylanguage(srcTextBlock);
    destTextBlock = await watsonTranslator.translate(
        srcTextBlock, srcLang.toString(), destLang);

    return destTextBlock.toString();
  }

  Future<String> translateTextLine(String textLine, String destLang) async {
    String srcTextBlock;
    IdentifyLanguageResult srcLang;
    TranslationResult destTextBlock;

    srcTextBlock = processTextBlock(textLine);
    srcLang = await watsonTranslator.identifylanguage(srcTextBlock);
    destTextBlock = await watsonTranslator.translate(
        srcTextBlock, srcLang.toString(), destLang);

    if (destTextBlock.translations == null ||
        destTextBlock.translations[0]['translation'] == "null") {
      return textLine;
    } else {
      return destTextBlock.translations[0]['translation'];
    }
  }

  Future translateAll(VisionText srcText, String destLang) async {
    var destText = [];

    for (TextBlock block in srcText.blocks) {
      for (TextLine line in block.lines) {
        String destTextBlock;
        destTextBlock = await translateTextLine(line.text, destLang);
        destText.add(destTextBlock);
      }
    }

    return destText;
  }
}
