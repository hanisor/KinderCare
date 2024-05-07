import 'package:flutter/material.dart';
import 'package:kindercare/parentScreen/parent_editProfile.dart';
import 'package:kindercare/splash_screen.dart';
import '../request_controller.dart';
import '../childScreen/child_editProfile.dart';
import '../model/child_model.dart';

class ParentProfile extends StatefulWidget {
  const ParentProfile({Key? key}) : super(key: key);

  @override
  State<ParentProfile> createState() => _ParentProfileState();
}

class _ParentProfileState extends State<ParentProfile> {
  final double coverHeight = 280;
  final double profileHeight = 144;
  String parentUsername = '';
  String parentName = '';
  String parentIcNumber = '';
  String parentEmail = '';
  String parentPhoneNumber = '';
  int? parentId;

  Future<void> fetchParentDetails() async {
    try {
      final data = await getParentDetails(finalEmail!);
      print('Response Data: $data');
      setState(() {
        parentUsername = data['username'];
        parentName = data['name'];
        parentIcNumber = data['ic_number'];
        parentPhoneNumber = data['phone_number'];
        parentEmail = data['email'];
        parentId = data['id'];
      });
    } catch (error) {
      print('Error fetching parent details: $error'); // Print error to debug
    }
  }

  Future<Map<String, dynamic>> getParentDetails(String? email) async {
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

  Future<List<ChildModel>> getChildrenData(int? parentId) async {
    RequestController req =
        RequestController(path: 'child/by-guardianId/$parentId');

    print("parent iddd : $parentId");
    await req.get();
    var response = req.result();
    print("req result : $response"); // Print the response to see its type

    if (response != null && response.containsKey('children')) {
      List<dynamic> childrenData = response['children'];

      // parese every int to string
      List<ChildModel> childrenList = childrenData.map((childData) {
        return ChildModel(
          childId: int.tryParse(
              childData['id'].toString()), // Ensure child ID is parsed as int
          childName: childData['name'],
          childMykidNumber: childData['my_kid_number'],
          childAge: int.tryParse(
              childData['age'].toString()), // Ensure age is parsed as int
          childGender: childData['gender'],
          childAllergies: childData['allergy'],
          parentId: int.tryParse(childData['guardian_id']
              .toString()), // Ensure guardian_id is parsed as int
        );
      }).toList();

      return childrenList;
    } else {
      // No children found or response is not in the expected format
      return [];
    }
  }

  Widget buildKids() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Kids',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
          ),
          FutureBuilder<List<ChildModel>>(
            future: getChildrenData(parentId),
            builder: (context, AsyncSnapshot<List<ChildModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}'); // Print error to terminal
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                  child: Text(
                    'No children found',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              } else {
                List<ChildModel> childrenList = snapshot.data!;
                return Column(
                  children: childrenList.map((child) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade800,
                            child: Icon(Icons.child_care, color: Colors.white),
                          ),
                          title: Text(
                            child.getChildName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                'Age: ${child.getChildAge}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gender: ${child.getChildGender}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Allergy: ${child.getChildAllergies}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight
                                      .bold, // Increase font weight for emphasis
                                  color:
                                      Colors.red, // Change color to alert color
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to edit child profile screen
                            print('childId : ${child.getChildId}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildEditProfile(
                                  childId: child.getChildId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      );

  String obfuscateICNumber(String icNumber) {
    if (icNumber.length > 6) {
      return '${icNumber.substring(0, 6)}${'*' * (icNumber.length - 6)}';
    }
    return icNumber;
  }

  String obfuscatePhoneNumber(String phoneNumber) {
    if (phoneNumber.length >= 6) {
      String visiblePart = phoneNumber.substring(0, 3);
      String maskedPart = '*' * (phoneNumber.length - 6);
      String lastVisiblePart = phoneNumber.substring(phoneNumber.length - 3);
      return '$visiblePart$maskedPart$lastVisiblePart';
    }
    return phoneNumber;
  }

  @override
  void initState() {
    super.initState();
    fetchParentDetails();
  }

  // Function to handle refresh action
  Future<void> _refresh() async {
    await fetchParentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16), // Adjust margin for spacing
                decoration: BoxDecoration(
                  color:
                      Colors.pink[50], // Change color to match kids' background
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: profileHeight / 2,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: AssetImage('assets/profile_pic.jpg'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      parentUsername,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      parentName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(
                        Icons.description,
                      ),
                      title: Text(
                        obfuscateICNumber(parentIcNumber),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.email,
                      ),
                      title: Text(
                        parentEmail,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.phone,
                      ),
                      title: Text(
                        obfuscatePhoneNumber('+6$parentPhoneNumber'),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentEditProfile(
                              parentId: parentId,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              // Display children's names
              buildKids(),
            ],
          ),
        ),
      ),
    );
  }
}
