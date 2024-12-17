// offers_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'city_search_page.dart';
import 'package:uuid/uuid.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'snowfall.dart'; // Ensure this import is correct

class OffersPage extends StatefulWidget {
  const OffersPage({Key? key}) : super(key: key);

  @override
  _OffersPageState createState() => _OffersPageState();
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
              durations: [15000, 9440], // Removed leading zero
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
                'Нова Понуда',
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

class _OffersPageState extends State<OffersPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isSubmitting = false; // Track if the form is being submitted

  String _departureCity = '';
  String _arrivalCity = '';
  String _carModel = '';
  String _description = '';
  int _seats = 0;
  int _price = 0;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _phoneNumber = '';

  final List<String> _cities = [
    'Аеродром',
    'Арачиново',
    'Берово',
    'Битола',
    'Богданци',
    'Боговиње',
    'Босилово',
    'Брбеница',
    'Бутел',
    'Валандово',
    'Василево',
    'Вевчани',
    'Велес',
    'Виница',
    'Врапчиште',
    'Гази Баба',
    'Гевгелија',
    'Ѓорче Петров',
    'Гостивар',
    'Градско',
    'Дебар',
    'Дебарца',
    'Делчево',
    'Демир Капија',
    'Демир Хисар',
    'Дојран',
    'Долнени',
    'Желино',
    'Зелениково',
    'Зрновци',
    'Илинден',
    'Јегуновце',
    'Кавадарци',
    'Карбинци',
    'Карпош',
    'Кисела Вода',
    'Кичево',
    'Конче',
    'Кочани',
    'Кратово',
    'Крива Паланка',
    'Кривогаштани',
    'Крушево',
    'Куманово',
    'Липково',
    'Лозово',
    'Маврово и Ростуше',
    'Македонска Каменица',
    'Македонски Брод',
    'Могила',
    'Неготино',
    'Новаци',
    'Ново Село',
    'Охрид',
    'Петровец',
    'Пехчево',
    'Пласница',
    'Прилеп',
    'Пробиштип',
    'Радовиш',
    'Ранковце',
    'Ресен',
    'Росоман',
    'Сарај',
    'Свети Николе',
    'Скопје',
    'Сопиште',
    'Старо Нагоричане',
    'Струга',
    'Струмица',
    'Студеничани',
    'Теарце',
    'Тетово',
    'Центар Жупа',
    'Центар',
    'Чаир',
    'Чашка',
    'Чешиново',
    'Чучер Сандево',
    'Штип',
    'Шуто Оризари',
    'Аеродром Скопје',
    'Аеродром Охрид'
  ];

