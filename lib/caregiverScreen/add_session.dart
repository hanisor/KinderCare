import 'package:flutter/material.dart';

class AddSession extends StatefulWidget {
  const AddSession({Key? key}) : super(key: key);

  @override
  State<AddSession> createState() => _AddSessionState();
}

class _AddSessionState extends State<AddSession> {
  late DateTime startDate;
  late DateTime endDate;
  int selectedYear = DateTime.now().year;
  late String selectedSection;
  late String selectedCaregiver;
  bool showSectionAndCaregiverSelection = false;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Session Details:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text('Start Date: ${startDate != null ? startDate.toString() : "Select a date"}'),
            ElevatedButton(
              onPressed: () => _selectStartDate(context),
              child: const Text('Select Start Date'),
            ),
            const SizedBox(height: 16.0),
            Text('End Date: ${endDate != null ? endDate.toString() : "Select a date"}'),
            ElevatedButton(
              onPressed: () => _selectEndDate(context),
              child: const Text('Select End Date'),
            ),
            const SizedBox(height: 16.0),
            const Text('Year:'),
            // Use a dropdown to select year
            DropdownButton<int>(
              value: selectedYear,
              onChanged: (value) {
                setState(() {
                  selectedYear = value!;
                });
              },
              items: [for (int year = 2022; year <= 2030; year++) DropdownMenuItem(value: year, child: Text(year.toString()))],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showSectionAndCaregiverSelection = true;
                });
              },
              child: const Text('Next'),
            ),
            if (showSectionAndCaregiverSelection) ...[
              const SizedBox(height: 32.0),
              const Text(
                'Select Section and Caregiver:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              const Text('Section:'),
              // Use a dropdown to select section
              // Update selectedSection when a section is selected
              // ...
              const SizedBox(height: 16.0),
              const Text('Caregiver:'),
              // Use a text field or dropdown to select caregiver
              // Update selectedCaregiver when a caregiver is selected
              // ...
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  // Add session details to database or perform necessary actions
                  // ...
                  // After saving, display a success message or navigate to another screen
                },
                child: const Text('Save Session'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


