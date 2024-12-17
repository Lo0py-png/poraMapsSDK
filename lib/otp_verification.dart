import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String userId; // Accept the userId as a parameter

  OTPVerificationPage({required this.phoneNumber, required this.userId});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const WaveAppBar({super.key, this.height = kToolbarHeight + 50.0});

  @override
  Size get preferredSize => Size.fromHeight(height);

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
                ],
              ],
              durations: [15000, 9440],
              heightPercentages: [0.10, 0.30],
              gradientBegin: Alignment.bottomLeft,
              gradientEnd: Alignment.topRight,
            ),
            waveAmplitude: 0,
            size: Size(
              double.infinity,
              preferredSize.height,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'ОТП Верификација',
                style: GoogleFonts.montserrat(
                  color: const Color.fromARGB(255, 34, 34, 34),
                  fontSize: 31.0,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();
  String _verificationId = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isVerifying = true;
    });

    String phoneNumber = widget.phoneNumber.trim();
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+389' + phoneNumber; // Prepend Macedonian country code
    }

    if (!RegExp(r'^\+\d{1,15}$').hasMatch(phoneNumber)) {
      setState(() {
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter a valid phone number in E.164 format.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _updateVerificationStatus();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isVerifying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isVerifying = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Внеси ОТП')),
      );
      return;
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otpController.text,
    );

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Link the phone credential to the current user
        await currentUser.linkWithCredential(credential);
        await currentUser
            .reload(); // Refresh the user to ensure the session updates
        FirebaseAuth.instance.currentUser; // Reassign the updated user
      } else {
        // Sign in as a fallback if no user is signed in
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      _updateVerificationStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Невалиден ОТП: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateVerificationStatus() async {
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId); // Use the userId passed from ProfilePage

    try {
      // Check if the document exists
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Update the document
        await userDoc.update({'isPhoneVerified': true});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Телефонскиот број верифициран успешно!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User document not found.')),
        );
      }

      // Navigate back to the ProfilePage
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating verification status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WaveAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(253, 255, 166, 0),
              Color.fromARGB(253, 255, 166, 0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Испративме ОТП до ${widget.phoneNumber}',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_verificationId.isNotEmpty)
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    labelStyle: GoogleFonts.montserrat(color: Colors.black),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verificationId.isEmpty ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(
                        253, 255, 166, 0), // Match the style
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator()
                      : Text('Верифицирај ОТП',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
