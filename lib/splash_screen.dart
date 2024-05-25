import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_homepage.dart';
import 'package:kindercare/model/splash_screen_model.dart';
import 'package:kindercare/parentScreen/parent_homepage.dart';
import 'package:kindercare/role.dart';
import 'package:get/get.dart';

String? finalEmail;
String? userRole;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final kAnimationDuration = Duration(milliseconds: 200);
  int currentIndex = 0;

  List<SplashScreenModel> splashScreenList = [
    SplashScreenModel(
      "assets/logo.png",
      "Welcome to KinderCare: Where every child's safety and happiness come first!",
      "Welcome",
    ),
  ];

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      if (finalEmail == null) {
        Get.to(() => Role());
      } else {
        if (userRole == 'parent') {
          Get.to(() => ParentHomepage());
        } else if (userRole == 'caregiver') {
          Get.to(() => CaregiverHomepage());
        } else {
          Get.to(() => Role());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              itemCount: splashScreenList.length,
              itemBuilder: (context, index) {
                return PageBuilderWidget(
                  title: splashScreenList[index].titlestr,
                  description: splashScreenList[index].description,
                  imgurl: splashScreenList[index].imgStr,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imgurl;

  PageBuilderWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.imgurl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Image.asset(imgurl),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: Colors.deepOrange[900],
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.deepOrange[900],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
