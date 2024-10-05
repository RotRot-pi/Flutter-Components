import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: MultiSegmentGauge(
          title: 'Project Progress',
          segments: [
            GaugeSegment(
              label: 'Design',
              progress: 35,
              color: Colors.blue,
            ),
            GaugeSegment(
              label: 'Development',
              progress: 45,
              color: Colors.green,
            ),
            GaugeSegment(
              label: 'Testing',
              progress: 20,
              color: Colors.orange,
            ),
          ],
        )),
      ),
    );
  }
}

class MultiSegmentGauge extends StatefulWidget {
  final List<GaugeSegment> segments;
  final double radius;
  final double strokeWidth;
  final String title;

  const MultiSegmentGauge({
    super.key,
    required this.segments,
    required this.title,
    this.radius = 150,
    this.strokeWidth = 25,
  });

  @override
  State<MultiSegmentGauge> createState() => _MultiSegmentGaugeState();
}

class _MultiSegmentGaugeState extends State<MultiSegmentGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    _animations = widget.segments.map((segment) {
      return Tween<double>(
        begin: 0,
        end: segment.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.radius * 2, widget.radius * 2),
          painter: GaugePainter(
            segments: widget.segments,
            animations: _animations,
            strokeWidth: widget.strokeWidth,
            title: widget.title,
          ),
        );
      },
    );
  }
}

class GaugePainter extends CustomPainter {
  final List<GaugeSegment> segments;
  final List<Animation<double>> animations;
  final double strokeWidth;
  final String title;

  GaugePainter({
    required this.segments,
    required this.animations,
    required this.strokeWidth,
    required this.title,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circles
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -pi / 2; // Start from top

    // Draw segments
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = 2 * pi * (animations[i].value / 100);

      final paint = Paint()
        ..color = segment.color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Draw segment label
      if (animations[i].value > 0) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius - strokeWidth / 2;
        final labelCenter = Offset(
          center.dx + labelRadius * cos(labelAngle),
          center.dy + labelRadius * sin(labelAngle),
        );

        // Draw label background
        final labelBgPaint = Paint()
          ..color = Colors.white.withOpacity(0.85)
          ..style = PaintingStyle.fill;

//         final labelText = '${animations[i].value.toStringAsFixed(1)}%\n${segment.label}';
        final textPainter = TextPainter(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${animations[i].value.toStringAsFixed(1)}%\n',
                style: TextStyle(
                  color: segment.color,
                  fontSize: radius / 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: segment.label,
                style: TextStyle(
                  color: segment.color.withOpacity(0.8),
                  fontSize: radius / 14,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(minWidth: 0, maxWidth: strokeWidth * 2);

        final labelRect = Rect.fromCenter(
          center: labelCenter,
          width: textPainter.width + 16,
          height: textPainter.height + 8,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
          labelBgPaint,
        );

        textPainter.paint(
          canvas,
          labelCenter.translate(
              -textPainter.width / 2, -textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }

    // Draw title in center
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: radius / 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    titlePainter.layout(maxWidth: radius);
    titlePainter.paint(
      canvas,
      center.translate(-titlePainter.width / 2, -titlePainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return true;
  }
}

class GaugeSegment {
  final String label;
  final double progress;
  final Color color;

  GaugeSegment({
    required this.label,
    required this.progress,
    required this.color,
  });
}
