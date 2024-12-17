// register.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'snowfall.dart'; // Import the SnowfallBackground widget

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
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

class CustomTextFormField extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode; // Add focusNode parameter

  const CustomTextFormField({
    Key? key,
    required this.label,
    required this.onChanged,
    this.obscureText = false,
    this.validator,
    this.focusNode, // Accept focusNode
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        obscureText: obscureText,
        focusNode: focusNode, // Set focusNode
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorStyle: GoogleFonts.montserrat(
            color: Colors.red,
            fontSize: 13,
            height: 1.2,
            // Ensures proper spacing for multi-line text
          ),
        ),
      ),
    );
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final List<String> _supportedEmailProviders = [
    "gmail.com",
    "yahoo.com",
    "outlook.com",
    "hotmail.com",
    "edu.mk"
  ];

  late String email;
  late String password;
  late String name;
  late String surname;
  late String phoneNumber;
  bool _isAgreed = false;
  String? _agreementError;

  bool _isRegisterButtonEnabled = false;
  bool _isRegistering = false;
  bool _showErrors = false;
  TapGestureRecognizer? _termsRecognizer;
  TapGestureRecognizer? _privacyRecognizer;
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _launchURL('https://upsy.mk/terms-and-conditions');
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _launchURL('https://upsy.mk/privacy-policy');
      };
  }

  @override
  void dispose() {
    _termsRecognizer?.dispose();
    _privacyRecognizer?.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        // Ensure it opens in a browser
      );
    } else {
      throw 'Не можам да го отворам $url';
    }
  }

  void _validateForm() {
    setState(() {
      _isRegisterButtonEnabled = _formKey.currentState?.validate() == true &&
          _isAgreed &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          name.isNotEmpty &&
          surname.isNotEmpty &&
          phoneNumber.isNotEmpty;
    });
  }

  Future<void> _registerUser() async {
    try {
      final phoneQuerySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (phoneQuerySnapshot.docs.isNotEmpty) {
        _showErrorDialog('Овој телефонски број веќе се користи.');
        return;
      }

      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(newUser.user!.uid).set({
        'name': name,
        'surname': surname,
        'email': email,
        'phoneNumber': phoneNumber,
        'isPhoneVerified': false,
      });

      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      String message = 'Настана грешка. Проверете ги вашите податоци.';
      if (e.code == 'email-already-in-use') {
        message = 'Оваа е-пошта веќе се користи.';
      } else if (e.code == 'invalid-email') {
        message = 'Е-поштата не е валидна.';
      } else if (e.code == 'weak-password') {
        message = 'Лозинката е слаба.';
      }
      _showErrorDialog(message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Грешка при регистрација'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Во ред'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String? _passwordValidator(String? value) {
    final passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{5,}$');
    if (!passwordRegEx.hasMatch(value!)) {
      return 'Лозинката мора да содржи најмалку 5 знаци, една голема буква и број.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: WaveAppBar(
        title: Text(
          'Регистрација',
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 32.0,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomTextFormField(
                        label: 'Име',
                        onChanged: (value) {
                          name = value;
                          _validateForm();
                        },
                        validator: (value) {
                          if (_showErrors && (value == null || value.isEmpty)) {
                            return 'Внесете име';
                          }
                          return null;
                        },
                      ),
                      CustomTextFormField(
                        label: 'Презиме',
                        onChanged: (value) {
                          surname = value;
                          _validateForm();
                        },
                        validator: (value) {
                          if (_showErrors && (value == null || value.isEmpty)) {
                            return 'Внесете презиме';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          onChanged: (value) {
                            email = value;
                            _validateForm();
                          },
                          validator: (value) {
                            if (_showErrors &&
                                (value == null || value.isEmpty)) {
                              return 'Внесете е-пошта';
                            } else if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                              return 'Е-поштата не е валидна';
                            } else if (value != null &&
                                value.isNotEmpty &&
                                !_supportedEmailProviders.any((provider) =>
                                    value.endsWith("@$provider"))) {
                              return 'Е-поштата мора да биде од поддржан провајдер (${_supportedEmailProviders.join(", ")}).';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Е-пошта',
                            labelStyle: GoogleFonts.montserrat(),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            errorMaxLines:
                                4, // Ensures the error message supports two lines
                            errorStyle: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 13,
                              height: 1.2, // Adjusts line spacing
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          onChanged: (value) {
                            password = value;
                            _validateForm();
                          },
                          validator: (value) {
                            final passwordRegEx =
                                RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{5,}$');
                            if (value == null ||
                                !passwordRegEx.hasMatch(value)) {
                              return 'Лозинката мора да содржи најмалку 5 знаци, една голема буква и број.';
                            }
                            return null;
                          },
                          obscureText: true,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Лозинка',
                            labelStyle: GoogleFonts.montserrat(),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            errorMaxLines:
                                2, // Forces error text to use two lines
                            errorStyle: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 13,
                              height: 1.2, // Line spacing
                            ),
                          ),
                        ),
                      ),
                      CustomTextFormField(
                        label: 'Телефонски број',
                        onChanged: (value) {
                          phoneNumber = value;
                          if (_phoneFocusNode.hasFocus) {
                            _validateForm();
                          }
                        },
                        validator: (value) {
                          if (_phoneFocusNode.hasFocus &&
                              (value == null ||
                                  !RegExp(r'^07\d{7}$').hasMatch(value))) {
                            return 'Телефонскиот број мора да започне со 07\nи да има 9 цифри.';
                          }
                          return null;
                        },
                        focusNode: _phoneFocusNode,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _isAgreed,
                            onChanged: (value) {
                              setState(() {
                                _isAgreed = value!;
                                _agreementError = null;
                              });
                              _validateForm();
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Се согласувам дека сум над 18 години и со ',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black, fontSize: 13),
                                  ),
                                  TextSpan(
                                    text: 'Правила и Услови',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                    recognizer: _termsRecognizer,
                                  ),
                                  TextSpan(
                                    text: ' и ',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Политика на Приватност',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                    recognizer: _privacyRecognizer,
                                  ),
                                  const TextSpan(
                                    text: '.',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_agreementError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _agreementError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 8.0,
                          backgroundColor:
                              _isRegistering || !_isRegisterButtonEnabled
                                  ? Colors.grey
                                  : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(
                              color: Colors.black,
                              width: 1), // Add black border
                        ),
                        onPressed: _isRegistering || !_isRegisterButtonEnabled
                            ? null
                            : () async {
                                setState(() {
                                  _showErrors =
                                      true; // Show errors for empty fields
                                });
                                if (_formKey.currentState?.validate() == true) {
                                  setState(() {
                                    _isRegistering = true;
                                  });
                                  await _registerUser();
                                  setState(() {
                                    _isRegistering = false;
                                  });
                                }
                              },
                        child: _isRegistering
                            ? const CircularProgressIndicator()
                            : Text(
                                'Регистрирај се',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 17),
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
}
