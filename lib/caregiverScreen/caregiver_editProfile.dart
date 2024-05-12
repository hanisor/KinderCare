import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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
        RequestController(path: 'caregiver-byEmail?email=$email');

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

  /*  Future<void> caregiverEdit(int? caregiverId) async {
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
  } */

  Future<void> caregiverUpdate(
    int? caregiverId,
    String currentName,
    String currentUsername,
    String currentIC,
    String currentPhone, {
    String? newName,
    String? newUsername,
    String? newIC,
    String? newPhone,
  }) async {
    Map<String, dynamic> requestData = {
      "id": caregiverId,
      if (newName != null) "name": newName,
      if (newUsername != null) "username": newUsername,
      if (newIC != null) "ic_number": newIC,
      if (newPhone != null) "phone_number": newPhone,
    };

    // Make sure the requestData contains at least one field to update
    if (requestData.isEmpty) {
      print("No fields to update");
      return;
    }

    RequestController req =
        RequestController(path: 'caregiver/update-profile/$caregiverId');
    req.setBody(requestData); // Set request body with updated data

    try {
      await req.put(); // Perform the PUT request
      print(req.result()); // Print the result of the request

      if (req.status() == 200) {
        print("caregiverId: ${caregiverId}");
        print("HTTP Response: ${req.status()}");
        var data = req.result();
        if (data == "Error") {
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
            backgroundColor: Colors.green, // Change to green for success
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        // Handle HTTP error
        print("HTTP request failed with status code: ${req.status()}");
        Fluttertoast.showToast(
          msg: "HTTP request failed with status code: ${req.status()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red, // Change to red for error
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print("Error updating parent: $e");
      // Handle any errors that occur during the request
      Fluttertoast.showToast(
        msg: "An error occurred while updating",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red, // Change to red for error
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
                        onPressed: () async {
                          try {
                            setState(() {
                              // Get the updated values from text controllers
                              String newName =
                                  caregiverNameController.text.trim();
                              String newUsername =
                                  caregiverUsernameController.text.trim();
                              String newIC = caregiverIcController.text.trim();
                              String newPhone =
                                  caregiverPhoneController.text.trim();

                              // Call the update function with existing data for fields that are not being updated
                              caregiverUpdate(
                                caregiverId,
                                caregiverName, // Existing name
                                caregiverUsername, // Existing username
                                caregiverIcNumber, // Existing IC number
                                caregiverPhoneNumber, // Existing phone number
                                newName: newName.isNotEmpty
                                    ? newName
                                    : null, // Updated name if provided
                                newUsername: newUsername.isNotEmpty
                                    ? newUsername
                                    : null, // Updated username if provided
                                newIC: newIC.isNotEmpty
                                    ? newIC
                                    : null, // Updated IC number if provided
                                newPhone: newPhone.isNotEmpty
                                    ? newPhone
                                    : null, // Updated phone number if provided
                              );
                            });
                            Navigator.pop(context);
                          } catch (e) {
                            print('Navigation error: $e');
                          }
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
