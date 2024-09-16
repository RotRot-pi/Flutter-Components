import 'dart:ui';

import 'package:color_palette_from_image/product_list.dart';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class Product {
  final String name;
  final String imagePath;

  Product({required this.name, required this.imagePath});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Product> products = [
    Product(name: 'White Sneakers', imagePath: 'assets/white-sneakers.jpg'),
    Product(name: 'Red Sneakers', imagePath: 'assets/red-sneakers.jpg'),
    Product(name: 'Yellow Sneakers', imagePath: 'assets/yellow-sneakers.jpg'),
    Product(name: 'Black Sneakers', imagePath: 'assets/black-sneakers.jpg'),
    // Add more products here
  ];
  bool isLoading = true;
  int currentPage = 0;
  final List<PaletteColor> _palettes = [];

  @override
  void initState() {
    super.initState();
    _generatePalettes();
  }

  _generatePalettes() async {
    for (var product in products) {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
        AssetImage(product.imagePath),
        size: const Size(200, 200),
      );
      _palettes.add(generator.dominantColor ?? generator.dominantColor!);
    }
    isLoading = false;
    setState(() {});
  }

  _handlePageChange(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Material(child: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              title: Text(
                widget.title,
              ),
              backgroundColor: _palettes[currentPage].color,
              centerTitle: true,
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: _palettes[currentPage].color.withOpacity(0.3)),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: AnimatedOpacity(
                      opacity: _palettes.isNotEmpty
                          ? 1.0
                          : 0.0, // Show when palette is generated
                      duration: const Duration(milliseconds: 300),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            width: 300,
                            height: 400,
                            decoration: BoxDecoration(
                              color:
                                  _palettes[currentPage].color.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _palettes[currentPage]
                                    .color
                                    .withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              products[currentPage].imagePath,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              cacheHeight: 400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Product List (PageView)
                ProductList(
                  products: products,
                  onPageChanged: _handlePageChange,
                ),
              ],
            ),
          );
  }
}
