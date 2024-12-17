// snowfall.dart

import 'dart:math';
import 'package:flutter/material.dart';

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white // Fully white snowflakes
      ..style = PaintingStyle.fill;

    for (var snowflake in snowflakes) {
      canvas.drawCircle(
        Offset(snowflake.x, snowflake.y),
        snowflake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Snowflake {
  double x;
  double y;
  double radius;
  double speed;
  double drift; // Horizontal movement

  Snowflake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
  });
}

class SnowfallBackground extends StatefulWidget {
  final Widget child;
  final Color backgroundColor; // New parameter for background color

  const SnowfallBackground({
    Key? key,
    required this.child,
    required this.backgroundColor, // Initialize background color
  }) : super(key: key);

  @override
  _SnowfallBackgroundState createState() => _SnowfallBackgroundState();
}

class _SnowfallBackgroundState extends State<SnowfallBackground>
    with SingleTickerProviderStateMixin {
  List<Snowflake> _snowflakes = [];
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // Approximately 60 FPS
    )..addListener(() {
        setState(() {
          for (var snowflake in _snowflakes) {
            snowflake.y += snowflake.speed;
            snowflake.x += snowflake.drift;

            // Wrap around horizontally
            if (snowflake.x > MediaQuery.of(context).size.width) {
              snowflake.x = 0;
            } else if (snowflake.x < 0) {
              snowflake.x = MediaQuery.of(context).size.width;
            }

            // Reset snowflake if it goes below the screen
            if (snowflake.y > MediaQuery.of(context).size.height) {
              snowflake.y = 0;
              snowflake.x =
                  _random.nextDouble() * MediaQuery.of(context).size.width;
            }
          }
        });
      });

    // Initialize snowflakes after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _snowflakes = List.generate(100, (_) {
        return Snowflake(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          radius: _random.nextDouble() * 3 + 2, // Radius between 2 to 5
          speed: _random.nextDouble() * 1 + 0.5, // Speed between 0.5 to 1.5
          // Speed between 1 to 3
          drift: _random.nextDouble() * 1 - 0.5, // Drift between -0.5 to +0.5
        );
      });
      _controller.repeat();
      print('Initialized snowflakes: ${_snowflakes.length}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Paint the background color first
        Container(
          color: widget.backgroundColor,
        ),
        // 2. Paint the snowflakes on top of the background
        IgnorePointer(
          child: CustomPaint(
            painter: SnowPainter(_snowflakes),
            size: Size.infinite,
          ),
        ),
        // 3. Render the main content above the snowflakes
        widget.child,
      ],
    );
  }
}
