import 'package:flutter/material.dart';

class CaregiverSickness extends StatefulWidget {
  const CaregiverSickness({super.key});

  @override
  State<CaregiverSickness> createState() => _CaregiverSicknessState();
}

class _CaregiverSicknessState extends State<CaregiverSickness> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sickness checklist'),
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}
