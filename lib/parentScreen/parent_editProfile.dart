import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindercare/request_controller.dart';
import '../splash_screen.dart';

class ParentEditProfile extends StatefulWidget {
  final int? parentId;
  ParentEditProfile({Key? key, this.parentId});

  @override
  _ParentEditProfileState createState() => _ParentEditProfileState();
}

class _ParentEditProfileState extends State<ParentEditProfile> {
  TextEditingController parentNameController = TextEditingController();
  TextEditingController parentEmailController = TextEditingController();
  TextEditingController parentIcController = TextEditingController();
  TextEditingController parentPhoneController = TextEditingController();
  TextEditingController parentUsernameController = TextEditingController();
  String parentUsername = '';
  String parentName = '';
  String parentIcNumber = '';
  String parentEmail = '';
  String parentPhoneNumber = '';
  String parentId = '';

  Future<Map<String, dynamic>> getParentDetails(String? email) async {
    if (email == null) {
      throw Exception('Email is null');
    }

    print('email : $email');
    RequestController req =
        RequestController(path: 'guardian-byEmail?email=$email');
    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load parent details');
    }
  }

  Future<void> fetchParentDetails() async {
    try {
      final data = await getParentDetails(finalEmail!);
      print('Response Data: $data');
      setState(() {
        parentUsername = data['username'];
        parentName = data['name'];
        parentIcNumber = data['ic_number'];
        parentPhoneNumber = data['phone_number'];
        parentId = data['id'].toString(); // Parse 'id' as a string
      });
    } catch (error) {
      print('Error fetching parent details: $error'); // Print error to debug
    }
  }

  /* Future<void> parentUpdate(String parentId, String currentName, String currentUsername, String currentIC, String currentPhone, String currentEmail, {String? newName, String? newUsername, String? newIC, String? newPhone, String? newEmail}) async {
    Map<String, dynamic> requestData = {
      "id": parentId,
      "name": newName ?? currentName, // If newName is null, use currentName
      "username": newUsername ?? currentUsername,
      "ic_number": newIC ?? currentIC,
      "phone_number": newPhone ?? currentPhone,
      "email": newEmail ?? currentEmail,
    };



    var url = Uri.parse("http://172.20.10.3/xampp/fyp/parent_controller_layer/update_parent.php");
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json', // Set content-type to JSON
      },
      body: jsonEncode(requestData),
    );

    print("parentId : ${parentId}");
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
  } */
  Future<void> parentUpdate(
    String parentId,
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
      "id": parentId,
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
        RequestController(path: 'guardian/update/$parentId');
    req.setBody(requestData); // Set request body with updated data

    try {
      await req.put(); // Perform the PUT request
      print(req.result()); // Print the result of the request

      if (req.status() == 200) {
        print("parentId: ${parentId}");
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
    parentNameController.dispose();
    parentUsernameController.dispose();
    parentIcController.dispose();
    parentPhoneController.dispose();
    parentEmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    parentNameController = TextEditingController(text: '');
    parentUsernameController = TextEditingController(text: '');
    parentIcController = TextEditingController(text: '');
    parentPhoneController = TextEditingController(text: '');
    fetchParentDetails();
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
                    style: GoogleFonts.saira(
                      // Use GoogleFonts.lato for the 'Edit Profile' text
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
                        hintText: '$parentName',
                      ),
                      controller: parentNameController,
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
                        hintText: '$parentUsername',
                      ),
                      controller: parentUsernameController,
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
                        hintText: '$parentIcNumber',
                      ),
                      controller: parentIcController,
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
                        hintText: '$parentPhoneNumber',
                      ),
                      controller: parentPhoneController,
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
                              String newName = parentNameController.text.trim();
                              String newUsername =
                                  parentUsernameController.text.trim();
                              String newIC = parentIcController.text.trim();
                              String newPhone =
                                  parentPhoneController.text.trim();

                              // Call the update function with existing data for fields that are not being updated
                              parentUpdate(
                                parentId,
                                parentName, // Existing name
                                parentUsername, // Existing username
                                parentIcNumber, // Existing IC number
                                parentPhoneNumber, // Existing phone number
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

                            // Navigate back to the parent profile page after saving
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
