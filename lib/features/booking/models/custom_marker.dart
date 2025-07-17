import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarker {
  /// Creates a pill-shaped marker with the given text
  /// Returns a [BitmapDescriptor] that can be used as a custom marker icon
  static Future<BitmapDescriptor> createPillMarker(String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Measure text first to determine size
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Calculate pill dimensions based on text
    const padding = 16.0;
    const pinHeight = 20.0;
    final pillWidth = textPainter.width + (padding * 2);
    final pillHeight = textPainter.height + 16.0;
    final totalHeight = pillHeight + pinHeight;
    final totalWidth = pillWidth;
    
    // Draw pill background
    final pillPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, pillWidth, pillHeight),
      Radius.circular(pillHeight / 2),
    );
    canvas.drawRRect(pillRect, pillPaint);
    
    // Draw pin/pointer at bottom center
    final pinPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    
    final pinPath = Path();
    final pinCenterX = pillWidth / 2;
    pinPath.moveTo(pinCenterX - 8, pillHeight);
    pinPath.lineTo(pinCenterX + 8, pillHeight);
    pinPath.lineTo(pinCenterX, pillHeight + pinHeight);
    pinPath.close();
    canvas.drawPath(pinPath, pinPaint);
    
    // Draw text
    textPainter.paint(
      canvas,
      Offset((pillWidth - textPainter.width) / 2, (pillHeight - textPainter.height) / 2),
    );
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Creates a circular marker with the given color and text
  static Future<BitmapDescriptor> createCircleMarker(Color color, String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Creates a square marker with the given color and text
  static Future<BitmapDescriptor> createSquareMarker(Color color, String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size - 8, size - 8),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRRect(rect, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
