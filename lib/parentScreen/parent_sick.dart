import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/request_controller.dart';
import '../model/sickness_model.dart';


class ParentSickness extends StatefulWidget {
  final int? parentId;
  ParentSickness({Key? key, this.parentId});

  @override
  State<ParentSickness> createState() => _ParentSicknessState();
}

class _ParentSicknessState extends State<ParentSickness> {
  String? sicknessType;
  String? dosage;
  String sicknessStatus = "Pending";
  DateTime? dateTime; // Changed type to DateTime
  ChildModel? selectedChild; // Initialize selectedChild
  List<ChildModel> childrenList = [];
  List<SicknessModel> checklistItems = []; // List to hold checklist items
  Map<int, bool> checkedMap = {};

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
          childrenList = List<ChildModel>.from(childrenData.map((x) => ChildModel(
                childId: int.tryParse(x['id'].toString()),
                childName: x['name'] as String,
                childDOB: x['date_of_birth'] as String,
                childGender: x['gender'] as String,
                childMykidNumber: x['my_kid_number'] as String,
                childAllergies: x['allergy'] as String,
                parentId: widget.parentId, 
                performances: [],
              )));
          // Set selectedChild if the list is not empty
          if (childrenList.isNotEmpty) {
            selectedChild = childrenList[0];
          }
        } else {
          print("Invalid children data format"); // Debugging line
        }
      });
    } else {
      print("Failed to fetch children data"); // Debugging line
    }
    print("childrenList : $childrenList");
  }


    Future<void> _saveChecklistItem() async {
      try {
        if (sicknessType == null ||
            dosage == null ||
            dateTime == null ||
            selectedChild == null) {
          return;
        }

        String formattedDateTime =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime!);

        RequestController req = RequestController(path: 'add-sickness');

        req.setBody({
          "type": sicknessType!,
          "dosage": dosage!,
          "date_time": formattedDateTime,
          "status": sicknessStatus, // Handle null status
          "child_id": selectedChild!.childId.toString(),
        });

        var response = await req.post();

        if (response.statusCode == 200) {
          var result = req.result();

          if (result != null && result.containsKey('sickness')) {
            print('Checklist item saved successfully');
            fetchChecklistItems();
          } else {
            print('Error saving checklist item');
          }
        } else {
          print('Error: HTTP request failed with status code ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

  Future<void> fetchChecklistItems() async {
    RequestController req = RequestController(path: 'sickness/by-childId/${selectedChild!.childId}');
    print("selectedChild!.childId : ${selectedChild!.childId}"); // Print the response to see its type

    await req.get();
    var response = req.result();
    print("req result : $response"); // Print the response to see its type
    if (response != null && response.containsKey('sicknesses')) {
      // Process the response data here
      var sicknessData = response['sicknesses'];
      print("sickness Data: $sicknessData"); // Print children data for debugging
      setState(() {
        checklistItems = List<SicknessModel>.from(sicknessData.map((x) {
          // Ensure sicknessId is parsed as an integer
          x['id'] = int.tryParse(x['id'].toString());
          print("SicknessId: ${x['id']}"); // Debug sicknessId
          print(" sicknessType: ${x['type']}"); // Debug sicknessType
          return SicknessModel.fromJson(x);
        }));

        // Sort checklistItems to display "Not Taken" status items before "Taken" status items
        checklistItems.sort((a, b) {
          if (a.sicknessStatus == 'Pending' && b.sicknessStatus != 'Taken') {
            return 1;
          } else if (a.sicknessStatus != 'Pending' && b.sicknessStatus == 'Taken') {
            return -1;
          } else {
            return 0;
          }
        });
      });
    }
  }

   

  
  Future<void> _refreshData() async {
    //await getChildrenData();
    await fetchChecklistItems();
  }

  @override
  void initState() {
    super.initState();
    getChildrenData();
    fetchChecklistItems(); // Fetch checklist items when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sickness Checklist'),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              // Open a dialog or navigate to another screen to add a checklist
              _addChecklistDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButton(
                hint: const Text(
                  "Select Child Name",
                  style: TextStyle(
                    color: Colors.pink, // Pink text color
                  ),
                ),
                value: selectedChild?.childName,
                icon: const Icon(
                  Icons.arrow_drop_down, // Arrow icon
                  color: Colors.pink, // Pink color
                ),
                elevation: 4,
                style: const TextStyle(
                  color: Colors.pink, // Pink text color
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.pink, // Pink underline
                ),
                items: childrenList.map<DropdownMenuItem<String>>((child) {
                  return DropdownMenuItem<String>(
                    value: child.childName,
                    child: Text(
                      child.childName,
                      style: const TextStyle(
                        color: Colors.black, // Black text color
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedChild = childrenList
                        .firstWhere((child) => child.childName == value);
                    fetchChecklistItems(); // Fetch checklist items when child changes
                  });
                },
              ),
              if (selectedChild != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Child Date Of Birth: ${selectedChild!.childDOB}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Child Allergies: ${selectedChild!.childAllergies}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: checklistItems.length,
                  itemBuilder: (context, index) {
                    final item = checklistItems[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(item.sicknessType),
                        subtitle: Text(
                            'Dosage: ${item.dosage}\nDate & Time: ${item.dateTime}'),
                      ),
                    );
                  },
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  void _addChecklistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Checklist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Sickness Type'),
                onChanged: (value) => sicknessType = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Dosage'),
                onChanged: (value) => dosage = value,
              ),
              DateTimeField(
                decoration: InputDecoration(labelText: 'Date & Time'),
                format: DateFormat("yyyy-MM-dd HH:mm"), // Date and time format
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.combine(
                        date, time); // Combine date and time
                  } else {
                    return currentValue;
                  }
                },
                onChanged: (DateTime? value) {
                  setState(() {
                    dateTime = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveChecklistItem();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
