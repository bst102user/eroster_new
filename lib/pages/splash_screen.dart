import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roster_app/pages/login.dart';
import 'package:roster_app/pages/tes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';


class Splash extends StatefulWidget {
  // Splash({Key key, this.title}) : super(key: key);
  // final String title;
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  getFcmToken(){
    _firebaseMessaging.getToken().then((token){
      print(token);
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFcmToken();
    Timer(Duration(milliseconds: 3), goToNext); //
  }

  void goToNext() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    bool checkLoginStatus = mPref.get("login_status") as bool;
    if (checkLoginStatus == null) {
      checkLoginStatus = false;
    }
    if (checkLoginStatus) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Tes()),
              (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      backgroundColor: const Color(0xFFeaa603),
      appBar: AppBar(
        title: Text('ee'),
      ),
      body: FittedBox(
        // child: Image.asset(
        //   'assets/images/splash_icon.png',
        // height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        // ),
        fit: BoxFit.fill,
      ),
    );

  }
}