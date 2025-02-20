import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(DrawingApp());
}

class DrawingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DrawingScreen(),
    );
  }
}

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<Offset?> _points = <Offset?>[];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Drawing App'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: _pickColor,
          ),
          IconButton(
            icon: Icon(Icons.brush),
            onPressed: _pickStrokeWidth,
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            _points.add(renderBox.globalToLocal(details.localPosition));
          });
        },
        onPanEnd: (details) {
          _points.add(null);
        },
        child: CustomPaint(
          painter: DrawingPainter(_points, _selectedColor, _strokeWidth),
          child: Container(),
        ),
      ),
    );
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _pickStrokeWidth() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick stroke width'),
          content: Slider(
            value: _strokeWidth,
            min: 1.0,
            max: 20.0,
            onChanged: (value) {
              setState(() {
                _strokeWidth = value;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  DrawingPainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  ColorPicker({required this.pickerColor, required this.onColorChanged});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _currentColor.red.toDouble(),
          min: 0.0,
          max: 255.0,
          onChanged: (value) {
            setState(() {
              _currentColor = Color.fromARGB(
                _currentColor.alpha,
                value.toInt(),
                _currentColor.green,
                _currentColor.blue,
              );
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        Slider(
          value: _currentColor.green.toDouble(),
          min: 0.0,
          max: 255.0,
          onChanged: (value) {
            setState(() {
              _currentColor = Color.fromARGB(
                _currentColor.alpha,
                _currentColor.red,
                value.toInt(),
                _currentColor.blue,
              );
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        Slider(
          value: _currentColor.blue.toDouble(),
          min: 0.0,
          max: 255.0,
          onChanged: (value) {
            setState(() {
              _currentColor = Color.fromARGB(
                _currentColor.alpha,
                _currentColor.red,
                _currentColor.green,
                value.toInt(),
              );
              widget.onColorChanged(_currentColor);
            });
          },
        ),
      ],
    );
  }
}
