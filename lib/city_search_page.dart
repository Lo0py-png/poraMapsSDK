import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Upsy/transliterationMap.dart';

String transliterate(String input) {
  String result = input.toLowerCase();
  transliterationMap.forEach((key, value) {
    result = result.replaceAll(key, value);
  });
  return result;
}

class CitySearchPage extends StatefulWidget {
  final List<String> cities;

  const CitySearchPage({Key? key, required this.cities}) : super(key: key);

  @override
  _CitySearchPageState createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  String filter = "";

  @override
  Widget build(BuildContext context) {
    // Transliterate the filter and match both transliterated and exact names
    String transliteratedFilter = transliterate(filter);

    List<String> filteredCities = widget.cities
        .where((city) =>
            city.toLowerCase().contains(transliteratedFilter) ||
            city.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: const Color.fromARGB(253, 255, 166, 0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Одберете град',
            style: GoogleFonts.montserrat(
              color: const Color.fromARGB(255, 34, 34, 34),
              fontSize: 25.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          elevation: 0.0,
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Пребарај',
                labelStyle: GoogleFonts.montserrat(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
                suffixIcon: const Icon(Icons.search),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {
                  filter = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredCities[index],
                    style: GoogleFonts.montserrat(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.location_city),
                  onTap: () {
                    Navigator.pop(context, filteredCities[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