  Widget buildCityField({
    required String labelText,
    required String value,
    required bool isDepartureCity,
  }) {
    return InkWell(
      onTap: () =>
          _navigateAndDisplaySelection(context, _cities, isDepartureCity),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.montserrat(
              textStyle: const TextStyle(
            color: Colors.black,
          )),
          fillColor: Colors.white, // White background color
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
          suffixIcon: const Icon(Icons.search),
        ),
        baseStyle: GoogleFonts.montserrat(
          textStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        child: Text(
          value.isEmpty ? 'Избери град' : value,
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ), // Display selected city with Montserrat font
        ),
      ),
    );
  }

  Future<void> _navigateAndDisplaySelection(
      BuildContext context, List<String> cities, bool isDepartureCity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CitySearchPage(cities: cities)),
    );

    // Use the result to update your state and UI
    if (result != null) {
      setState(() {
        if (isDepartureCity) {
          _departureCity = result;
        } else {
          _arrivalCity = result;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneNumber();
  }

  Future<void> _fetchUserPhoneNumber() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _phoneNumber = userData['phoneNumber'] ?? '';
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && user != null) {
      // Fetch the user's data again to ensure it is up-to-date
      final userDoc = await _db.collection('users').doc(user!.uid).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Корисничкиот профил не постои.')),
        );
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final isPhoneVerified = userData['isPhoneVerified'] ?? false;

      // Check if the phone number is verified
      if (!isPhoneVerified) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Верификација на Телефонски Број'),
              content: const Text(
                  'Вашиот телефонски број не е верификуван. Ве молиме верификувајте го за да објавите понуда.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Во ред'),
                ),
              ],
            );
          },
        );
        return; // Stop the submission process
      }

      // Proceed with the submission if the phone number is verified
      setState(() {
        _isSubmitting = true; // Disable the button while submitting
      });

      try {
        // Generate a new UUID for the offerId
        var uuid = const Uuid();
        String offerId = uuid.v4();

        DateTime fullDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        );

        Timestamp dateTimestamp = Timestamp.fromDate(_date);
        Timestamp timeTimestamp = Timestamp.fromDate(fullDateTime);

        final offer = {
          'userId': user!.uid,
          'departureCity': _departureCity,
          'arrivalCity': _arrivalCity,
          'carModel': _carModel,
          'phoneNumber': _phoneNumber,
          'description': _description,
          'seats': _seats,
          'price': _price,
          'date': dateTimestamp,
          'time': timeTimestamp,
        };

        // Store the offer in Firestore using the generated offerId
        await _db.collection('offers').doc(offerId).set(offer);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Превоз објавен!')),
        );

        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        print('Error creating offer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating offer: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false; // Re-enable the button after submission
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ве молиме потполнете ги сите полиња')),
      );
    }
  }

  // Helper method to build TextFormField
  Widget buildTextFormField({
    TextEditingController? controller,
    required String labelText,
    TextInputType? keyboardType,
    bool readOnly = false,
    GestureTapCallback? onTap,
    ValueChanged<String>? onChanged,
    int? maxLines,
    Widget? suffixIcon,
    String? hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            GoogleFonts.montserrat(color: Colors.black), // Use Montserrat font
        fillColor: Colors.white, // White background color
        filled: true, // Enable the fillColor
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          // Use BorderSide.none for no border
        ),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(
            color: Colors.grey), // Optional: Montserrat for hintText
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      style: GoogleFonts.montserrat(
          color: Colors.black), // Optional: Montserrat for input text
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      validator: validator,
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (pickedTime != null && pickedTime != _time) {
      setState(() {
        _time = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the background color you want for OffersPage
    const Color offersBackgroundColor = Color.fromARGB(253, 255, 166, 0);

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
      childContent = Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                // From Field - Departure City
                buildCityField(
                  labelText: 'Од',
                  value: _departureCity,
                  isDepartureCity: true,
                ),
                const SizedBox(height: 10),

                // To Field - Arrival City
                buildCityField(
                  labelText: 'До',
                  value: _arrivalCity,
                  isDepartureCity: false,
                ),
                const SizedBox(height: 10),

                // Date and Time Fields
                Row(
                  children: [
                    Expanded(
                      child: buildTextFormField(
                        controller: TextEditingController(
                            text: "${_date.toLocal()}".split(' ')[0]),
                        labelText: 'Датум',
                        onTap: () => selectDate(context),
                        readOnly: true,
                        suffixIcon: const Icon(Icons.calendar_today),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Задолжително';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Give some spacing between the fields
                    Expanded(
                      child: buildTextFormField(
                        controller:
                            TextEditingController(text: _time.format(context)),
                        labelText: 'Час',
                        onTap: () => selectTime(context),
                        readOnly: true,
                        suffixIcon: const Icon(Icons.access_time),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Задолжително';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Free Seats and Price Fields
                Row(
                  children: [
                    Expanded(
                      child: buildTextFormField(
                        controller: TextEditingController(),
                        labelText: 'Слободни места',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _seats = int.tryParse(value) ?? 1,
                        suffixIcon: const Icon(Icons.group),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Задолжително';
                          }
                          final intSeats = int.tryParse(value);
                          if (intSeats == null) {
                            return 'Одбери валиден број';
                          }
                          if (intSeats < 1 || intSeats > 10) {
                            return 'Помеѓу 1 и 10';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Give some spacing between the fields
                    Expanded(
                      child: buildTextFormField(
                        controller: TextEditingController(), // Empty controller
                        labelText: 'Цена',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _price = int.tryParse(value) ?? 0,
                        suffixIcon: const Icon(Icons.attach_money),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Задолжително';
                          }
                          if (value.length > 4) {
                            return 'Ве молиме одберете пониска цена.';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Одбери валиден број';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Car Model Field
                buildTextFormField(
                  controller: TextEditingController(text: _carModel),
                  labelText: 'Возило',
                  onChanged: (value) => _carModel = value,
                  textCapitalization: TextCapitalization.words,
                  suffixIcon: const Icon(Icons.directions_car),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ве молиме напишете модел на кола';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Description Field
                buildTextFormField(
                  controller: TextEditingController(text: _description),
                  labelText: 'Додатен опис (опционално)',
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) => _description = value,
                  validator: (value) {
                    // Remove mandatory validation by returning null regardless of the input
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 125,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color.fromARGB(255, 43, 255, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          )
                        : Text(
                            'Објави',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const WaveAppBar(),
      body: SnowfallBackground(
        backgroundColor:
            const Color.fromARGB(253, 255, 166, 0), // Solid background color
        child: user == null || user!.isAnonymous
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 240),
                  child: Container(
                    padding: const EdgeInsets.all(
                        32.0), // Increased padding for larger card
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the card
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Slight shadow
                          blurRadius:
                              15.0, // Larger blur radius for better shadow
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
                            padding: const EdgeInsets.all(
                                10.0), // Padding inside the circle
                            child: SvgPicture.asset(
                              'assets/logoSadChristmas.svg', // Replace with your asset path
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(
                            height:
                                24.0), // Larger spacing between logo and text
                        Text(
                          'Ве молиме',
                          style: GoogleFonts.montserrat(
                            color: const Color.fromARGB(255, 34, 34, 34),
                            fontSize: 23.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                            height:
                                24.0), // Larger spacing between text and button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 226, 226, 226), // Light grey background
                            foregroundColor: Colors.black, // Text color
                            elevation: 8, // Add shadow effect
                            shadowColor:
                                Colors.black.withOpacity(0.4), // Shadow color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  16.0), // Rounded corners
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
              )
            : childContent, // Logged-in user content
      ),
    );
  }
}
