// home.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'city_search_page.dart';
import 'cities.dart';
import 'filtered_offers_page.dart';
import 'package:intl/intl.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'snowfall.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const WaveAppBar(
      {super.key,
      this.height = kToolbarHeight + 50.0}); // You can increase this if needed

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
              durations: [15000, 9440], // Removed leading 0 from 09440
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
              padding: const EdgeInsets.only(
                  bottom: 5.0), // Adjust the value as needed
              child: Text(
                'Upsy.',
                style: GoogleFonts.outfit(
                  color: const Color.fromARGB(255, 34, 34, 34),
                  fontSize: 40.0,
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

class _HomePageState extends State<HomePage> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  List<Map<String, String>> cityPairs = [
    {'from': 'Скопје', 'to': 'Велес'},
    {'from': 'Скопје', 'to': 'Кавадарци'},
    {'from': 'Куманово', 'to': 'Скопје'},
    {'from': 'Битола', 'to': 'Скопје'},
    {'from': 'Прилеп', 'to': 'Скопје'},
  ];

  void swapCities() {
    setState(() {
      String temp = fromController.text;
      fromController.text = toController.text;
      toController.text = temp;
    });
  }

  Widget _buildSwapButton() {
    return Positioned(
      top: 40, // Adjust the positioning as needed
      left: 170,
      right: 0,
      child: Center(
        child: FloatingActionButton(
          mini: true,
          onPressed: swapCities,
          backgroundColor: const Color.fromARGB(253, 255, 166, 0),
          child: const Icon(Icons.swap_vert, color: Colors.black),
        ),
      ),
    );
  }

  Future<int> getNumberOfOffersForDate({
    required DateTime date,
    required String departureCity,
    required String arrivalCity,
  }) async {
    Timestamp dayStart = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day, 0, 0),
    );
    Timestamp dayEnd = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day, 23, 59, 59),
    );

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('offers')
        .where('date', isGreaterThanOrEqualTo: dayStart)
        .where('date', isLessThanOrEqualTo: dayEnd)
        .where('departureCity', isEqualTo: departureCity)
        .where('arrivalCity', isEqualTo: arrivalCity)
        .get();

    return querySnapshot.docs.length;
  }

  void navigateToFilteredOffers(DateTime date, String fromCity, String toCity,
      bool searchFromTodayOnward) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredOffersPage(
          fromCity: fromCity,
          toCity: toCity,
          selectedDate: date,
          searchFromTodayOnward:
              searchFromTodayOnward, // Pass this new flag to the page
        ),
      ),
    );
  }

  Widget _buildOfferSection(int index) {
    String fromCity = cityPairs[index]['from']!;
    String toCity = cityPairs[index]['to']!;
    // Calculate the dates for today, tomorrow, and the day after tomorrow
    var today = DateTime.now();
    var tomorrow = DateTime.now().add(const Duration(days: 1));
    var dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));

    // Format the dates to a readable format, e.g., 'Monday', 'Tuesday', etc.
    var formatter =
        DateFormat('EEEE', 'mk'); // Specify locale to 'mk' for Macedonian
    var todayName = formatter.format(today);
    var tomorrowName = formatter.format(tomorrow);
    var dayAfterTomorrowName = formatter.format(dayAfterTomorrow);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4.0, // Adjust elevation to match the search card if needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Set the curve radius here
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => navigateToFilteredOffers(
                  selectedDate, fromController.text, toController.text, false),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 190, 190, 190),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), // Top left corner
                    topRight: Radius.circular(16), // Top right corner
                  ),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        fromCity,
                        style: GoogleFonts.montserrat(
                            fontWeight:
                                FontWeight.bold), // Montserrat font applied
                      ),
                      const Icon(Icons.navigate_next),
                      Text(
                        toCity,
                        style: GoogleFonts.montserrat(
                            fontWeight:
                                FontWeight.bold), // Montserrat font applied
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () {
                      setState(() {
                        String temp = cityPairs[index]['from']!;
                        cityPairs[index]['from'] = cityPairs[index]['to']!;
                        cityPairs[index]['to'] = temp;
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilteredOffersPage(
                          fromCity: fromCity,
                          toCity: toCity,
                          selectedDate: today,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey,
                      width: 1), // Define the border width and color
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(150, 212, 212, 212), // Semi-transparent
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildDayOfferCount(todayName, today, fromCity, toCity),
                  _buildDayOfferCount(tomorrowName, tomorrow, fromCity, toCity),
                  _buildDayOfferCount(
                      dayAfterTomorrowName, dayAfterTomorrow, fromCity, toCity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each day's offer count column
  Widget _buildDayOfferCount(
      String dayName, DateTime date, String fromCity, String toCity) {
    final DateFormat formatter = DateFormat.E('mk'); // Macedonian locale

    return GestureDetector(
      onTap: () => navigateToFilteredOffers(date, fromCity, toCity, false),
      child: Container(
        alignment: Alignment.center, // Ensure text is centered
        padding: const EdgeInsets.all(20.0), // Increase the tappable area
        color: Colors.transparent, // Make the expanded hitbox invisible
        child: Column(
          children: <Widget>[
            FutureBuilder<int>(
              future: getNumberOfOffersForDate(
                  date: date, departureCity: fromCity, arrivalCity: toCity),
              builder: (context, snapshot) {
                int offerCount = snapshot.data ?? 0;
                return Text(
                  offerCount.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                  ),
                );
              },
            ),
            const SizedBox(height: 3),
            Text(
              formatter.format(date),
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WaveAppBar(),
      body: SnowfallBackground(
        backgroundColor:
            const Color.fromARGB(253, 255, 166, 0), // Solid background color
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Column(
                              children: [
                                _buildCityField(
                                  labelText: 'Од',
                                  controller: fromController,
                                  isDepartureCity: true,
                                ),
                                const SizedBox(height: 8),
                                _buildCityField(
                                  labelText: 'До',
                                  controller: toController,
                                  isDepartureCity: false,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                            _buildSwapButton(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Датум',
                                  labelStyle: GoogleFonts
                                      .montserrat(), // Montserrat font applied
                                  border: const OutlineInputBorder(),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                controller: TextEditingController(
                                  text:
                                      "${selectedDate.toLocal()}".split(' ')[0],
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2101),
                                  );
                                  if (date != null && date != selectedDate) {
                                    setState(() {
                                      selectedDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  navigateToFilteredOffers(
                                      DateTime.now(),
                                      fromController.text,
                                      toController.text,
                                      true);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(253, 255, 166, 0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: Colors.black, width: 1),
                                  ),
                                ),
                                child: Text('Било Кога',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FilteredOffersPage(
                                    fromCity: fromController.text,
                                    toCity: toController.text,
                                    selectedDate: selectedDate,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  const Color.fromARGB(253, 255, 166, 0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors.black, width: 1),
                              ),
                            ),
                            child: Text('Барај',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(cityPairs.length, (index) {
                  return _buildOfferSection(index);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityField({
    required String labelText,
    required TextEditingController controller,
    required bool isDepartureCity,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CitySearchPage(cities: citiesList)));
        if (result != null) {
          setState(() {
            if (isDepartureCity) {
              fromController.text = result;
            } else {
              toController.text = result;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.montserrat(), // Montserrat font applied
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.search),
        ),
        child: Text(controller.text,
            style: GoogleFonts.montserrat()), // Montserrat font applied
      ),
    );
  }
}
