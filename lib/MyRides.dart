// myrides.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'OfferDetailsPage.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'snowfall.dart';

class MyRidesPage extends StatefulWidget {
  final void Function(int) changeTab;

  const MyRidesPage({Key? key, required this.changeTab}) : super(key: key);

  @override
  _MyRidesPageState createState() => _MyRidesPageState();
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
                'Мои превози',
                style: GoogleFonts.montserrat(
                  color: const Color.fromARGB(255, 34, 34, 34),
                  fontSize: 40.0,
                  fontWeight: FontWeight.w800,
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

class _MyRidesPageState extends State<MyRidesPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _toggleFavorite(String offerId) async {
    if (user == null) return;

    var userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    var userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      List favorites = userSnapshot.data()?['favorites'] ?? [];

      if (favorites.contains(offerId)) {
        favorites.remove(offerId); // Remove from favorites
      } else {
        favorites.add(offerId); // Add to favorites
      }

      await userRef.update({'favorites': favorites});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the background color you want for MyRidesPage
    const Color myRidesBackgroundColor = Color.fromARGB(253, 255, 166, 0);

    // Define the child widget based on user's login state
    Widget childContent;

    if (user == null || user!.isAnonymous) {
      // User is not logged in
      childContent = Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 240),
          child: Container(
            padding:
                const EdgeInsets.all(32.0), // Increased padding for larger card
            decoration: BoxDecoration(
              color: Colors.white, // White background for the card
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Slight shadow
                  blurRadius: 15.0, // Larger blur radius for better shadow
                  spreadRadius: 3.0, // Spread radius for shadow
                  offset: const Offset(0, 5), // Offset for shadow
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular logo container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        253, 255, 166, 0), // Background color
                    shape: BoxShape.circle, // Circular shape
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(10.0), // Padding inside the circle
                    child: SvgPicture.asset(
                      'assets/logoSadChristmas.svg', // Replace with your asset path
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 24.0), // Larger spacing between logo and text
                Text(
                  'Ве молиме',
                  style: GoogleFonts.montserrat(
                    color: const Color.fromARGB(255, 34, 34, 34),
                    fontSize: 23.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                    height: 24.0), // Larger spacing between text and button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 226, 226, 226), // Light grey background
                    foregroundColor: Colors.black, // Text color
                    elevation: 8, // Add shadow effect
                    shadowColor: Colors.black.withOpacity(0.4), // Shadow color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16.0), // Rounded corners
                      side: const BorderSide(
                        color: Colors.black, // Optional: Add a border
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ), // Larger padding for a bigger button
                  ),
                  child: Text(
                    'Најавете се!',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // User is logged in
      childContent = Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .where('userId', isEqualTo: user!.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/logoTearChristmas.svg',
                              width: 180,
                              height: 180,
                            ),
                            Text(
                              'Немате ваши превози.',
                              style: GoogleFonts.montserrat(
                                color: const Color.fromARGB(255, 34, 34, 34),
                                fontSize: 20.0,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                widget.changeTab(2);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 8.0,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: Text(
                                'Нов Превоз',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var ride = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      var offerId = snapshot.data!.docs[index].id;
                      var rideWithId = {'offer': ride, 'offerId': offerId};

                      // Format the date to show only the day, month, and year
                      var dateTime = ride['date'] != null
                          ? (ride['date'] as Timestamp).toDate().toLocal()
                          : DateTime.now().toLocal();
                      var formattedDate =
                          "${dateTime.day}.${dateTime.month}.${dateTime.year}";

                      // Get the price
                      var price = ride['price'] != null
                          ? "${ride['price']} ден."
                          : "Без цена";

                      return Card(
                        elevation: 8.0,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                              "${ride['departureCity']} > ${ride['arrivalCity']}"),
                          subtitle: Text("$formattedDate • $price"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    OfferDetailsPage(offer: rideWithId),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Омилени',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    !(snapshot.data!.data() as Map<String, dynamic>)
                        .containsKey('favorites') ||
                    (snapshot.data!.data() as Map<String, dynamic>)['favorites']
                        .isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Немате омилени превози.',
                        style: GoogleFonts.montserrat(
                          color: const Color.fromARGB(255, 34, 34, 34),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  var favorites = (snapshot.data!.data()
                      as Map<String, dynamic>)['favorites'] as List;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('offers')
                            .doc(favorites[index])
                            .snapshots(),
                        builder: (context, offerSnapshot) {
                          if (offerSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (offerSnapshot.hasError) {
                            return Text('Error: ${offerSnapshot.error}');
                          } else if (!offerSnapshot.hasData ||
                              !offerSnapshot.data!.exists) {
                            return const SizedBox.shrink();
                          } else {
                            var ride = offerSnapshot.data!.data()
                                as Map<String, dynamic>;
                            var offerId = offerSnapshot.data!.id;
                            var rideWithId = {
                              'offer': ride,
                              'offerId': offerId
                            };

                            // Format the date to show only the day, month, and year
                            var dateTime = ride['date'] != null
                                ? (ride['date'] as Timestamp).toDate().toLocal()
                                : DateTime.now().toLocal();
                            var formattedDate =
                                "${dateTime.day}.${dateTime.month}.${dateTime.year}";

                            // Get the price
                            var price = ride['price'] != null
                                ? "${ride['price']} ден."
                                : "Без цена";

                            return Card(
                              elevation: 8.0,
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                    "${ride['departureCity']} > ${ride['arrivalCity']}"),
                                subtitle: Text("$formattedDate • $price"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite,
                                      color: Colors.red),
                                  onPressed: () {
                                    _toggleFavorite(offerId);
                                  },
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OfferDetailsPage(offer: rideWithId),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: const WaveAppBar(),
      body: SnowfallBackground(
        backgroundColor:
            const Color.fromARGB(253, 255, 166, 0), // Solid background color
        child: childContent,
      ),
    );
  }
}
