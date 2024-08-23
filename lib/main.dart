import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:kindercare/forgotPassword/forgot_password_service.dart';
import 'package:kindercare/forgotPassword/forgot_pwd_bloc.dart';
import 'package:kindercare/forgotPassword/reset_password.dart';
import 'package:kindercare/model/attendance_model.dart';
import 'package:kindercare/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize("4eac3324-d5f1-4b7c-8844-b9763c44e601");
  OneSignal.Notifications.requestPermission(true);  
  OneSignal.Notifications.addPermissionObserver((state) {
    print("Has permission " + state.toString());
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceModel()),
      ],
      child: BlocProvider(
        create: (context) => ForgotPwdBloc(ForgotPasswordService()),
        child: const MyApp(),
      ),
    ),
  );  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        Uri uri = Uri.parse(link);
        if (uri.pathSegments.contains('password-reset')) {
          String? token = uri.queryParameters['token'];
          String? email = uri.queryParameters['email'];
          
          if (token != null && email != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(email: email, token: token),
              ),
            );
          }
        }
      }
    }, onError: (err) {
      print('Failed to receive link: $err');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KinderCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
