import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/parent_registration.dart';
import 'package:kindercare/request_controller.dart';

import '../childScreen/child_registration.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late List<Map<String, dynamic>> _allUsers = [];
  late List<Map<String, dynamic>> _foundUsers = [];

  @override
  void initState() {
    _getAllUsers();
    super.initState();
  }

  Future<void> _getAllUsers() async {
    RequestController req = RequestController(path: 'guardian-data');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load parent details');
    }
  }


  void _runFilter(String enteredKeyword) async {
    if (enteredKeyword.isEmpty) {
      setState(() {
        _foundUsers = _allUsers;
      });
    } else {
      RequestController req = RequestController(
          path: 'guardian-byKeyword?keyword=$enteredKeyword');

      await req.get();
      var response = req.result();
      print("req result : $response"); // Print the response to see its type

      if (response != null) {
        if (response is List) {
          setState(() {
            _foundUsers = response.cast<Map<String, dynamic>>();
          });
        } else {
          var jsonData = json.decode(response.body);
          if (jsonData is List) {
            setState(() {
              _foundUsers = jsonData.cast<Map<String, dynamic>>();
            });
          } else {
            print("Response is not a List");
          }
        }
      } else {
        print("Failed to load data");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Before registering, please select a parent name',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundUsers[index]["id"]),
                        color: Colors.pinkAccent,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to children registration screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildRegistration(
                                  parentId: _foundUsers[index]["id"],
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Text(
                              _foundUsers[index]["id"].toString(),
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                            title: Text(
                              _foundUsers[index]['username'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 20),
                    ),
            ),
            Column(
              children: [
                const Text(
                  'Or, add a new parent registration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ParentRegistration()));
                    },
                    child: Text('Add new parent'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  runApp(
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection
            .ltr, // Or TextDirection.rtl based on your language direction
        child: RegisterPage(),
      ),
    ),
  );
}
