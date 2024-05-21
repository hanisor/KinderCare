import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_behaviour.dart';
import 'package:kindercare/model/behaviour_model.dart';
import 'package:kindercare/request_controller.dart';

class CaregiverBehaviourReport extends StatefulWidget {
  final int? caregiverId;
  CaregiverBehaviourReport({Key? key, this.caregiverId});

  @override
  State<CaregiverBehaviourReport> createState() =>
      _CaregiverBehaviourReportState();
}

class _CaregiverBehaviourReportState extends State<CaregiverBehaviourReport> {
  List<BehaviourModel> behaviourList = [];

  @override
  void initState() {
    super.initState();
    // Fetch child behaviours when the widget initializes
    fetchChildBehavioursByCaregiverId();
  }

  Future<void> fetchChildBehavioursByCaregiverId() async {
    try {
      // Make an HTTP GET request to fetch child behaviours by caregiver ID
      RequestController req =
          RequestController(path: 'behaviour/${widget.caregiverId}');

      await req.get();
      var response = req.result();
      if (response != null) {
        if (response is Map<String, dynamic>) {
          // If the request is successful, parse the JSON response
          final responseData = response as Map<String, dynamic>;
          final childGroup = responseData['child_group'];

          setState(() {
            // Clear existing behaviour list
            behaviourList.clear();

            // Process the child group data
            childGroup.forEach((childGroupItem) {
              final child = childGroupItem['child'];
              final behaviours = childGroupItem['child']['behaviours'];
              print('listeeee: $behaviours');
              print('chilfddd: $child');


              // Check if child and behaviours are not null
              if (child != null && behaviours != null) {
                // Get the child's name
                final childName = child['name'];

                // Process behaviour details
                behaviours.forEach((behaviour) {
                  // Create BehaviourModel object from JSON data
                  BehaviourModel behaviourModel = BehaviourModel(
                    type: behaviour['type'],
                    description: behaviour['description'],
                    dateTime: behaviour['date_time'],
                  );

                  // Add the child's name to the behaviour model
                  behaviourModel.childName = childName;

                  // Add behaviour to the list
                  behaviourList.add(behaviourModel);
                  print('listeeee: $behaviourList');
                });
              }
            });
          });
        } else {
          // If the request fails, print the error message
          print(
              'Failed to fetch child groups and behaviours: ${response.toString()}');
        }
      } else {
        // If no response received, print an error message
        print('No response received');
      }
    } catch (error) {
      // If an error occurs during the request, print the error message
      print('Failed to fetch child groups and behaviours: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Behaviour Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CaregiverBehaviour(caregiverId: widget.caregiverId)),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: behaviourList.length,
        itemBuilder: (context, index) {
          // Build card for each behaviour
          return Card(
            child: ListTile(
              title: Text(behaviourList[index].childName ?? 'Unknown Child'), // Display child name
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Behaviour: ${behaviourList[index].type}'),
                  Text('Description: ${behaviourList[index].description}'),
                  Text('Date: ${behaviourList[index].dateTime}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}