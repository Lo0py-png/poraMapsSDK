// filtered_offers_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'OfferDetailsPage.dart'; // Ensure correct path
import 'package:intl/intl.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'snowfall.dart'; // Import the SnowfallBackground widget

class FilteredOffersPage extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final DateTime selectedDate;
  final bool searchFromTodayOnward;

  const FilteredOffersPage({
    Key? key,
    required this.fromCity,
    required this.toCity,
    required this.selectedDate,
    this.searchFromTodayOnward = false,
  }) : super(key: key);

  @override
  _FilteredOffersPageState createState() => _FilteredOffersPageState();
}

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget title;
  final Widget leading;
  final PreferredSizeWidget? bottom;

  const WaveAppBar({
    super.key,
    this.height = kToolbarHeight + 50.0,
    required this.title,
    required this.leading,
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
                ],
              ],
              durations: [15000, 9440],
              heightPercentages: [0.10, 0.30],
              gradientBegin: Alignment.bottomLeft,
              gradientEnd: Alignment.topRight,
            ),
            waveAmplitude: 0,
            size: Size(double.infinity, preferredSize.height),
          ),
          AppBar(
            leading: leading,
            title: title,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          if (bottom != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottom!,
            ),
        ],
      ),
    );
  }
}

class _FilteredOffersPageState extends State<FilteredOffersPage> {
  Future<String> _getUserName(String userId) async {
    var userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      return userSnapshot.data()!['name'] ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  Future<void> _toggleFavorite(String offerId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    var userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      List favorites = userSnapshot.data()?['favorites'] ?? [];

      if (favorites.contains(offerId)) {
        favorites.remove(offerId);
      } else {
        favorites.add(offerId);
      }

      await userRef.update({'favorites': favorites});
    } else {
      await userRef.set({
        'favorites': [offerId],
      }, SetOptions(merge: true));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('offers')
        .where('departureCity', isEqualTo: widget.fromCity)
        .where('arrivalCity', isEqualTo: widget.toCity)
        .orderBy('date', descending: false);

    if (widget.searchFromTodayOnward) {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay));
    } else {
      DateTime startOfDay = DateTime(widget.selectedDate.year,
          widget.selectedDate.month, widget.selectedDate.day);
      DateTime endOfDay = DateTime(widget.selectedDate.year,
          widget.selectedDate.month, widget.selectedDate.day, 23, 59, 59);
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
    }

    String appBarTitle = widget.searchFromTodayOnward
        ? "Било Кога"
        : DateFormat('EEEE, dd.MM.', 'mk').format(widget.selectedDate);

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(
          appBarTitle,
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 30.0,
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
        child: Column(children: [
          // Removed the outer Container with gradient
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 200),
                      SvgPicture.asset(
                        'assets/logoTearChristmas.svg',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Нема достапни понуди за оваа рута.',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }

              List<DocumentSnapshot> documents = snapshot.data!.docs;
              return Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.fromCity,
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.navigate_next),
                              Text(
                                widget.toCity,
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(documents.length.toString()),
                        ],
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          var offer =
                              documents[index].data() as Map<String, dynamic>;
                          var offerId = documents[index].id;
                          var offerWithId = {
                            'offer': offer,
                            'offerId': offerId
                          };

                          final time = offer['time'] != null
                              ? offer['time'].toDate()
                              : null;
                          final date = offer['date'] != null
                              ? offer['date'].toDate()
                              : null;

                          final timeString = time != null
                              ? "${DateFormat('HH:mm').format(time)} (${DateFormat('dd.MM.yyyy').format(date ?? DateTime.now())})"
                              : 'Not specified';

                          EdgeInsetsGeometry padding = EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: index == 0 ? 16.0 : 8.0,
                            bottom: index == documents.length - 1 ? 16.0 : 8.0,
                          );

                          return FutureBuilder<String>(
                            future: _getUserName(offer['userId']),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading...'),
                                );
                              }

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }

                                  var userData = snapshot.data!.data() as Map?;
                                  var favorites = userData?['favorites'] ?? [];

                                  return Padding(
                                    padding: padding,
                                    child: Material(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15.0),
                                      elevation: 4.0,
                                      child: ListTile(
                                        title: Text(
                                          timeString,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          userSnapshot.data ?? 'No user name',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${offer['price']} den.',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                favorites.contains(offerId)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color:
                                                    favorites.contains(offerId)
                                                        ? Colors.red
                                                        : Colors.grey,
                                              ),
                                              onPressed: () {
                                                _toggleFavorite(offerId);
                                              },
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OfferDetailsPage(
                                                      offer: offerWithId),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}
