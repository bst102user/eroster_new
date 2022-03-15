import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const Color app_theme_dark_color = Color(0xFF401461);

class CommonMethods{
  static String getCurrentDate(int dayNum){
    var now = new DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + dayNum);
    var formatter = new DateFormat('dd MMM');
    String formattedDate = formatter.format(tomorrow);
    String day = DateFormat('EEEE').format(tomorrow);
    return formattedDate+' ('+day+')';
  }

  static String getCurrentTime(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  static String  getCurrentOnlyDate(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  static void showAlertDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5),child:Text("Loading" )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  static String getAfter7thDaysDate(int dayNum){
    var now = new DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day+7 + dayNum);
    var formatter = new DateFormat('dd MMM');
    String formattedDate = formatter.format(tomorrow);
    String day = DateFormat('EEEE').format(tomorrow);
    return formattedDate+' ('+day+')';
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  static savePrefStr(String key, String message) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, message);
  }

  static readPrefStr(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static showMessageDialog(BuildContext context,String title,String content) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
    final DateFormat serverFormater = DateFormat('dd MMM yyyy');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    final DateFormat serverFormater1 = DateFormat('HH:mm');
    final DateTime displayTime = displayFormater.parse(date);
    final String timeFormated = serverFormater1.format(displayTime);
    return formatted+'\n'+timeFormated;
  }

  static String convertDateTimeDisplay2(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd');
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  static Future<String> getId(context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  static String getCurrentMonth(){
    var now = new DateTime.now();
    var formatter = new DateFormat('MM');
    return formatter.format(now);
  }

  static String getCurrentYear(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy');
    return formatter.format(now);
  }
}