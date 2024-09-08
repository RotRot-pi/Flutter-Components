import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Expandable Card Example',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: ExpandableCard(),
        ),
      ),
    );
  }
}

class ExpandableCard extends StatefulWidget {
  const ExpandableCard({super.key});

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Image.asset('assets/product.png', fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? 200 : 75,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFe99d90),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Product Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: AnimatedOpacity(
                    opacity: isExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nisl vitae fermentum feugiat, nunc justo dignissim ligula, ac sagittis nisl tellus id magna.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
