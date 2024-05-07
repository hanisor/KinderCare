import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:kindercare/caregiverScreen/caregiver_login.dart';

class CaregiverRegistration extends StatefulWidget {
  const CaregiverRegistration({Key? key}) : super(key: key);

  @override
  State<CaregiverRegistration> createState() => _CaregiverRegistrationState();
}

class _CaregiverRegistrationState extends State<CaregiverRegistration> {
  var caregiverEmailEditCtrl = TextEditingController();
  var caregiverNameEditCtrl = TextEditingController();
  var caregiverUsernameEditCtrl = TextEditingController();
  var caregiverPassEditCtrl = TextEditingController();
  var caregiverRePassEditCtrl = TextEditingController();
  var caregiverIcEditCtrl = TextEditingController();
  var caregiverPhoneEditCtrl = TextEditingController();
  var caregiverImageEditCtrl = TextEditingController();
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  int? caregiverId;

  void _showRegistrationFailedDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  bool isPasswordStrong(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  Future<int> fetchCaregiverDetails() async {
    try {
      final data = await getCaregiverDetails(caregiverEmailEditCtrl.text);
      print('Response Data: $data');
      final caregiverId = data['id'];
      setState(() {
        this.caregiverId = caregiverId;
        print('caregiver Id after setState: $caregiverId');
      });
      return caregiverId; // Return caregiverId
    } catch (error) {
      print('Error fetching caregiver details: $error'); // Print error to debug
      throw error; // Re-throw the error
    }
  }

  Future<Map<String, dynamic>> getCaregiverDetails(String email) async {
    var url = Uri.parse('http://172.20.10.3:8000/caregiver/by-email?email=$email'); // Pass email as parameter
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // Caregiver retrieved successfully
      final caregiver = json.decode(response.body);
      print('Caregiver: $caregiver');
      // Return the caregiver data
      return caregiver;
    } else {
      // Error occurred
      print('Failed to get caregiver: ${response.reasonPhrase}');
      // Return null or throw an exception, depending on your requirements
      throw Exception('Failed to get caregiver: ${response.reasonPhrase}');
    }
  }

  Future<void> caregiverRegister() async {
    String caregiverEmail = caregiverEmailEditCtrl.text.trim();
    String caregiverName = caregiverNameEditCtrl.text.trim();
    String caregiverUsername = caregiverUsernameEditCtrl.text.trim();
    String caregiverPass = caregiverPassEditCtrl.text.trim();
    String caregiverRePass = caregiverRePassEditCtrl.text.trim();
    String caregiverIc = caregiverIcEditCtrl.text.trim();
    String caregiverPhone = caregiverPhoneEditCtrl.text.trim();
    String caregiverImage = caregiverImageEditCtrl.text.trim();

    if (caregiverEmail.isEmpty ||
        caregiverName.isEmpty ||
        caregiverUsername.isEmpty ||
        caregiverPass.isEmpty ||
        caregiverRePass.isEmpty ||
        caregiverIc.isEmpty ||
        caregiverPhone.isEmpty) {
      _showRegistrationFailedDialog(context, 'Please fill in all the details');
    } else if (caregiverPass != caregiverRePass) {
      _showRegistrationFailedDialog(context, 'The password did not match.');
    } else if (!isPasswordStrong(caregiverPass)) {
      _showRegistrationFailedDialog(
          context,
          'The password is not strong enough. '
          'Please ensure it meets the strength criteria.');
      return;
    } else {
      var url = Uri.parse(
          "http://172.20.10.3:8000/caregiver/register");
      var response = await http.post(url, body: {
        "name": caregiverName,
        "ic_number": caregiverIc,
        "phone_number": caregiverPhone,
        "email": caregiverEmail,
        "username": caregiverUsername,
        "password": caregiverPass,
        "status": "ACTIVE",
        "role": "CAREGIVER",
        "image": caregiverImage,
      });

      print("Response: ${response.body}");
      var data = json.decode(response.body);
      if (data == "Error") {
        _showRegistrationFailedDialog(
            context, 'Registration failed. Please try again.');
      } else {
        var caregiverIdFuture =
            fetchCaregiverDetails(); // Get the Future<String>
        int caregiverId =
            await caregiverIdFuture; // Wait for the Future<String> to complete
        print("caregiverID = $caregiverId");
        Fluttertoast.showToast(
          msg: "Registration successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.push(
            context,MaterialPageRoute(
            builder: (context) => CaregiverLogin(),
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCaregiverDetails();
    print('InitState: caregiverId: $caregiverId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Caregiver Registration",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create caregiver account',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'Enter your email',
                  ),
                  controller: caregiverEmailEditCtrl,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Enter your name',
                  ),
                  controller: caregiverNameEditCtrl,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Enter your username',
                  ),
                  controller: caregiverUsernameEditCtrl,
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Enter your IC number',
                  ),
                  controller: caregiverIcEditCtrl,
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                    hintText: 'Enter your phone number',
                  ),
                  controller: caregiverPhoneEditCtrl,
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.image_outlined),
                    hintText: 'Enter image URL',
                  ),
                  controller: caregiverImageEditCtrl,
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      obscureText: _obscurePassword1,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.password_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword1 = !_obscurePassword1;
                            });
                          },
                          icon: _obscurePassword1
                              ? const Icon(Icons.visibility_off_outlined)
                              : const Icon(Icons.visibility_outlined),
                        ),
                        hintText: 'Enter your password',
                      ),
                      controller: caregiverPassEditCtrl,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please ensure that your password meets the following criteria:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('- Minimum 8 characters long'),
                    const Text('- Contains a mix of uppercase and lowercase letters'),
                    const Text(
                        '- Includes numbers and special characters (!@#%^&*(),.?":{}|<>)'),
                    const Text('- Avoids common patterns and dictionary words'),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: _obscurePassword2,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 3,
                        color: Colors.pinkAccent,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    prefixIcon: const Icon(Icons.password_outlined),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword2 = !_obscurePassword2;
                        });
                      },
                      icon: _obscurePassword2
                          ? const Icon(Icons.visibility_off_outlined)
                          : const Icon(Icons.visibility_outlined),
                    ),
                    hintText: 'Re-Enter your password',
                  ),
                  controller: caregiverRePassEditCtrl,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.pinkAccent),
                      ),
                      onPressed: () async {
                        caregiverRegister();
                      },
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
