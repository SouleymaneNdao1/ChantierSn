// widgets/ann_painter.dart — ChantierSN
// CustomPainter : anneau de progression circulaire (sans package externe)

import 'package:flutter/material.dart';

class AnnPainter extends CustomPainter {
  final double valeur; // 0.0 à 1.0
  final Color couleur;
  const AnnPainter(this.valeur, this.couleur);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 6;

    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -3.14159 / 2,
      2 * 3.14159 * valeur,
      false,
      Paint()
        ..color = couleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(AnnPainter old) => old.valeur != valeur;
}
