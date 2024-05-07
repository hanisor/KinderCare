import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindercare/caregiverScreen/caregiver_profile.dart';
import 'package:kindercare/request_controller.dart';

import '../splash_screen.dart';

class CaregiverEditProfile extends StatefulWidget {
  final int? caregiverId;
  const CaregiverEditProfile({Key? key, this.caregiverId});

  @override
  _CaregiverEditProfileState createState() => _CaregiverEditProfileState();
}

class _CaregiverEditProfileState extends State<CaregiverEditProfile> {
  TextEditingController caregiverNameController = TextEditingController();
  TextEditingController caregiverEmailController = TextEditingController();
  TextEditingController caregiverIcController = TextEditingController();
  TextEditingController caregiverPhoneController = TextEditingController();
  TextEditingController caregiverUsernameController = TextEditingController();
  String caregiverUsername = '';
  String caregiverName = '';
  String caregiverIcNumber = '';
  String caregiverEmail = '';
  String caregiverPhoneNumber = '';
  int? caregiverId;

  Future<Map<String, dynamic>> getCaregiverDetails(String? email) async {
    print('email : $email');
    RequestController req =
        RequestController(path: 'caregiver/by-email?email=$email');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load parent details');
    }
  }

  Future<void> fetchCaregiverDetails() async {
    try {
      final data = await getCaregiverDetails(finalEmail!);
      print('Response Data: $data');
      setState(() {
        caregiverUsername = data['username'];
        caregiverName = data['name'];
        caregiverIcNumber = data['ic_number'];
        caregiverPhoneNumber = data['phone_number'];
        caregiverEmail = data['email'];
        caregiverId = data['id'];
        print('Fetched Caregiver ID: $caregiverId');
      });
    } catch (error) {
      print('Error fetching caregiver details: $error');
    }
  }

  Future<void> caregiverEdit(int? caregiverId) async {
    String caregiverName = caregiverNameController.text.trim();
    String caregiverIcNumber = caregiverIcController.text.trim();
    String caregiverEmail = caregiverEmailController.text.trim();
    String caregiverUsername = caregiverUsernameController.text.trim();
    String caregiverPhoneNumber = caregiverPhoneController.text.trim();

    print('Caregiver ID to update: ${caregiverId}');
    print(
        'New data - Name: $caregiverName, IC: $caregiverIcNumber, Email: $caregiverEmail, Username: $caregiverUsername, Phone: $caregiverPhoneNumber');

    RequestController req =
        RequestController(path: 'caregiver/update-profile/$caregiverId');

    await req.setBody({
      "id": caregiverId,
      "name": caregiverName,
      "ic_number": caregiverIcNumber,
      "phone_number": caregiverPhoneNumber,
      "email": caregiverEmail,
      "username": caregiverUsername,
    });

    print("caregiverId : ${caregiverId}");
    await req.put();

    print(req.result());


    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: "This data failed to be updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.pinkAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Edit successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.pinkAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    caregiverNameController.dispose();
    caregiverUsernameController.dispose();
    caregiverIcController.dispose();
    caregiverPhoneController.dispose();
    caregiverEmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    caregiverNameController = TextEditingController(text: '');
    caregiverUsernameController = TextEditingController(text: '');
    caregiverIcController = TextEditingController(text: '');
    caregiverPhoneController = TextEditingController(text: '');
    caregiverEmailController = TextEditingController(text: '');
    fetchCaregiverDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.saira(
                      // Use GoogleFonts.lato for the 'Edit Profile' text
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: '$caregiverName',
                      ),
                      controller: caregiverNameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: '$caregiverUsername',
                      ),
                      controller: caregiverUsernameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        hintText: '$caregiverIcNumber',
                      ),
                      controller: caregiverIcController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.phone_iphone),
                        hintText: '$caregiverPhoneNumber',
                      ),
                      controller: caregiverPhoneController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.email_rounded),
                        hintText: '$caregiverEmail',
                      ),
                      controller: caregiverEmailController,
                    ),
                  ),
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
                        onPressed: () {
                          setState(() {
                            caregiverEdit(caregiverId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CaregiverProfile(),
                              ),
                            );
                          });
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
