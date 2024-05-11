import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_editProfile.dart';
import 'package:kindercare/splash_screen.dart';
import '../request_controller.dart';


class CaregiverProfile extends StatefulWidget {
  const CaregiverProfile({Key? key}) : super(key: key);

  @override
  State<CaregiverProfile> createState() => _CaregiverProfileState();
}

class _CaregiverProfileState extends State<CaregiverProfile> {
  final double coverHeight = 280;
  final double profileHeight = 144;
  String caregiverUsername = '';
  String caregiverName = '';
  String caregiverIcNumber = '';
  String caregiverEmail = '';
  String caregiverPhoneNumber = '';
  int? caregiverId;

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
      });
    } catch (error) {
      print('Error fetching caregiver details: $error'); // Print error to debug
    }
  }

    Future<Map<String, dynamic>> getCaregiverDetails(String? email) async{
    print('email : $email');
    RequestController req = RequestController(
        path: 'caregiver-byEmail?email=$email');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if(req.status() == 200){
       return response;
    }
    else {
      throw Exception('Failed to load parent details');
    }
  }


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
    fetchCaregiverDetails();
  }

  // Function to handle refresh action
  Future<void> _refresh() async {
    await fetchCaregiverDetails();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjust margin for spacing
                decoration: BoxDecoration(
                  color: Colors.pink[50], // Change color to match kids' background
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: profileHeight / 2,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: const AssetImage('assets/profile_pic.jpg'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      caregiverUsername,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caregiverName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(
                        Icons.description,
                      ),
                      title: Text(
                        obfuscateICNumber(caregiverIcNumber),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.email,
                      ),
                      title: Text(
                        caregiverEmail,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.phone,
                      ),
                      title: Text(
                        obfuscatePhoneNumber('+6$caregiverPhoneNumber'),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaregiverEditProfile(caregiverId: caregiverId,),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}