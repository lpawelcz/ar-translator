import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======

>>>>>>> adfbecc86a5b7a10a1a5507768d83358f7e2f7a8

// Paints rectangles around all the text in the image.
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.visionText);

  final Size absoluteImageSize;
  final VisionText visionText;

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
        for (TextElement element in line.elements) {
          paint.color = Colors.green;
          canvas.drawRect(scaleRect(element), paint);
        }

<<<<<<< HEAD
        var len = (scaleRect(line).right - scaleRect(line).left).toInt();
        var charAm = line.text.length.toInt();
        var fonS = (len / charAm + 5).toDouble();
        print("@#@ ilość znaków: " +
            charAm.toString() +
            " : długość prostokąta: " +
            len.toString() +
            " font: " +
            fonS.toString());

        paint.color = Colors.white;
        canvas.drawRect(scaleRect(line), paint);
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: fonS.toDouble(),
        );

        print("### " + block.text);
        final textSpan = TextSpan(
          text: line.text,
          style: textStyle,
        );

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
            block.boundingBox.left * scaleX, block.boundingBox.top * scaleY);
        textPainter.paint(canvas, offset);
        print("@### " + offset.toString());
      }
      // paint.color = Colors.white;
      // canvas.drawRect(scaleRect(block), paint);

=======
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 15,
      );

      final textSpan = TextSpan(
        text: block.text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: block.boundingBox.width,
      );
      final offset = Offset(block.boundingBox.left * scaleX , block.boundingBox.top * scaleY);
      textPainter.paint(canvas, offset);

>>>>>>> adfbecc86a5b7a10a1a5507768d83358f7e2f7a8
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.visionText != visionText;
  }
}
