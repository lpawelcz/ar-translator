import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

// Paints rectangles around all the text in the image.
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
      this.absoluteImageSize, this.visionText, this.isTextInTranslator);

  TextDetectorPainter.formTextDetectorPainter(this.absoluteImageSize,
      this.visionText, this.isTextInTranslator, this.translatedText);

  final Size absoluteImageSize;
  final VisionText visionText;
  List<dynamic> translatedText;
  final bool isTextInTranslator;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX - 10,
        container.boundingBox.top * scaleY - 10,
        container.boundingBox.right * scaleX + 10,
        container.boundingBox.bottom * scaleY + 10,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        paint.color = Colors.white;
        canvas.drawRect(scaleRect(line), paint);
      }
    }

    int i = 0;
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        String translatedTextLine = line.text;
        var len = (scaleRect(line).right - scaleRect(line).left).toInt();
        var charAm = line.text.length;
        var fonS = (len / charAm + 5).toDouble();

        if (translatedText != null && translatedText.isNotEmpty) {
          charAm = line.text.length.toInt();
          translatedTextLine = translatedText[i].toString();
        }

        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: fonS.toDouble(),
        );

        final textSpan = TextSpan(
          text: translatedTextLine,
          style: textStyle,
        );

        i = i + 1;

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: block.boundingBox.width,
        );
        final offset = Offset(
            line.boundingBox.left * scaleX - 4, line.boundingBox.top * scaleY);
        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    TextBlock tb = visionText.blocks[0];
    TextLine tl = tb.lines[0];
    TextBlock tb2 = oldDelegate.visionText.blocks[0];
    TextLine tl2 = tb2.lines[0];

    if (translatedText != null) {
      bool warunek = translatedText.isEmpty;
      if (!warunek) {
        if (tl.boundingBox.left > tl2.boundingBox.left + 72 ||
            tl.boundingBox.left < tl2.boundingBox.left - 72) {
          return true;
        } else {
          return oldDelegate.translatedText != translatedText;
        }
      } else {
        if (tl.boundingBox.left > tl2.boundingBox.left + 72 ||
            tl.boundingBox.left < tl2.boundingBox.left - 72) {
          return true;
        } else {
          return false;
        }
        return false;
      }
    } else {
      if (tl.boundingBox.left > tl2.boundingBox.left + 72 ||
          tl.boundingBox.left < tl2.boundingBox.left - 72) {
        return true;
      } else {
        return false;
      }
      return false;
    }
  }
}
