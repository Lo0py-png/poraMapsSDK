// login.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Upsy/auth_service.dart';
import 'forgot_pw_page.dart';
import 'register.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'square_title.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for the animation
import 'snowfall.dart'; // Import the SnowfallBackground widget

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
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

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  late String email = '';
  late String password = '';
  String errorMessage = '';

  bool get _isLoginButtonEnabled => email.isNotEmpty && password.isNotEmpty;

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(
          'Upsy.',
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 40.0,
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
                    //     Color.fromARGB(253, 255, 166, 0),
                    //   ],
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    // ),
                    ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/logoChristmas.svg',
                      height: 100,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      onChanged: (value) => setState(() => email = value),
                      decoration: _inputDecoration('Внесете го вашиот емаил'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      onChanged: (value) => setState(() => password = value),
                      decoration: _inputDecoration('Внесете ја вашата лозинка'),
                    ),
                    const SizedBox(height: 10),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage,
                          style: GoogleFonts.montserrat(color: Colors.red),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ForgotPasswordPage();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Заборавена лозинка?',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.black)),
                        backgroundColor: _isLoginButtonEnabled
                            ? const Color.fromARGB(255, 253, 197, 43)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                      ),
                      onPressed: _isLoginButtonEnabled ? _attemptLogin : null,
                      child: Text(
                        'Најавете се',
                        style: GoogleFonts.montserrat(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: _attemptAnonymousLogin,
                      child: Text(
                        'Продолжете без акаунт',
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(5)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      ),
                      child: Text(
                        'Регистрирајте се!',
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Или продолжете со',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        SquareTile(
                          onTap: () async {
                            try {
                              await AuthService().signInWithGoogle();
                              _showSuccessDialog();
                            } catch (e) {
                              setState(() {
                                errorMessage =
                                    'Грешка при најавување со Google. Обидете се повторно.';
                              });
                            }
                          },
                          imagePath: 'assets/google.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _attemptLogin() async {
    setState(() {
      errorMessage = '';
      if (email.isEmpty) {
        errorMessage = 'Внесете емаил';
      }
      if (password.isEmpty) {
        errorMessage = 'Внесете лозинка';
      }
    });

    if (errorMessage.isNotEmpty) {
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _handleAuthErrors(e);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Настана грешка. Обидете се повторно.';
      });
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      pageBuilder: (context, _, __) {
        return Center(
          child: Lottie.asset(
            'assets/green_check.json', // Path to your green check animation
            width: 100, // Adjust size if needed
            height: 100,
            repeat: false, // No loop for the animation
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(scale: anim1, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(
          context, '/main', (Route<dynamic> route) => false);
    });
  }

  String _handleAuthErrors(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Не постои корисник со таа е-пошта.';
      case 'wrong-password':
        return 'Погрешна лозинка.';
      case 'invalid-email':
        return 'Е-поштата не е валидна.';
      case 'user-disabled':
        return 'Овој кориснички профил е оневозможен.';
      case 'too-many-requests':
        return 'Претерано многу обиди. Обидете се подоцна.';
      default:
        return 'Непозната грешка. Обидете се повторно.';
    }
  }

  void _attemptAnonymousLogin() async {
    try {
      await _auth.signInAnonymously();
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }
}
