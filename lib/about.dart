import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('About Our App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
                'Our app is a platform where anyone can offer their transport services. '
                'We aim to connect people who need transport with those who can provide it. '
                'Whether you need a ride or want to earn extra money by providing transport, '
                'our app is the place for you.',
                style: TextStyle(fontSize: 16)),
            // You can add more text widgets to provide more information about your app or company
          ],
        ),
      ),
    );
  }
}
