import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

// Paints rectangles around all the text in the image.
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
      this.absoluteImageSize, this.visionText, this.translatedText);

  final Size absoluteImageSize;
  final VisionText visionText;
  final List<dynamic> translatedText;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    print(size.width.toString() + " " + absoluteImageSize.width.toString());
    print(size.height.toString() + " " + absoluteImageSize.height.toString());

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
    // int i = 0;
    // print("@@@ testowanko tłumaczenia :");
    // for (String textBlock in translatedText) {
    //   print("$i. $textBlock");
    //   i++;
    // }

    int i = 0;
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        String translatedTextLine = translatedText[i];
        var len = (scaleRect(line).right - scaleRect(line).left).toInt();
        var charAm = translatedTextLine.length.toInt();
        // var charAm = translatedText[i].length.toInt();
        var fonS = (len / charAm + 5).toDouble();
        print("@#@ ilość znaków: " +
            charAm.toString() +
            " : długość prostokąta: " +
            len.toString() +
            " font: " +
            fonS.toString());

        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: fonS.toDouble(),
        );

        print("### " + block.text);
        final textSpan = TextSpan(
          // text: line.text,
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
            line.boundingBox.left * scaleX, line.boundingBox.top * scaleY);
        textPainter.paint(canvas, offset);
        print("@### " + offset.toString());
        print("@### " + line.text);
      }
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.visionText != visionText;
  }
}
