/* import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';

class PickupReportPage extends StatefulWidget {
  final int? relativeId;

  PickupReportPage({Key? key, this.relativeId}) : super(key: key);

  @override
  _PickupReportPageState createState() => _PickupReportPageState();
}

class _PickupReportPageState extends State<PickupReportPage> {
  List<ChildModel> _children = [];
  String? relativeName;
  String? relation;
  String? phoneNumber;
  DateTime? pickupDateTime;

  Future<void> _fetchRelativeData() async {
    try {
      RequestController req =
          RequestController(path: 'child_relatives/$widget.relativeId');
      await req.get();
      var response = req.result();
      print("req result : $response");

      if (response != null && response.containsKey('children')) {
        var responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('child_relatives')) {
          List<dynamic> relativesData = responseData['child_relatives'];

          setState(() {
            relativeName = relativesData[0]['relative_name'];
            relation = relativesData[0]['relation'];
            phoneNumber = relativesData[0]['phone_number'];
            pickupDateTime = DateTime.parse(relativesData[0]['date_time']);

            _children = relativesData.map((relative) {
              return ChildModel(
                childId: relative['child_id'],
                childName: relative['child_name'],
                childMykidNumber: "", // Dummy value for childMykidNumber
                childAge: 0, // Dummy value for childAge
                childGender: "", // Dummy value for childGender
                childAllergies: "", // Dummy value for childAllergies
                parentId: 0, // Dummy value for parentId
              );
            }).toList();
          });
        }
      } else {
        // Handle error response
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching relative data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRelativeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pickup Report'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRelativeData,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relative Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Name: ${relativeName ?? ''}'),
                Text('Relation: ${relation ?? ''}'),
                Text('Phone Number: ${phoneNumber ?? ''}'),
                Text(
                    'Pickup Date and Time: ${pickupDateTime != null ? DateFormat.yMd().add_jm().format(pickupDateTime!) : 'Loading...'}'),
                SizedBox(height: 20),
                Text(
                  'Children Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _children.isNotEmpty
                    ? Column(
                        children: _children.map((child) {
                          return ListTile(
                            title: Text(child.childName ?? ''),
                            // Other child details...
                          );
                        }).toList(),
                      )
                    : Text('No children associated with this relative.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */