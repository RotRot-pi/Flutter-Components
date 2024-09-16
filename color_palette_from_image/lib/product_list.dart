import 'package:color_palette_from_image/product_card.dart';
import 'package:color_palette_from_image/view_sneakers.dart';
import 'package:flutter/material.dart';

class ProductList extends StatefulWidget {
  const ProductList({
    super.key,
    required this.products,
    this.onPageChanged,
  });
  final List<Product> products;
  final void Function(int)? onPageChanged;
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  int currentPage = 0;
  late PageController _pageController;
  @override
  void initState() {
    _pageController = PageController(
      initialPage: currentPage,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 225,
        width: 300,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {
            widget.onPageChanged?.call(index);
          },
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: widget.products[index]);
          },
        ),
      ),
    );
  }
}
