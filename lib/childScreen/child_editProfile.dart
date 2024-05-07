import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

class ChildEditProfile extends StatefulWidget {
  final int? childId;
  ChildEditProfile({Key? key, this.childId});

  @override
  _ChildEditProfileState createState() => _ChildEditProfileState();
}

class _ChildEditProfileState extends State<ChildEditProfile> {
  TextEditingController childNameController = TextEditingController();
  TextEditingController childMykidNumberController = TextEditingController();
  TextEditingController childAgeController = TextEditingController();
  TextEditingController childGenderController = TextEditingController();
  TextEditingController childAllergiesController = TextEditingController();
  String childName = '';
  String childMykidNumber = '';
  String childAge = '';
  String childGender = '';
  String childAllergies = '';
  String childId = '';

  Future<Map<String, dynamic>> getChildrenDetails(int? childId) async {
    var url = Uri.parse('http://172.20.10.3/xampp/fyp/child_controller_layer/read_child_childId.php?childId=$childId'); // Pass email as parameter
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load child details');
    }
  }

  Future<void> fetchChildrenDetails() async {
    try {
      final data = await getChildrenDetails(widget.childId);
      print('Response Data: $data');
      setState(() {
        childMykidNumber = data['childMykidNumber'];
        childName = data['childName'];
        childAge = data['childAge'];
        childGender = data['childGender'];
        childAllergies = data['childAllergies'];
        childId = data['childId'];
        print('Fetched child ID: $childId');
      });
    } catch (error) {
      print('Error fetching child details: $error');
    }
  }

  Future<void> childUpdate(String childId, String currentName,
      String currentMykidNumber, String currentAge, String currentGender,
      String currentAllergies, {String? newName, String? newMykidNumber,
        String? newAge, String? newGender, String? newALlergies}) async {
    Map<String, dynamic> requestData = {
      "childId": childId,
      "childName": newName ?? currentName, // If newName is null, use currentName
      "childMykidNumber": newMykidNumber ?? currentMykidNumber,
      "childAge": newAge ?? currentAge,
      "childGender": newGender ?? currentGender,
      "childAllergies": newALlergies ?? currentAllergies,
    };

    var url = Uri.parse("http://172.20.10.3/xampp/fyp/child_controller_layer/update_child.php");
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json', // Set content-type to JSON
      },
      body: jsonEncode(requestData),
    );

    print("childId : ${childId}");
    print("HTTP Response: ${response.statusCode}");
    print("Response Body: ${response.body}");
    var data = json.decode(response.body);
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
        backgroundColor: Colors.pinkAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  @override
  void dispose() {
    childNameController.dispose();
    childMykidNumberController.dispose();
    childAgeController.dispose();
    childGenderController.dispose();
    childAllergiesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    childNameController = TextEditingController(text:'');
    childMykidNumberController = TextEditingController(text:'');
    childAgeController = TextEditingController(text:'');
    childGenderController = TextEditingController(text:'');
    childAllergiesController = TextEditingController(text: '');
    fetchChildrenDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit profile'),
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
                    style: GoogleFonts.saira( // Use GoogleFonts.lato for the 'Edit Profile' text
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: '$childName',
                      ),
                      controller: childNameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: '$childMykidNumber',
                      ),
                      controller: childMykidNumberController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        hintText: '$childAge',
                      ),
                      controller: childAgeController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.phone_iphone),
                        hintText: '$childGender',
                      ),
                      controller: childGenderController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        prefixIcon: const Icon(Icons.email_rounded),
                        hintText: '$childAllergies',
                      ),
                      controller: childAllergiesController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          backgroundColor: MaterialStateProperty.all(Colors.pinkAccent),
                        ),
                        onPressed: () async {
                          try {
                            setState(() {
                              // Get the updated values from text controllers
                              String newName = childNameController.text.trim();
                              String newMykidNumber = childMykidNumberController.text.trim();
                              String newAge = childAgeController.text.trim();
                              String newGender = childGenderController.text.trim();
                              String newALlergies = childAllergiesController.text.trim();

                              // Call the update function with existing data for fields that are not being updated
                              childUpdate(
                                childId,
                                childName, // Existing name
                                childMykidNumber, // Existing username
                                childAge, // Existing IC number
                                childGender, // Existing phone number
                                childAllergies, // Existing email
                                newName: newName.isNotEmpty ? newName : null, // Updated name if provided
                                newMykidNumber: newMykidNumber.isNotEmpty ? newMykidNumber : null, // Updated username if provided
                                newAge: newAge.isNotEmpty ? newAge : null, // Updated IC number if provided
                                newGender: newGender.isNotEmpty ? newGender : null, // Updated phone number if provided
                                newALlergies: newALlergies.isNotEmpty ? newALlergies : null, // Updated email if provided
                              );
                            });

                            // Navigate back to the child profile page after saving
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
