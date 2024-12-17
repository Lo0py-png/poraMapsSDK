import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'MainScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controller for the Lottie animation

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this); // Initialize the controller

    // Navigate to home after a fixed delay
    Future.delayed(const Duration(seconds: 3), () {
      navigateToHome();
    });
  }

  void navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(_createRoute());
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const MainScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween =
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease));
        var fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animation.json',
          controller: _controller, // Apply the animation controller
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
          frameRate: FrameRate.max,
        ),
      ),
    );
  }
}
