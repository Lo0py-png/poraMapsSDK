import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'city_search_page.dart';
import 'cities.dart';
import 'package:google_fonts/google_fonts.dart';

class EditOfferPage extends StatefulWidget {
  final Map<String, dynamic> offerData;
  final String offerId;

  const EditOfferPage(
      {Key? key, required this.offerData, required this.offerId})
      : super(key: key);

  @override
  _EditOfferPageState createState() => _EditOfferPageState();
}

class _EditOfferPageState extends State<EditOfferPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _departureCityController;
  late TextEditingController _arrivalCityController;
  late TextEditingController _carModelController;
  late TextEditingController _descriptionController;
  late TextEditingController _seatsController;
  late TextEditingController _priceController;
  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _departureCityController =
        TextEditingController(text: widget.offerData['departureCity']);
    _arrivalCityController =
        TextEditingController(text: widget.offerData['arrivalCity']);
    _carModelController =
        TextEditingController(text: widget.offerData['carModel']);
    _descriptionController =
        TextEditingController(text: widget.offerData['description']);
    _seatsController =
        TextEditingController(text: widget.offerData['seats'].toString());
    _priceController =
        TextEditingController(text: widget.offerData['price'].toString());
    _date = widget.offerData['date'].toDate();
    _time = TimeOfDay.fromDateTime(widget.offerData['time'].toDate());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(), // Ensure no past dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _navigateAndSelectCity(
      BuildContext context, bool isDepartureCity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CitySearchPage(cities: citiesList)),
    );
    if (result != null) {
      setState(() {
        if (isDepartureCity) {
          _departureCityController.text = result;
        } else {
          _arrivalCityController.text = result;
        }
      });
    }
  }

  void _updateOffer() async {
    if (_formKey.currentState!.validate()) {
      DateTime fullDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
      Timestamp dateTimestamp = Timestamp.fromDate(_date);
      Timestamp timeTimestamp = Timestamp.fromDate(fullDateTime);

      Map<String, dynamic> updatedOffer = {
        'departureCity': _departureCityController.text,
        'arrivalCity': _arrivalCityController.text,
        'carModel': _carModelController.text,
        'description': _descriptionController.text,
        'seats': int.tryParse(_seatsController.text) ?? 1,
        'price': int.tryParse(_priceController.text) ?? 0,
        'date': dateTimestamp,
        'time': timeTimestamp,
      };

      await FirebaseFirestore.instance
          .collection('offers')
          .doc(widget.offerId)
          .update(updatedOffer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Превозот е успешно ажуриран.')),
      );

      Navigator.pushNamedAndRemoveUntil(
          context, '/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: AppBar(
          backgroundColor: const Color.fromARGB(253, 255, 166, 0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Colors.black), // Set the back button color here
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Ажурирај понуда',
            style: GoogleFonts.montserrat(
              color: const Color.fromARGB(255, 34, 34, 34),
              fontSize: 25.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          elevation: 0.0, // Customize as needed
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () => _navigateAndSelectCity(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Град на поаѓање',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(
                      _departureCityController.text,
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _navigateAndSelectCity(context, false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Град на пристигнување',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(
                      _arrivalCityController.text,
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _carModelController,
                  decoration: InputDecoration(
                    labelText: 'Модел на возило',
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  style: GoogleFonts.montserrat(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Моделот на возилото не може да биде празен.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Опис',
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  style: GoogleFonts.montserrat(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Описот не може да биде празен.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _seatsController,
                  decoration: InputDecoration(
                    labelText: 'Слободни места',
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Цена',
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.montserrat(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Цената не може да биде празна.';
                    }
                    final price = int.tryParse(value);
                    if (price == null || price < 150) {
                      return 'Цената мора да биде најмалку 150.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Датум',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(
                      "${_date.toLocal()}".split(' ')[0],
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Време',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(
                      _time.format(context),
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateOffer,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color.fromARGB(255, 228, 178, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.black))),
                  child: Text(
                    'Ажурирај понуда',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
