import 'package:flutter/material.dart';
import 'colors.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _activeIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 320,
        height: 60,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(0, Icons.home),
            _buildIconButton(1, Icons.search_outlined),
            _buildIconButton(2, Icons.trending_up),
            _buildIconButton(3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(int index, IconData icon) {
    return Container(
      width: 50,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: _activeIndex == index ? Colors.white : Colors.transparent,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onItemTapped(index),
        icon: Icon(
          icon,
          size: 25,
          color: _activeIndex == index ? primaryColor : Colors.white,
        ),
      ),
    );
  }
}
