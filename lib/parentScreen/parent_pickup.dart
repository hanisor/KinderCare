import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/parentScreen/parent_pickuprepoprt.dart';
import 'package:kindercare/request_controller.dart';

class ParentPickup extends StatefulWidget {
  final int? parentId;
  ParentPickup({Key? key, this.parentId});

  @override
  _ParentPickupState createState() => _ParentPickupState();
}

class _ParentPickupState extends State<ParentPickup> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? relation;
  String? phoneNumber;
  String status = 'ACTIVE';
  DateTime? dateTime;
  List<ChildModel> _children = [];
  ChildModel? _selectedChild;
  bool _selectAllChildren = false;

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
          childDOB: childData['date_of_birth'], // Ensure age is parsed as int
          childGender: childData['gender'],
          childAllergies: childData['allergy'],
          childStatus:  childData['status'] as String,
          parentId: int.tryParse(childData['guardian_id']
              .toString()), performances: [], // Ensure guardian_id is parsed as int
        );
      }).toList();

      return childrenList;
    } else {
      // No children found or response is not in the expected format
      return [];
    }
  }

  Future<void> _fetchChildrenData() async {
    try {
      List<ChildModel> children = await getChildrenData(widget.parentId);
      setState(() {
        _children = children;
      });
    } catch (e) {
      print('Error fetching children data: $e');
    }
  }

  Future<void> addRelative() async {
    try {
      if (name == null ||
          relation == null ||
          phoneNumber == null ||
          dateTime == null) {
        return;
      }

      String formattedDateTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime!);

      // Check if the relative already exists in the database
      int? relativeId = await checkRelativeExistence();

      if (relativeId == null) {
        // If the relative doesn't exist, add them to the database
        RequestController req =
            RequestController(path: 'guardian/add-relative');

        req.setBody({
          "name": name,
          "relation": relation,
          "phone_number": phoneNumber,
          "date_time": formattedDateTime,
          "status": status,
          "guardian_id": widget.parentId,

        });

        await req.post();
        var response = req.result();
        print("req resulttt : $response");

        var responseData = response as Map<String, dynamic>; // Cast to Map

        if (responseData.containsKey('message')) {
          String message = responseData['message'];
          print('response message: $message');
          print(responseData['relative_id']);

          if (message == 'relative added successfully') {
            // Retrieve the newly added relative's ID
            relativeId = responseData['relative_id'];
            print('relativeId: $relativeId');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ParentPickupReport(
                  parentId:
                      widget.parentId, // Pass the relative ID to PickupReportPage
                ),
              ),
            );
          } else {
            print('Error: Relative was not added successfully');
            return;
          }
        } else {
          print('Error: Unexpected response format');
          return;
        }
      }

      // If "Select All Children" is checked, relate the relative with all children
      if (_selectAllChildren) {
        for (var child in _children) {
          await relateChildWithRelative(child.childId!, relativeId!);
        }
      } else {
        // If a specific child is selected, relate the relative with that child
        if (_selectedChild != null) {
          print('Selected Child ID: ${_selectedChild!.childId}');
          await relateChildWithRelative(_selectedChild!.childId!, relativeId!);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

// Function to check if the relative already exists in the database
  Future<int?> checkRelativeExistence() async {
    try {
      RequestController req =
          RequestController(path: 'guardian/check-relative');

      req.setBody({
        "name": name,
        "relation": relation,
        "phone_number": phoneNumber,
      });

      var response = await req.post();
      var responseData = response as Map<String, dynamic>;

      if (responseData.containsKey('relative_id')) {
        // If the relative exists, return their ID
        return responseData['relative_id'];
      } else {
        // If the relative doesn't exist, return null
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> relateChildWithRelative(int childId, int relativeId) async {
    try {
      RequestController req = RequestController(path: 'child_relative/relate');

      req.setBody({
        "child_id": childId,
        "relative_id": relativeId,
      });

      var response = await req.post();

      if (response.statusCode != 200) {
        print('Error relating child with relative');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch children data when the widget is initialized
    _fetchChildrenData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kindergarten Pickup Authorization Form',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Children Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _selectAllChildren,
                      onChanged: (value) {
                        setState(() {
                          _selectAllChildren = value!;
                          // If "Select All Children" is checked, clear the selected child
                          if (_selectAllChildren) {
                            _selectedChild = null;
                          }
                        });
                      },
                    ),
                    const Text('Select All Children'),
                  ],
                ),
                // Dropdown for individual children
                DropdownButtonFormField<ChildModel>(
                  value: _selectAllChildren ? null : _selectedChild,
                  onChanged: (value) {
                    setState(() {
                      _selectedChild = value!;
                    });
                  },
                  items: _selectAllChildren
                      ? null // If "Select All Children" is checked, disable individual selection
                      : _children.map((child) {
                          return DropdownMenuItem<ChildModel>(
                            value: child,
                            child: Row(
                              children: [
                                const Icon(Icons.child_care),
                                const SizedBox(width: 10),
                                Text(child.childName),
                              ],
                            ),
                          );
                        }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Child',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (!_selectAllChildren && value == null) {
                      return 'Please select a child';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Relative Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Relative Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter relative name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Relation',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  onChanged: (value) {
                    setState(() {
                      relation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter relation';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                DateTimeField(
                  decoration: const InputDecoration(
                    labelText: 'Date & Time',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  format:
                      DateFormat("yyyy-MM-dd HH:mm"), // Date and time format
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
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Here you can implement the logic to submit the form data
                        // For now, let's just print the data
                        if (_selectAllChildren) {
                          print('All Children selected');
                        } else {
                          print('Selected Child: ${_selectedChild?.childName}');
                        }
                        print('Relative Name: $name');
                        print('Relation: $relation');
                        print('Phone Number: $phoneNumber');
                        print('Pickup Date and Time: $dateTime');
                        // Other form data...
                      }
                      addRelative();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 240, 196, 210)),
                    ),
                    child: const Text('Authorize Pickup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
