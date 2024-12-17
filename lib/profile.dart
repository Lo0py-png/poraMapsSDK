// profile_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:url_launcher/url_launcher.dart';

import 'otp_verification.dart';
import 'snowfall2.dart'; // Import the SnowfallBackground widget

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Stream<DocumentSnapshot>? _userDocStream;

  Future<DocumentSnapshot?> fetchData() async {
    if (user != null) {
      if (!user!.isAnonymous) {
        final userProfile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        return userProfile;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _userDocStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots();
    }
  }

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImageToFirebase(imageFile);
      setState(() {}); // Refresh the profile page to show the new image
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No need to reload or fetch user data here
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef =
        _storage.ref().child('profilePictures/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String newImageUrl = await taskSnapshot.ref.getDownloadURL();

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'imageUrl': newImageUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.isAnonymous) {
      // User is not logged in or is anonymous
      return Scaffold(
        body: SnowfallBackground(
          backgroundColor: const Color.fromARGB(
              252, 255, 255, 255), // Match the gradient color
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
                  gradientBegin: Alignment.centerLeft,
                  gradientEnd: Alignment.centerRight,
                  durations: [9500, 15500],
                  heightPercentages: [0.25, 0.33],
                ),
                size: const Size(double.infinity, double.infinity),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 250),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 64.4),
                      const CircleAvatar(
                        radius: 90,
                        backgroundImage:
                            AssetImage('assets/logoplaceholderchristmas.png'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Upsy.',
                        style: GoogleFonts.montserrat(
                          color: const Color.fromARGB(255, 34, 34, 34),
                          fontSize: 38.0,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shadowColor: Colors.grey,
                          elevation: 10,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          'Започни овде!',
                          style: GoogleFonts.montserrat(
                            color: const Color.fromARGB(255, 34, 34, 34),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // User is logged in
    return StreamBuilder<DocumentSnapshot?>(
      stream: _userDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.data == null || !snapshot.data!.exists) {
          return const Center(
              child: Text('No user data available. Please log in.'));
        }

        final userProfile =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};
        String imageUrl = userProfile['imageUrl'] ?? 'assets/placeholder.png';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Профил',
              style: GoogleFonts.montserrat(
                color: Colors.black, // Black text
                fontSize: 40.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(
                              253, 255, 166, 0), // Orange border
                          width: 4.0,
                        ),
                      ),
                      child: ClipOval(
                        child: imageUrl.isNotEmpty &&
                                imageUrl != 'assets/placeholder.png'
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                buildProfileSection(userProfile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _userInfoCard(String title, String value,
      {bool isEditable = true, Function? editAction}) {
    return Card(
      elevation: 8.0,
      color: const Color.fromARGB(255, 245, 180, 0),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 16.0,
          ),
        ),
        trailing: isEditable ? const Icon(Icons.edit) : null,
        onTap: isEditable ? () => editAction!() : null,
      ),
    );
  }

  Widget buildProfileSection(Map<String, dynamic> userProfile) {
    String phoneNumber = userProfile['phoneNumber'] ?? '';
    bool isPhoneVerified = userProfile['isPhoneVerified'] ?? false;
    String messengerLink = userProfile['messenger'] ?? '';
    bool isViberEnabled = userProfile['viber'] ?? false;
    bool isWhatsAppEnabled = userProfile['whatsapp'] ?? false;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 32.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _userInfoCard('Име', userProfile['name'] ?? 'N/A',
                editAction: () =>
                    _showEditDialog('name', userProfile['name'] ?? 'N/A')),
            _userInfoCard('Презиме', userProfile['surname'] ?? 'N/A',
                editAction: () => _showEditDialog(
                    'surname', userProfile['surname'] ?? 'N/A')),
            _userInfoCard('Емаил', userProfile['email'] ?? 'N/A',
                isEditable: false), // Email is not editable
            _userInfoCard(
              'Телефон',
              phoneNumber.isNotEmpty ? phoneNumber : 'Внесете телефонски број',
              isEditable: phoneNumber.isEmpty, // Only editable if missing
              editAction: () => _showEditDialog('Телефон', phoneNumber),
            ),
            if (phoneNumber.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Телефонскиот број мора да започне со 07 и да има 9 цифри.',
                  style: GoogleFonts.montserrat(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
              ),
            if (!isPhoneVerified && phoneNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OTPVerificationPage(
                          phoneNumber: phoneNumber,
                          userId: user!.uid,
                        ),
                      ),
                    );
                    if (result == true) {
                      // Refresh the profile data
                      setState(() {});
                    }
                  },
                  child: Text(
                    'Вашиот телефонски број не е верификуван. Кликнете тука за верификација.',
                    style: GoogleFonts.montserrat(
                      color: Colors.red,
                      fontSize: 14.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Communication Options Section
            Text(
              'Останати начини за комуницирање',
              style: GoogleFonts.montserrat(
                color: const Color.fromARGB(255, 34, 34, 34),
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Messenger Section
                Image.asset(
                  'assets/messenger_logo.png', // Replace with your Messenger logo path
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: messengerLink),
                    onChanged: (value) async {
                      messengerLink = value;
                      if (value.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({'messenger': messengerLink});
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Messenger линкот е зачуван!'),
                        ));
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Messenger Линк',
                      labelStyle: GoogleFonts.montserrat(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Messenger > Menu > Settings > QR Code > Share > Copy',
              style: GoogleFonts.montserrat(
                fontSize: 11.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Имате Viber или Whatsapp?',
              style: GoogleFonts.montserrat(
                color: const Color.fromARGB(255, 34, 34, 34),
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Viber Section
                Row(
                  children: [
                    Image.asset(
                      'assets/viber_logo.png', // Replace with your Viber logo path
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: isViberEnabled,
                      onChanged: (value) async {
                        isViberEnabled = value ?? false;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({'viber': isViberEnabled});
                        setState(() {});
                      },
                    ),
                  ],
                ),

                Row(
                  children: [
                    Image.asset(
                      'assets/whatsapp_logo.png', // Replace with your WhatsApp logo path
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: isWhatsAppEnabled,
                      onChanged: (value) async {
                        isWhatsAppEnabled = value ?? false;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({'whatsapp': isWhatsAppEnabled});
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Picture Section
            Center(
              child: ElevatedButton(
                onPressed: _changeProfilePicture,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                ),
                child: Text('Смени профилна слика',
                    style: GoogleFonts.montserrat(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    setState(() {
                      user = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Одјава',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLinksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksSection() {
    return Column(
      children: [
        _linkTile('За Нас', 'https://upsy.mk/about-us'),
        _linkTile('Правила и Услови', 'https://upsy.mk/terms-and-conditions'),
        _linkTile('Политика на Приватност', 'https://upsy.mk/privacy-policy'),
        _linkTile('Контакт', 'https://upsy.mk/contact'),
      ],
    );
  }

  Widget _linkTile(String title, String url) {
    return Card(
      elevation: 8.0,
      color: const Color.fromARGB(255, 245, 180, 0),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 34, 34, 34),
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
    );
  }

  Future<void> _showEditDialog(String field, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    String errorMessage = '';

    // Map field to a more descriptive title
    String dialogTitle;
    switch (field) {
      case 'name':
        dialogTitle = 'Измени Име';
        break;
      case 'surname':
        dialogTitle = 'Измени Презиме';
        break;
      case 'email':
        dialogTitle = 'Измени Емаил';
        break;
      case 'Телефон':
        dialogTitle = 'Измени Телефон';
        break;
      default:
        dialogTitle = 'Измени Податок';
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: controller,
                  keyboardType: field == 'Телефон'
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Внесете ново $dialogTitle',
                    errorText: errorMessage.isEmpty ? null : errorMessage,
                  ),
                  onChanged: (value) {
                    if (field == 'Телефон') {
                      if (!RegExp(r'^07\d{7}$').hasMatch(value)) {
                        setState(() {
                          errorMessage =
                              'Телефонскиот број мора да започне со 07 и да има точно 9 цифри.';
                        });
                      } else {
                        setState(() {
                          errorMessage = '';
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Откажи'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Зачувај'),
              onPressed: () async {
                if (field == 'Телефон' &&
                    !RegExp(r'^07\d{7}$').hasMatch(controller.text)) {
                  setState(() {
                    errorMessage =
                        'Телефонскиот број мора да започне со 07 и да има точно 9 цифри.';
                  });
                } else {
                  await _updateUserInfo(field, controller.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserInfo(String field, String newValue) async {
    if (user != null) {
      if (field == 'Телефон') {
        field = 'phoneNumber';
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        field: newValue,
      });
      setState(() {}); // Trigger a rebuild
    }
  }
}
