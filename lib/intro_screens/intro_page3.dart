import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.orange[100],
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1, // Takes half of the screen space
              child: Center(
                child: Image.asset(
                  'assets/finance.png',
                  width: 300, // Specify the width
                  height: 300,
                ), // Replace with your image path
              ),
            ),
            Expanded(
              flex: 1, // Takes the other half
              child: Center(
                child: Text(
                  'Faster, cheaper and more comfortable, yet cost effective for both parties',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
