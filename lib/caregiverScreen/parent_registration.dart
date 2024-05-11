import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/request_controller.dart';
import '../childScreen/child_registration.dart';

class ParentRegistration extends StatefulWidget {

  @override
  State<ParentRegistration> createState() => _ParentRegistrationState();
}

class _ParentRegistrationState extends State<ParentRegistration> {
  var parentEmailEditCtrl = TextEditingController();
  var parentNameEditCtrl = TextEditingController();
  var parentUsernameEditCtrl = TextEditingController();
  var parentPassEditCtrl = TextEditingController();
  var parentRePassEditCtrl = TextEditingController();
  var parentIcEditCtrl = TextEditingController();
  var parentPhoneEditCtrl = TextEditingController();
  var parentImageEditCtrl = TextEditingController();
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  int? parentId;

  void _showRegistrationFailedDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registration Failed'),
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

  Future<int> fetchParentDetails() async {
    try {
      final data = await getParentDetails(parentEmailEditCtrl.text);
      print('Response Data: $data');
      final parentId = data['id'];
      setState(() {
        this.parentId = parentId;
        print('caregiver Id after setState: $parentId');
      });
      return parentId; // Return caregiverId
    } catch (error) {
      print('Error fetching parent details: $error'); // Print error to debug
      throw error; // Re-throw the error
    }
  }

  Future<Map<String, dynamic>> getParentDetails(String? email) async {
  print('email : $email');
  RequestController req = RequestController(path: 'guardian-byEmail?email=$email');

  await req.get();
  var response = req.result();
  print("${req.status()}");
  if (req.status() == 200) {
    return response;
  } else {
    throw Exception('Failed to load parent details');
  }
}



  Future<void> parentRegister() async {
    String parentEmail = parentEmailEditCtrl.text.trim();
    String parentName = parentNameEditCtrl.text.trim();
    String parentUsername = parentUsernameEditCtrl.text.trim();
    String parentPass = parentPassEditCtrl.text.trim();
    String parentRePass = parentRePassEditCtrl.text.trim();
    String parentIc = parentIcEditCtrl.text.trim();
    String parentPhone = parentPhoneEditCtrl.text.trim();
    String parentImage = parentImageEditCtrl.text.trim();

    if (parentEmail.isEmpty ||
        parentName.isEmpty ||
        parentUsername.isEmpty ||
        parentPass.isEmpty ||
        parentRePass.isEmpty ||
        parentIc.isEmpty ||
        parentPhone.isEmpty) {
      _showRegistrationFailedDialog(context, 'Please fill in all the details');
    } else if (parentPass != parentRePass) {
      _showRegistrationFailedDialog(context, 'The password did not match.');
    } else if (!isPasswordStrong(parentPass)) {
      _showRegistrationFailedDialog(
          context,
          'The password is not strong enough. '
          'Please ensure it meets the strength criteria.');
      return;
    } else {
      RequestController req = RequestController(path: 'guardian-register');

      req.setBody({
        "name": parentName,
        "ic_number": parentIc,
        "phone_number": parentPhone,
        "email": parentEmail,
        "username": parentUsername,
        "password": parentPass,
        "status": "ACTIVE",
        "role": "PARENT",
        "image": parentImage,
      });

      await req.postNoToken();

      print(req.result());

      var result = req.result();

      // Check if req.result() contains the 'guardian' field to indicate success
      if (result != null && result.containsKey('guardian')) {
        // Registration success logic
        var parentIdFuture = fetchParentDetails(); // Get the Future<String>
        int parentId = await parentIdFuture; // Wait for the Future<String> to complete
        print("parentID = $parentId");
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
            context, MaterialPageRoute(
            builder: (context) => ChildRegistration(parentId: parentId)
        ));
      }
    }
  }


  @override
  void initState() {
    super.initState();
    fetchParentDetails();
    print('InitState: parentId: $parentId');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parent Registration",
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
                Text(
                  'Create parent account',
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
                  controller: parentEmailEditCtrl,
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
                  controller: parentNameEditCtrl,
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
                  controller: parentUsernameEditCtrl,
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
                  controller: parentIcEditCtrl,
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
                  controller: parentPhoneEditCtrl,
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
                      controller: parentPassEditCtrl,
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
                  controller: parentRePassEditCtrl,
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
                        parentRegister();
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
