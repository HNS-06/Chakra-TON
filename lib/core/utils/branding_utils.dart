import 'dart:math';
import 'package:flutter/material.dart';

class BrandingUtils {
  // Enhanced Chakra Logo with better design
  static Widget chakraLogo({double size = 100, Color color = const Color(0xFF7B61FF)}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.7),
            color.withOpacity(0.4),
          ],
          stops: const [0.1, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ChakraLogoPainter(color: color),
      ),
    );
  }

  // Simple icon version for app bars etc.
  static Widget chakraIcon({double size = 24, Color color = const Color(0xFF7B61FF)}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.star_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  // App name with styling
  static Widget appName({double fontSize = 24, Color color = Colors.white, bool withTagline = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Chakra Loyalty',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        if (withTagline) ...[
          const SizedBox(height: 4),
          tagline(fontSize: fontSize * 0.5, color: color.withOpacity(0.8)),
        ],
      ],
    );
  }

  // Tagline
  static Widget tagline({double fontSize = 14, Color color = Colors.white70}) {
    return Text(
      'TON-Powered Rewards',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }

  // Brand colors
  static const Color primaryColor = Color(0xFF7B61FF);
  static const Color secondaryColor = Color(0xFF00C6FF);
  static const Color accentColor = Color(0xFF00D2A8);
  static const Color warningColor = Color(0xFFFC466B);
  static const Color successColor = Color(0xFF00D2A8);
}

class _ChakraLogoPainter extends CustomPainter {
  final Color color;

  _ChakraLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Outer white ring
    final outerRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.9, outerRingPaint);

    // Middle colored ring
    final middleRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.7, middleRingPaint);

    // Inner white circle
    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.5, innerCirclePaint);

    // Central colored star
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    _drawStar(canvas, center, maxRadius * 0.3, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final angle = i * pi / points;
      final currentRadius = i.isEven ? radius : radius * 0.4;
      final x = center.dx + currentRadius * cos(angle - pi / 2);
      final y = center.dy + currentRadius * sin(angle - pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}