import 'package:flutter/material.dart';

void main() => runApp(const CreditCardApp());

class CreditCardApp extends StatelessWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Credit Card Input'),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: CreditCardForm(),
        ),
      ),
    );
  }
}

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({super.key});

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _isBackVisible = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set up the animation controller for card flip
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_isBackVisible) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isBackVisible = !_isBackVisible;
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardHolderNameController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Widget _buildCreditCard(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159;
        final isBackVisible = angle > 1.5708;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: GestureDetector(
            onTap: _flipCard,
            child: isBackVisible
                ? _buildBackSide(context)
                : _buildFrontSide(context),
          ),
        );
      },
    );
  }

  Widget _buildFrontSide(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple,
      child: Container(
        width: 300,
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credit Card',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 30),
            Text(
              _cardNumberController.text.isEmpty
                  ? '**** **** **** ****'
                  : _formatCardNumber(_cardNumberController.text),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Holder',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _cardHolderNameController.text.isEmpty
                          ? 'YOUR NAME'
                          : _cardHolderNameController.text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _expiryDateController.text.isEmpty
                          ? 'MM/YY'
                          : _expiryDateController.text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackSide(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple,
      child: Container(
        width: 300,
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            Transform.flip(
              flipX: true,
              child: const Text(
                'CVV',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const Spacer(),
            Transform.flip(
              flipX: true,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _cvvController.text.isEmpty ? '***' : _cvvController.text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String input) {
    input = input.replaceAll(' ', '');
    return input.replaceAllMapped(
        RegExp(r".{1,4}"), (match) => "${match.group(0)} ");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCreditCard(context),
          const SizedBox(height: 30),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Card Number',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            maxLength: 19, // 16 digits + 3 spaces
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _expiryDateController,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              hintText: 'Expiry Date (MM/YY)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            maxLength: 5, // MM/YY format
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cardHolderNameController,
            decoration: const InputDecoration(
              hintText: 'Card Holder Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cvvController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'CVV',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            maxLength: 3,
            onTap: () {
              _flipCard();
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
