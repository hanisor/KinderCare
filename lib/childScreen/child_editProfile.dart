import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindercare/request_controller.dart';

class ChildEditProfile extends StatefulWidget {
  final int? childId;
  ChildEditProfile({Key? key, this.childId});

  @override
  _ChildEditProfileState createState() => _ChildEditProfileState();
}

class _ChildEditProfileState extends State<ChildEditProfile> {
  TextEditingController childNameController = TextEditingController();
  TextEditingController childMykidNumberController = TextEditingController();
  TextEditingController childDOBController = TextEditingController();
  TextEditingController childAllergiesController = TextEditingController();
  String childName = '';
  String childMykidNumber = '';
  String childDOB = '';
  String childAllergies = '';
  String errorMessage = '';

  Future<Map<String, dynamic>> getChildDetails(int? childId) async {
    print('childIddd : $childId');
    RequestController req = RequestController(path: 'child-byId/$childId');

    await req.get();
    if (req.status() == 200) {
      var response = req.result();
      print("Response: $response");

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load child details');
    }
  }

  Future<void> fetchChildDetails(int? childId) async {
    try {
      final data = await getChildDetails(childId);
      print('Response Data: $data');
      setState(() {
        childName = data['name'] ?? 'Name';
        childMykidNumber = data['my_kid_number'] ?? 'MyKid number';
        childDOB = data['date_of_birth'] ?? 'Date of birth';
        childAllergies = data['allergy'] ?? 'Allergy';

        // Update text controllers with the fetched data
        childNameController.text = childName;
        childMykidNumberController.text = childMykidNumber;
        childDOBController.text = childDOB;
        childAllergiesController.text = childAllergies;
      });
    } catch (error) {
      print('Error fetching child details: $error');
      setState(() {
        errorMessage = 'Failed to load child details';
      });
    }
  }

  Future<void> childUpdate(
    int? childId,
    String currentName,
    String currentMyKidNumber,
    String currentDOB,
    String currentAllergies, {
    String? newName,
    String? newMyKidNumber,
    String? newDOB,
    String? newAllergies,
  }) async {
    Map<String, dynamic> requestData = {
      "id": childId,
      if (newName != null) "name": newName,
      if (newMyKidNumber != null) "my_kid_number": newMyKidNumber,
      if (newDOB != null) "date_of_birth": newDOB,
      if (newAllergies != null) "allergy": newAllergies,
    };

    // Make sure the requestData contains at least one field to update
    if (requestData.length == 1) {
      // Changed from requestData.isEmpty to requestData.length == 1 to ensure 'id' is excluded
      print("No fields to update");
      return;
    }
    print("childIdddd: $childId");
    print("Request Data: $requestData"); // Log request data

    RequestController req =
        RequestController(path: 'child/update-profile/$childId');
    req.setBody(requestData); // Set request body with updated data

    try {
      await req.put(); // Perform the PUT request
      print(req.result()); // Print the result of the request

      if (req.status() == 200) {
        print("childIdddd: $childId");
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
    childNameController.dispose();
    childMykidNumberController.dispose();
    childDOBController.dispose();
    childAllergiesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    childNameController = TextEditingController(text: '');
    childMykidNumberController = TextEditingController(text: '');
    childDOBController = TextEditingController(text: '');
    childAllergiesController = TextEditingController(text: '');
    fetchChildDetails(widget.childId);
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
                        hintText: '$childDOB',
                      ),
                      controller: childDOBController,
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
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.pinkAccent),
                        ),
                        onPressed: () async {
                          try {
                            setState(() {
                              // Get the updated values from text controllers
                              String newName = childNameController.text.trim();
                              String newMykidNumber =
                                  childMykidNumberController.text.trim();
                              String newDOB = childDOBController.text.trim();
                              String newAllergies =
                                  childAllergiesController.text.trim();

                              // Call the update function with existing data for fields that are not being updated
                              childUpdate(
                                widget.childId, // Use widget.childId here
                                childName, // Existing name
                                childMykidNumber, // Existing username
                                childDOB, // Existing IC number
                                childAllergies, // Existing email
                                newName: newName.isNotEmpty
                                    ? newName
                                    : null, // Updated name if provided
                                newMyKidNumber: newMykidNumber.isNotEmpty
                                    ? newMykidNumber
                                    : null, // Updated username if provided
                                newDOB: newDOB.isNotEmpty
                                    ? newDOB
                                    : null, // Updated IC number if provided
                                newAllergies: newAllergies.isNotEmpty
                                    ? newAllergies
                                    : null, // Updated email if provided
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
