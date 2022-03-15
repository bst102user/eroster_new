import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:location/location.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/LoginModel.dart';
import 'package:roster_app/pages/select_location.dart';
import 'package:roster_app/pages/select_restaurant.dart';
import 'package:roster_app/pages/show_restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  late String fcmTokenStr;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Location location = Location();
  bool _obscureText = true;

  goToMainPage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ShowRestaurant()),
        // MaterialPageRoute(builder: (context) => SelectLocation()),
        (Route<dynamic> route) => false);
  }

  Future<bool> openLocationSetting() async {
    bool serviceStatus = await location.serviceEnabled();
    return serviceStatus;
  }

  Future<String> getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fcmTokenStr = prefs.getString('firebase_token').toString();
    return fcmTokenStr;
  }

  removeSharedValue() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    mPref.setString('user_entity_str','');
    mPref.setString('user_location_str','');
  }


  @override
  void initState() {
    super.initState();
//     emailController.text = 'testingteam2@gmail.com';
//     passController.text = 'testing';
    // initPlatformState();
    getFcmToken();
    removeSharedValue();
  }
  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  loginUser(String username, String password) async {
    if (_formKey.currentState!.validate()) {
      openLocationSetting().then((value) {
        if (value) {
          CommonMethods.showAlertDialog(context);
          CommonMethods.getId(context).then((value1){
            getFcmToken().then((value) async {
              var mBody = {
                "email": username,
                "password": password,
                "userToken": value,
                "device_id": value1
              };
              final ioc = new HttpClient();
              ioc.badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
              final http = new IOClient(ioc);
              print(mBody.toString());
              Uri mUri = Uri.parse(ApiInterface.LOGIN_USER);
              final response =
              await http.post(mUri, body: mBody);
              print(response.body);
              if (response.statusCode == 200) {
                Navigator.pop(context);
                final String loginResponse = response.body;
                print(response.body);
                Map<String, dynamic> d = json.decode(loginResponse.trim());
                // var status = d["status"];
                var status = d["status"];
                if (status != 'success') {
                  if(status == 'notRegistered'){
                    CommonMethods.showToast(
                        d["message"]);
                  }
                  else if(status == 'false'){
                    CommonMethods.showToast(d["message"]);
                  }
                  else if(status == 'Error'){
                    CommonMethods.showToast(d["message"]);
                  }
                } else {
                  LoginModel loginModal = loginModelFromJson(response.body);
                  SharedPreferences mPref = await SharedPreferences.getInstance();
                  CommonMethods.savePrefStr("user_token", loginModal.data);
                  mPref.setString(
                      "email_pref", loginModal.userDetails.userLoginEmail);
                  mPref.setString(
                      "f_name_pref", loginModal.userDetails.userFirstName);
                  mPref.setString(
                      "l_name_pref", loginModal.userDetails.userLastName);
                  mPref.setString(
                      "mobile_pref", loginModal.userDetails.userPhoneNo);
                  mPref.setString(
                      "address_pref", loginModal.userDetails.userAddress);
                  mPref.setString(
                      "user_id", loginModal.userDetails.userId.toString());
                  CommonMethods.showToast('Login Success');
                  // getLocationData(loginModal.data);
                  goToMainPage();
                }
                print(loginResponse);
              } else {
                Navigator.of(context).pop();
                CommonMethods.showToast(
                    'Oops! You have entered invalid credentials');
                return null;
              }
            });
          });
        } else {
          CommonMethods.showToast('Enable your device location');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  // child: Image.asset('assets/images/splash_icon_test.png'),
                  child: Image.asset('assets/images/splash_icon.png'),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            return val!.isEmpty ? 'Please enter email' : null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: passController,
                            obscureText: _obscureText,
                            validator: (val) {
                              return val!.isEmpty
                                  ? 'Please enter password'
                                  : null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon:  IconButton(
                                icon:Icon(_obscureText ? Icons.visibility_off:Icons.visibility,),
                                onPressed: _togglePasswordStatus,
                                color: app_theme_dark_color,
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: MaterialButton(
                      onPressed: () {
                        loginUser(emailController.text, passController.text);
                        // print('_platformImei:- '+_idMap.toString());
                      },
                      minWidth: double.infinity,
                      color: const Color(0xFF401461),
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
