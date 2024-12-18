import 'package:flutter/material.dart';
import 'dart:math';

class RobotWidget extends StatelessWidget {
  const RobotWidget({super.key});
  final int n = 12;
  final double radius = 300;
  final double smallCircleRadius = 35;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final position = details.localPosition;
        final center =
            Offset(context.size!.width / 2, context.size!.height / 2);

        // Calculate which circle was clicked
        for (int i = 0; i < n; i++) {
          double angle = (2 * pi / n) * i;
          double x = center.dx + radius * cos(angle);
          double y = center.dy + radius * sin(angle);

          // Check if the tap is inside the circle
          if ((position.dx - x).abs() <= smallCircleRadius &&
              (position.dy - y).abs() <= smallCircleRadius) {
            print("Circle $i clicked!");
            break;
          }
        }
      },
      child: CustomPaint(
          size: Size(radius * 2, radius * 2),
          painter: SvgPainter(n, radius, smallCircleRadius)),
    );
  }
}

class SvgPainter extends CustomPainter {
  final int n;
  final double radius;
  final double smallCircleRadius;

  const SvgPainter(this.n, this.radius, this.smallCircleRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final center = Offset(size.width / 2, size.height / 2);
    const selected = 1;

    // Draw the outer circle
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;

    canvas.drawCircle(center, radius, paint);

    // Draw the smaller circles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      double angle = (2 * pi / n) * i;
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);

      if (i == selected) {
        paint.color = Colors.green;
        paint.strokeWidth = 5;
      }

      paint.color = Colors.red;
      canvas.drawCircle(Offset(x, y), smallCircleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
