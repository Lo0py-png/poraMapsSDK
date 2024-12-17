import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'newoffer.dart';
//import 'about.dart';
//import 'login.dart';
import 'MyRides.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _widgetOptions {
    return [
      const HomePage(),
      MyRidesPage(changeTab: changeTab),
      const OffersPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: const Color.fromARGB(255, 253, 197, 43),
        color: const Color.fromARGB(255, 245, 180, 0),
        height: 55,
        items: const [
          Icon(
            Icons.home,
            semanticLabel: 'Home',
          ),
          Icon(
            Icons.directions_car,
            semanticLabel: 'myrides',
          ),
          Icon(
            Icons.playlist_add,
            semanticLabel: 'newoffer',
          ),
          Icon(
            Icons.person,
            semanticLabel: 'profile',
          )
        ],
        onTap: changeTab,
      ),
    );
  }
}
