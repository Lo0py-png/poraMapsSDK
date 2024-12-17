import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'OfferDetailsPage.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchResultsPage extends StatefulWidget {
  final String from;
  final String to;
  final DateTime date;

  const SearchResultsPage({
    Key? key,
    required this.from,
    required this.to,
    required this.date,
  }) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget title;
  final Widget leading;
  final PreferredSizeWidget? bottom;

  const WaveAppBar({super.key, 
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
              durations: [15000, 09440],
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

class _SearchResultsPageState extends State<SearchResultsPage> {
  Future<String> _getUserName(String userId) async {
    var userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      return userSnapshot.data()!['name'] ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate =
        DateTime(widget.date.year, widget.date.month, widget.date.day);
    DateTime endDate = DateTime(
        widget.date.year, widget.date.month, widget.date.day, 23, 59, 59);
    Timestamp startTimestamp = Timestamp.fromDate(startDate);
    Timestamp endTimestamp = Timestamp.fromDate(endDate);

    String appBarTitle = DateFormat('EEEE, dd.MM.').format(widget.date);

    return Container(
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
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: WaveAppBar(
              title: Text(
                appBarTitle,
                style: GoogleFonts.outfit(
                  color: const Color.fromARGB(255, 34, 34, 34),
                  fontSize: 30.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              // If you have bottom widgets like TabBar, you can add them here.
            ),
            body: Column(children: [
              Container(
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .where('departureCity', isEqualTo: widget.from)
                      .where('arrivalCity', isEqualTo: widget.to)
                      .where('date', isGreaterThanOrEqualTo: startTimestamp)
                      .where('date', isLessThanOrEqualTo: endTimestamp)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No matching offers found.'));
                    }

                    List<DocumentSnapshot> documents = snapshot.data!.docs;

                    return Container(
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
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
                                      widget.from,
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(Icons.navigate_next),
                                    Text(
                                      widget.to,
                                      style: const TextStyle(
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
                              // Changed from ListView.separated to ListView.builder
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                var offer = documents[index].data()
                                    as Map<String, dynamic>;
                                var offerId = documents[index].id;
                                var offerWithId = {
                                  'offer': offer,
                                  'offerId': offerId
                                };
                                final timeString = offer['time'] != null
                                    ? DateFormat('HH:mm')
                                        .format(offer['time'].toDate())
                                    : 'Not specified';

                                // Add spacing on top for the first item
                                EdgeInsetsGeometry padding = EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: index == 0 ? 16.0 : 8.0,
                                  bottom: index == documents.length - 1
                                      ? 16.0
                                      : 8.0,
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

                                    return Padding(
                                      padding: padding,
                                      child: Material(
                                        color: Colors
                                            .white, // Set background color for the ListTile
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Rounded corners
                                        elevation: 4.0, // No shadow
                                        child: ListTile(
                                          title: Text(timeString,
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                          subtitle: Text(userSnapshot.data ??
                                              'No user name'),
                                          trailing: Text(
                                            '${offer['price']}den',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
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
                            ),
                          )
                        ]));
                  },
                ),
              )
            ])));
  }
}
