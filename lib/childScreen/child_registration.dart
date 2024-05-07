import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/caregiverScreen/caregiver_homepage.dart';
import 'package:kindercare/request_controller.dart';

class ChildRegistration extends StatefulWidget {
  final int? parentId;
  ChildRegistration({Key? key, this.parentId});

  @override
  State<ChildRegistration> createState() => _ChildRegistrationState();
}

class _ChildRegistrationState extends State<ChildRegistration> {
  var childNameEditCtrl = TextEditingController();
  var childMyKidEditCtrl = TextEditingController();
  var childAgeEditCtrl = TextEditingController();
  var childAllergiesEditCtrl = TextEditingController();
  var childGenderEditCtrl = TextEditingController();

  // Method to display a generic error dialog
  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
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

  void _showRegistrationFailedDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registration Failed'),
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

  Future<void> childRegister() async {
    String childName = childNameEditCtrl.text.trim();
    String childMyKid = childMyKidEditCtrl.text.trim();
    String childAge = childAgeEditCtrl.text.trim();
    String childAllergy = childAllergiesEditCtrl.text.trim();
    String childGender = childGenderEditCtrl.text.trim();

    if (childName.isEmpty ||
        childMyKid.isEmpty ||
        childAge.isEmpty ||
        childAllergy.isEmpty ||
        childGender.isEmpty) {
      _showRegistrationFailedDialog(context, 'Please fill in all the details');
      return;
    } else {
      RequestController req = RequestController(path: 'add-child');

      req.setBody({
        "name": childName,
        "my_kid_number": childMyKid,
        "age": childAge,
        "allergy": childAllergy,
        "gender": childGender,
      });

      await req.postNoToken();

      print(req.result());

      var result = req.result();
      if (result != null && result.containsKey('child')) {
        Fluttertoast.showToast(
          msg: "This User already exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.pinkAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Registration successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.pinkAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Children Registration",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register the children',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Enter child name',
                      ),
                      controller: childNameEditCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                        hintText: 'Enter child my kid number',
                      ),
                      controller: childMyKidEditCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        prefixIcon: const Icon(Icons.cake),
                        hintText: 'Enter child age',
                      ),
                      controller: childAgeEditCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        prefixIcon: const Icon(Icons.female),
                        hintText: 'Enter child gender',
                      ),
                      controller: childGenderEditCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.pinkAccent,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        prefixIcon: const Icon(Icons.sick),
                        hintText: 'Enter child allergies',
                      ),
                      controller: childAllergiesEditCtrl,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Align buttons at the center horizontally
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.pinkAccent),
                          ),
                          onPressed: () async {
                            await childRegister();
                            Navigator.pop(context);
                          },
                          child: const Text("Add"),
                        ),
                        const SizedBox(width: 50),
                        ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.pinkAccent),
                          ),
                          onPressed: () {
                            childRegister();
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CaregiverHomepage()));
                            });
                          },
                          child: const Text("Done"),
                        ),
                      ],
                    ),
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
