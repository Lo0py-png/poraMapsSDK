// lib/OfferDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EditOfferPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart'; // Import the login page
import 'native_bridge.dart'; // Import the native_bridge.dart file

class OfferDetailsPage extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId;

  OfferDetailsPage({Key? key, required Map<String, dynamic> offer})
      : offerData = offer['offer'],
        offerId = offer['offerId'],
        super(key: key);

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final NativeBridge _nativeBridge = NativeBridge();

  Future<String> getUserName(String userId) async {
    var userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      return userSnapshot.data()!['name'] ?? 'No name';
    } else {
      return 'No name';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Потврди бришење'),
          content: const Text(
              'Дали сте сигурни дека сакате да ја избришете оваа понуда?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Откажи'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);

                // Delete the document from Firestore
                await FirebaseFirestore.instance
                    .collection('offers')
                    .doc(offerId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Огласот е успешно избришан.')),
                );

                Navigator.of(context).pop(); // Go back to the previous screen
              },
              child: const Text('Избриши'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offerId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Огласот е успешно избришан')),
      );

      Navigator.of(context).pop(); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString = offerData['time'] != null
        ? DateFormat('HH:mm').format(offerData['time'].toDate())
        : 'Not specified';

    // Format the date in Macedonian locale and use Montserrat font
    final String formattedDate = offerData['date'] != null
        ? DateFormat('EEEE, dd.MM.', 'mk').format(offerData['date'].toDate())
        : 'Date not specified';

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
            formattedDate,
            style: GoogleFonts.montserrat(
              color: const Color.fromARGB(255, 34, 34, 34),
              fontSize: 25.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          elevation: 0.0, // Customize as needed
        ),
      ),
      body: FutureBuilder<String>(
        future: getUserName(offerData['userId']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching driver name'));
          }

          String driverName = snapshot.data ?? 'Unavailable';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Од',
                            style: GoogleFonts.montserrat(
                                fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            '${offerData['departureCity']}',
                            style: GoogleFonts.montserrat(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(width: 75),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'До',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            Text(
                              '${offerData['arrivalCity']}',
                              style: GoogleFonts.montserrat(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Час',
                              style: GoogleFonts.montserrat(
                                  fontSize: 15, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(timeString,
                                    style:
                                        GoogleFonts.montserrat(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Слободни места',
                              style: GoogleFonts.montserrat(
                                  fontSize: 15, color: Colors.grey),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.group, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('${offerData['seats']}',
                                    style:
                                        GoogleFonts.montserrat(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Цена',
                              style: GoogleFonts.montserrat(
                                  fontSize: 15, color: Colors.grey),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.payments, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text('${offerData['price']}den.',
                                    style:
                                        GoogleFonts.montserrat(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Возач',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(driverName,
                                    style:
                                        GoogleFonts.montserrat(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Возило',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.directions_car,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('${offerData['carModel']}',
                                    style:
                                        GoogleFonts.montserrat(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPhoneNumberSection(context),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Додатен опис',
                            style: GoogleFonts.montserrat(
                                fontSize: 16, color: Colors.grey)),
                      ),
                      const Icon(Icons.comment, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    offerData['description'] ?? 'No Description',
                    style: GoogleFonts.montserrat(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 10),
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                  // Add the "Show Route" button here
                  ElevatedButton(
                    onPressed: () {
                      String departure = offerData['departureCity'];
                      String arrival = offerData['arrivalCity'];
                      _nativeBridge.showRoute(departure, arrival);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text(
                      'Прикажи патека',
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneNumberSection(BuildContext context) {
    final String userId = offerData['userId'] ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Text(
            'Корисничките информации не можат да се вчитаат.',
            style: TextStyle(color: Colors.red),
          );
        }

        // Retrieve user data
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String? messengerLink = userData['messenger'];
        final bool isViberEnabled = userData['viber'] ?? false;
        final bool isWhatsAppEnabled = userData['whatsapp'] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Телефонски бр.',
                  style:
                      GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
                ),
                if (messengerLink != null && messengerLink.isNotEmpty)
                  Text(
                    'Messenger',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Number and Logo Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      offerData['phoneNumber'] ?? 'Unavailable',
                      style: GoogleFonts.montserrat(fontSize: 18),
                    ),
                  ],
                ),
                if (messengerLink != null && messengerLink.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final Uri messengerUri = Uri.parse(messengerLink);

                      // Ensure the URI starts with "https://"
                      final Uri normalizedUri = messengerUri.hasScheme
                          ? messengerUri
                          : Uri.parse("https://${messengerUri.toString()}");

                      if (await canLaunchUrl(normalizedUri)) {
                        await launchUrl(normalizedUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Не можам да го отворам Messenger линкот'),
                          ),
                        );
                      }
                    },
                    child: Image.asset(
                      'assets/messenger_logo.png', // Replace with your Messenger logo path
                      width: 40,
                      height: 40,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Availability Section
            if (isViberEnabled || isWhatsAppEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Достапен/на на',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (isViberEnabled)
                        Row(
                          children: [
                            Image.asset(
                              'assets/viber_logo.png', // Replace with your Viber logo path
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      if (isWhatsAppEnabled)
                        Row(
                          children: [
                            Image.asset(
                              'assets/whatsapp_logo.png', // Replace with your WhatsApp logo path
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (currentUserId == offerData['userId']) {
      // User is the owner of the offer, show Edit and Delete buttons
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditOfferPage(
                      offerData: offerData,
                      offerId: offerId,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Измени',
                    style: GoogleFonts.montserrat(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _confirmDelete(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Избриши',
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (isLoggedIn) {
      // User is logged in but not the owner, show the Call and SMS buttons
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _makePhoneCall(offerData['phoneNumber'] ?? ''),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Јави се',
                    style: GoogleFonts.montserrat(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.phone, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _sendSMS(offerData['phoneNumber'] ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Прати SMS',
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chat, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // User is not logged in, hide the buttons and show no extra text
      return const SizedBox.shrink();
    }
  }
}
