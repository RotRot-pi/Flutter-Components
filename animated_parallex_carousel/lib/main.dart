import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class ParallaxCarouselItem {
  final String imageUrl;
  final String title;
  final String description;
  final List<String> tags;
  final VoidCallback? onActionButtonPressed;

  ParallaxCarouselItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    this.tags = const [],
    this.onActionButtonPressed,
  });
}

class CarouselTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle tagStyle;

  const CarouselTheme({
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.accentColor = Colors.blue,
    this.titleStyle =
        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    this.descriptionStyle = const TextStyle(fontSize: 16),
    this.tagStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  });
}

class AnimatedParallaxCarousel extends StatefulWidget {
  final List<ParallaxCarouselItem> items;
  final double height;
  final Duration autoScrollDuration;
  final Curve transitionCurve;
  final CarouselTheme theme;

  const AnimatedParallaxCarousel({
    super.key,
    required this.items,
    this.height = 200,
    this.autoScrollDuration = const Duration(seconds: 5),
    this.transitionCurve = Curves.easeInOut,
    this.theme = const CarouselTheme(),
  });

  @override
  State<AnimatedParallaxCarousel> createState() =>
      _AnimatedParallaxCarouselState();
}

class _AnimatedParallaxCarouselState extends State<AnimatedParallaxCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  double _currentPage = 0;
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    _pageController.addListener(_onScroll);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _currentPage = _pageController.page!;
    });
  }

  void _startAutoScroll() {
    Future.delayed(widget.autoScrollDuration, () {
      if (_isAutoScrolling && mounted) {
        final nextPage = (_currentPage + 1) % widget.items.length;
        _pageController.animateToPage(
          nextPage.toInt(),
          duration: const Duration(milliseconds: 800),
          curve: widget.transitionCurve,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            onPanDown: (_) => _isAutoScrolling = false,
            onPanCancel: () => _isAutoScrolling = true,
            onPanEnd: (_) => _isAutoScrolling = true,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page ?? 0) - index;
                      value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * widget.height,
                        child: child,
                      ),
                    );
                  },
                  child: _CarouselCard(
                    item: widget.items[index],
                    onTap: () => _showExpandedCard(context, index),
                    theme: widget.theme,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: _buildPageIndicator(),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.items.asMap().entries.map((entry) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.theme.accentColor.withOpacity(
              _currentPage.round() == entry.key ? 0.9 : 0.4,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showExpandedCard(BuildContext context, int index) {
    _animationController.forward(from: 0.0);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExpandedCardView(
          item: widget.items[index],
          theme: widget.theme,
          animation: _animationController,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuint,
            )),
            child: child,
          );
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final ParallaxCarouselItem item;
  final VoidCallback onTap;
  final CarouselTheme theme;

  const _CarouselCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: item.imageUrl,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: theme.backgroundColor),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: theme.accentColor),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.backgroundColor.withOpacity(0.7)
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  item.title,
                  style: theme.titleStyle.copyWith(color: theme.textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedCardView extends StatelessWidget {
  final ParallaxCarouselItem item;
  final CarouselTheme theme;
  final Animation<double> animation;

  const ExpandedCardView({
    super.key,
    required this.item,
    required this.theme,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Hero(
          tag: item.imageUrl,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.backgroundColor.withOpacity(0.8)
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: theme.textColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: theme.titleStyle
                                    .copyWith(color: theme.textColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description,
                                style: theme.descriptionStyle
                                    .copyWith(color: theme.textColor),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.tags
                                    .map((tag) => _buildTag(tag))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                              if (item.onActionButtonPressed != null)
                                ElevatedButton(
                                  onPressed: item.onActionButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.accentColor),
                                  child: Text('Learn More',
                                      style: TextStyle(color: theme.textColor)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          Text(tag, style: theme.tagStyle.copyWith(color: theme.accentColor)),
    );
  }
}

// Usage example
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final List<ParallaxCarouselItem> carouselItems = [
    ParallaxCarouselItem(
      imageUrl: 'https://picsum.photos/id/1018/1000/600',
      title: 'Beautiful Mountains',
      description:
          'Majestic peaks reaching towards the sky, covered in snow and surrounded by lush forests.',
      tags: ['Nature', 'Landscape', 'Mountains'],
      onActionButtonPressed: () {
        print('Learn more about Beautiful Mountains');
      },
    ),
    ParallaxCarouselItem(
      imageUrl: 'https://picsum.photos/id/1015/1000/600',
      title: 'Serene Lake',
      description:
          'A tranquil body of water reflecting the surrounding landscape like a mirror.',
      tags: ['Nature', 'Landscape', 'Water'],
      onActionButtonPressed: () {
        print('Learn more about Serene Lake');
      },
    ),
    ParallaxCarouselItem(
      imageUrl: 'https://picsum.photos/id/1019/1000/600',
      title: 'Lush Forest',
      description:
          'A dense woodland teeming with life, where sunlight filters through the canopy.',
      tags: ['Nature', 'Landscape', 'Forest'],
      onActionButtonPressed: () {
        print('Learn more about Lush Forest');
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Parallax Carousel')),
      body: Center(
        child: AnimatedParallaxCarousel(
          items: carouselItems,
          theme: const CarouselTheme(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            accentColor: Colors.teal,
            titleStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            descriptionStyle: TextStyle(fontSize: 18),
            tagStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
