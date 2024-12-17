import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:Upsy/MainScreen.dart';
import 'login.dart';
import 'about.dart';
import 'profile.dart';
import 'register.dart';
import 'newoffer.dart';
import 'home.dart';
import 'splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'otp_verification.dart';

import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyC-eNrwC5HdZ8v4KcTP5c2w17l6dNfh41g',
        appId: '1:467000119099:android:470a058c17e6b248af311e',
        messagingSenderId: '',
        projectId: 'prevozi-mk'),
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );
  initializeDateFormatting('mk', null);
  FlutterNativeSplash.remove();
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Upsy',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/about': (context) => const AboutPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/offers': (context) => const OffersPage(),
        '/main': (context) => const MainScreen()
      },
    );
  }
}
