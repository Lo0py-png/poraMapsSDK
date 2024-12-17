// forgot_password_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'snowfall.dart'; // Import the SnowfallBackground widget

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget title;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const WaveAppBar({
    super.key,
    this.height = kToolbarHeight + 50.0,
    required this.title,
    this.leading,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Stack(
        children: [
          WaveWidget(
            config: CustomConfig(
              gradients: [
                [const Color.fromARGB(255, 255, 124, 1), Colors.orange],
                [
                  const Color.fromARGB(253, 255, 166, 0),
                  const Color.fromARGB(253, 255, 166, 0)
                ]
              ],
              durations: [15000, 19440],
              heightPercentages: [0.20, 0.25],
              gradientBegin: Alignment.bottomLeft,
              gradientEnd: Alignment.topRight,
            ),
            waveAmplitude: 0,
            size: Size(double.infinity, preferredSize.height),
          ),
          AppBar(
            centerTitle: true,
            leading: leading,
            title: title,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            bottom: bottom,
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: const Text(
                  'Линкот за ресетирање на лозинка е испратен! Проверете го вашиот емаил.',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('ОК',
                        style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                ]);
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content:
                    Text(e.message.toString(), style: GoogleFonts.montserrat()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('ОК',
                        style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                ]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: WaveAppBar(
        title: Text(
          'Ресетирај Лозинка',
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SnowfallBackground(
        backgroundColor:
            const Color.fromARGB(253, 255, 166, 0), // Match the gradient color
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth,
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                // Remove the gradient from the child Container
                decoration: const BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [
                    //     Color.fromARGB(253, 255, 166, 0),
                    //     Color.fromARGB(255, 228, 178, 40),
                    //   ],
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    // ),
                    ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 250),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          'Внесете го вашиот емаил и ќе ви испратиме линк за ресетирање на лозинката.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            hintText: 'Емаил',
                            hintStyle: GoogleFonts.montserrat(),
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        onPressed: passwordReset,
                        color: const Color.fromARGB(255, 253, 197, 43),
                        child: Text(
                          'Ресетирај Лозинка',
                          style: GoogleFonts.montserrat(
                              fontWeight:
                                  FontWeight.bold), // Using Montserrat font
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.black)),
                        height: 45,
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
}
