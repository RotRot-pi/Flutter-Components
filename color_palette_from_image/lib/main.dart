import 'package:color_palette_from_image/view_sneakers.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// The main Application class.
class MyApp extends StatelessWidget {
  /// Creates the main Application class.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Colors',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(
        title: 'Home',
      ),
    );
  }
}
