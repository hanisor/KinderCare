import 'package:flutter/material.dart';
import 'package:kindercare/model/attendance_model.dart';
import 'package:provider/provider.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';

class ParentAttendanceArrival extends StatefulWidget {
  final int? parentId;
  const ParentAttendanceArrival({Key? key, this.parentId}) : super(key: key);

  @override
  State<ParentAttendanceArrival> createState() =>
      _ParentAttendanceArrivalState();
}

class _ParentAttendanceArrivalState extends State<ParentAttendanceArrival> {
  DateTime? dateTime; // Changed type to DateTime
  List<ChildModel> childrenList = [];

  @override
  void initState() {
    super.initState();
    getChildrenData();
    // Initialize dateTime with current date and time
    dateTime = DateTime.now();
  }

  Future<void> getChildrenData() async {
    RequestController req =
        RequestController(path: 'child/by-guardianId/${widget.parentId}');
    await req.get();
    var response = req.result();
    print("req result : $response"); // Print the response to see its type
    if (response != null && response.containsKey('children')) {
      setState(() {
        var childrenData = response['children'];
        print("Children Data: $childrenData"); // Debugging line
        if (childrenData is List) {
          childrenList =
              childrenData.map((x) => ChildModel.fromJson(x)).toList();
        } else {
          print("Invalid children data format"); // Debugging line
        }
      });
    } else {
      print("Failed to fetch children data"); // Debugging line
    }
    print("childrenList : $childrenList");
  }

  void toggleChildSelection(ChildModel child, AttendanceModel attendanceModel) {
    if (attendanceModel.selectedChildren.contains(child)) {
      attendanceModel.removeChild(child);
    } else {
      attendanceModel.addChild(child);
    }
  }

  void sendAttendanceConfirmation(BuildContext context,
      AttendanceModel attendanceModel, DateTime dateTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Selected Children"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "Are you sure you want to send attendance for the following children?"),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: attendanceModel.selectedChildren.length,
                itemBuilder: (context, index) {
                  return Text(
                      attendanceModel.selectedChildren[index].childName);
                },
              ),
              const SizedBox(height: 16),
              Text(
                  "Date: ${dateTime.day}/${dateTime.month}/${dateTime.year}  Time: ${dateTime.hour}:${dateTime.minute}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Create a copy of selectedChildren
                final List<ChildModel> selectedChildrenCopy =
                    List.from(attendanceModel.selectedChildren);
                // Update selectedDateTime in AttendanceModel
                attendanceModel.selectedDateTime = dateTime;
                // Pass date and time along with children details to the model
                attendanceModel.addChildWithDateTime(
                    selectedChildrenCopy, dateTime);
                // Show SnackBar message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Attendance for your children has been sent!'),
                    duration:
                        Duration(seconds: 2), // Adjust the duration as needed
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceModel = Provider.of<AttendanceModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Arrival"),
        actions: [
          IconButton(
            onPressed: attendanceModel.selectedChildren.isNotEmpty
                ? () => sendAttendanceConfirmation(
                    context, attendanceModel, dateTime!)
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Date: ${dateTime?.day}/${dateTime?.month}/${dateTime?.year}  Time: ${dateTime?.hour}:${dateTime?.minute}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: childrenList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: childrenList.length,
                      itemBuilder: (context, index) {
                        final child = childrenList[index];
                        final isSelected =
                            attendanceModel.selectedChildren.contains(child);
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              toggleChildSelection(child, attendanceModel);
                            });
                          },
                          child: Card(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(child.childName[0]),
                                ),
                                title: Text(child.childName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DOB: ${child.childDOB}'),
                                    Text('Gender: ${child.childGender}'),
                                    Text(
                                        'Allergies: ${child.childAllergies}'),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Caregiver: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '${child.caregiverName ?? ""}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color.fromARGB(255, 0, 85, 255), // Example color
                                            ),
                                          ),
                                        ],
                                      ),
                                    ), // Display caregiver name
                                  ],
                                ),
                                trailing: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: isSelected ? Colors.green : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
