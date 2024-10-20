import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Main application widget. Demonstrates the usage of the MultiRangeSlider.
void main() {
  runApp(const MyApp());
}

// MyApp widget: Stateful widget that sets up the MaterialApp and demonstrates the MultiRangeSlider.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Example usage with price range.
                MultiRangeSlider(
                  min: 0,
                  max: 1000,
                  initialValues: [200, 800],
                  onChanged: (values) {
                    print('Price range: $values');
                  },
                  title: 'Price Range',
                  labelFormatter: (value) => '\$${value.toInt()}',
                ),
                SizedBox(height: 32),
                // Example usage with date range.
                MultiRangeSlider(
                  min: 1609459200000, // Jan 1, 2021
                  max: 1640995200000, // Jan 1, 2022
                  initialValues: [1620000000000, 1630000000000],
                  onChanged: (values) {
                    print('Date range: $values');
                  },
                  title: 'Date Range',
                  labelFormatter: (value) =>
                      DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MultiRangeSlider: A custom Flutter widget that allows the user to select multiple ranges on a slider.
class MultiRangeSlider extends StatefulWidget {
  // Minimum value of the slider.
  final double min;
  // Maximum value of the slider.
  final double max;
  // Initial values for the slider handles. Must be a list of even length.
  final List<double> initialValues;
  // Callback function triggered when the slider values change.
  final void Function(List<double>) onChanged;
  // The number of discrete divisions on the slider.
  final int divisions;
  // Color of the active range(s) on the slider.
  final Color activeColor;
  // Color of the inactive range(s) on the slider.
  final Color inactiveColor;
  // Color of the slider handles.
  final Color handleColor;
  // Function to format the labels displayed above the handles.
  final String Function(double) labelFormatter;
  // The title for the slider
  final String title;
  // Show tooltip value above handles
  final bool showTooltips;

  const MultiRangeSlider({
    Key? key,
    required this.min,
    required this.max,
    required this.initialValues,
    required this.onChanged,
    required this.title,
    this.divisions = 100,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.handleColor = Colors.white,
    this.labelFormatter = _defaultLabelFormatter,
    this.showTooltips = true,
  }) : super(key: key);

  // Default label formatter.
  static String _defaultLabelFormatter(double value) => value.toStringAsFixed(0);

  @override
  _MultiRangeSliderState createState() => _MultiRangeSliderState();
}

// _MultiRangeSliderState: Manages the state of the MultiRangeSlider widget.
class _MultiRangeSliderState extends State<MultiRangeSlider> {
  // Current values of the slider handles.
  late List<double> _values;

  @override
  void initState() {
    super.initState();
    _values = List.from(widget.initialValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title of the slider
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        // Slider
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              // Update slider values on pan update.
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                var position = renderBox.globalToLocal(details.globalPosition);
                _updateClosestValue(position.dx / constraints.maxWidth);
              },
              child: CustomPaint(
                size: Size(constraints.maxWidth, 48),
                // Custom painter for drawing the slider.
                painter: _SliderPainter(
                  min: widget.min,
                  max: widget.max,
                  values: _values,
                  activeColor: widget.activeColor,
                  inactiveColor: widget.inactiveColor,
                  handleColor: widget.handleColor,
                  labelFormatter: widget.labelFormatter,
                  showTooltips: widget.showTooltips,
                ),
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Labels for min and max values
            children: [
              Text(widget.labelFormatter(widget.min)),
              Text(widget.labelFormatter(widget.max)),
            ],
          ),
        ),
      ],
    );
  }

  // Updates the closest slider value based on the given position.
  void _updateClosestValue(double position) {
    double valuePosition = widget.min + (widget.max - widget.min) * position;
    int closestIndex = 0;
    double minDifference = double.infinity;

    for (int i = 0; i < _values.length; i++) {
      double difference = (_values[i] - valuePosition).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
      }
    }

    setState(() {
      _values[closestIndex] = valuePosition.clamp(widget.min, widget.max);
      _values.sort();
    });

    widget.onChanged(_values);
  }
}
// _SliderPainter: Custom painter for drawing the MultiRangeSlider.
class _SliderPainter extends CustomPainter {
  // Minimum value of the slider.
  final double min;
  // Maximum value of the slider.
  final double max;
  // Current values of the slider handles.
  final List<double> values;
  // Color of the active range(s) on the slider.
  final Color activeColor;
  // Color of the inactive range(s) on the slider.
  final Color inactiveColor;
  // Color of the slider handles.
  final Color handleColor;
  // Function to format the labels displayed above the handles.
  final String Function(double) labelFormatter;
  // Show tooltip value above handles
  final bool showTooltips;


  _SliderPainter({
    required this.min,
    required this.max,
    required this.values,
    required this.activeColor,
    required this.inactiveColor,
    required this.handleColor,
    required this.labelFormatter,
    required this.showTooltips,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint object for drawing.
    final paint = Paint()
      ..color = inactiveColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    // Draw inactive track.
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw active ranges.
    paint.color = activeColor;
    for (int i = 0; i < values.length - 1; i += 2) {
      double start = (values[i] - min) / (max - min) * size.width;
      double end = (values[i + 1] - min) / (max - min) * size.width;
      canvas.drawLine(
        Offset(start, size.height / 2),
        Offset(end, size.height / 2),
        paint,
      );
    }

    // Draw handles and tooltips.
    paint.color = handleColor;
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (double value in values) {
      double position = (value - min) / (max - min) * size.width;
      // Draw handle with multiple circles for better visibility
      canvas.drawCircle(
        Offset(position, size.height / 2),
        12,
        paint,
      );
      paint.color = Colors.grey;
      canvas.drawCircle(
        Offset(position, size.height / 2),
        10,
        paint,
      );
      paint.color = handleColor;
      canvas.drawCircle(
        Offset(position, size.height / 2),
        8,
        paint,
      );

      if (showTooltips) {
        _drawTooltip(canvas, position, size.height / 2 - 30, labelFormatter(value), textPainter);
      }
    }
  }


// Draws a tooltip above the slider handle.
  void _drawTooltip(Canvas canvas, double x, double y, String text, TextPainter textPainter) {
    const tooltipHeight = 28.0;
    const tooltipWidth = 60.0;
    final tooltipRect = Rect.fromCenter(
      center: Offset(x, y),
      width: tooltipWidth,
      height: tooltipHeight,
    );

    // Draw tooltip background.
    canvas.drawRRect(
      RRect.fromRectAndRadius(tooltipRect, Radius.circular(8)),
      Paint()..color = Colors.black87,
    );

    // Draw tooltip text.
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout(minWidth: 0, maxWidth: tooltipWidth);
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
