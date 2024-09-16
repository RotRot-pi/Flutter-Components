import 'dart:ui';

import 'package:color_palette_from_image/view_sneakers.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
              aspectRatio: 16 / 9,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Image.asset(
                  product.imagePath,
                  height: 150,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  cacheHeight: 150,
                ),
              )),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
