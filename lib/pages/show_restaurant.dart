import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/rest_location_model.dart';
import 'package:roster_app/models/restaurant_model.dart';
import 'package:http/http.dart' as http;
import 'package:roster_app/pages/dashboard.dart';
import 'package:roster_app/pages/select_location.dart';
import 'package:roster_app/pages/select_restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowRestaurant extends StatefulWidget {
  ShowRestaurantState createState() => ShowRestaurantState();
}

class ShowRestaurantState extends State<ShowRestaurant> {
  GetEntity? selectedEntity;
  List<GetEntity>? entityList;

  String selectedLocation = 'Select Location';
  late List<GetLocation> locationList;
  bool isEntitySelected = false;
  String selectEntity = 'Select Entity';

  @override
  void initState() {
    super.initState();
    getUserId().then((userId) {
      getRestaurantData(userId).then((entityValue) {
        // print('entityValue '+entityValue);
        if (entityValue != null) {
          setState(() {
            if (entityValue == 'no_entity') {
              setState(() {
                // entityList = 'no_entity';
              });
            }
            else {
              entityList = entityValue;
              if (entityList!.length == 1) {
                isEntitySelected = true;
                selectedEntity = entityList![0];
                savePrefValue('user_entity', selectedEntity!.entityId.toString());
              }
              getRestaurantLocations(userId, selectedEntity!.entityId.toString()).then((
                  locationValue) {
                setState(() {
                  locationList = locationValue;
                });
              });
            }
          });
        }
      });
    });
  }

  savePrefValue(String key, String value) async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    mPref.setString(key, value);
  }

  Future<String> getUserId() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String userId = mPref.getString('user_id').toString();
    return userId;
  }

  Future<String> getEntity() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String entityStr = mPref.getString('user_entity_name').toString();
    return entityStr;
  }

  Future<String> getLocation() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String locationStr = mPref.getString('user_location_name').toString();
    return locationStr;
  }

  Future getRestaurantData(String userId) async {
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    Uri mUri = Uri.parse(ApiInterface.ALL_RESTAURANT + userId);
    final response = await http.get(mUri);
    print('response.statusCode ' + ApiInterface.ALL_RESTAURANT + userId);
    if (response.statusCode == 200) {
      final String restrntResponse = response.body;
      print(response.body);
      Map<String, dynamic> resMap = json.decode(restrntResponse.trim());
      var status = resMap['status'];
      if (status == 'error') {
        return 'no_entity';
      }
      else {
        RestaurantModel restaurantModel = restaurantModelFromJson(
            restrntResponse);
        List<Entity> restrntList = restaurantModel.entity;
        if (restrntList.length == 1) {
          isEntitySelected = true;
        }
        if (restrntList.length != 0) {
          List<GetEntity> gtEnttList = [];
          for (int i = 0; i < restrntList.length; i++) {
            GetEntity getEntity = restrntList[i].getEntity[0];
            gtEnttList.add(getEntity);
          }
          if (gtEnttList.length == 1) {
            SharedPreferences mPref = await SharedPreferences.getInstance();
            mPref.setString('user_entity_str', gtEnttList[0].entityId.toString());
            mPref.setString('user_entity_name', gtEnttList[0].entityName);
          }
          return gtEnttList;
        }
        else {
          return 'no_entity';
        }
      }
    }
    else {
      return 'server_error';
    }
  }

  Future<dynamic> getRestaurantLocations(String userId, String entityId) async {
    CommonMethods.showAlertDialog(context);
    Uri mUri = Uri.parse(
        ApiInterface.ALL_REST_LOCATION + userId + '/' + entityId);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    final response = await http.get(mUri);
    if (response.statusCode == 200) {
      print(response.body);
      Navigator.pop(context);
      final String restrntLocationResponse = response.body;
      RestrntLocationModel locationModel = restrntLocationModelFromJson(
          restrntLocationResponse);
      List<Location> allLocations = locationModel.location;
      if(selectEntity == 'Select Entity'){
        isEntitySelected = false;
      }
      else{
        isEntitySelected = true;
      }
      if (isEntitySelected) {
        if (allLocations.length == 1) {
          SharedPreferences mPref = await SharedPreferences.getInstance();
          GetLocation getEntity = allLocations[0].getLocation[0];
          mPref.setBool("login_status", true);
          savePrefValue('user_entity_str', getEntity.entityId.toString());
          savePrefValue('user_location_str', getEntity.locationId.toString());
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (BuildContext context) => Dashboard()));
        }
      }
      if (allLocations.length != 0) {
        List<GetLocation> gtLocList = [];
        for (int i = 0; i < allLocations.length; i++) {
          GetLocation getEntity = allLocations[i].getLocation[0];
          gtLocList.add(getEntity);
        }
        return gtLocList;
      }
      else {
        return 'no_entity';
      }
    }
    else {
      return 'server_error';
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant and Location'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: getEntity(),
                builder: (context, snapshot){
                  if(snapshot.data == null||snapshot.data.toString() == 'null'){
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0,left: 5.0, bottom: 5.0),
                      child: Text('Select Entity'),
                    );
                  }
                  else{
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0,left: 5.0, bottom: 5.0),
                      child: Text('Select Entity('+snapshot.data.toString()+')'),
                    );
                  }
                },
              ),
              FutureBuilder(
                future: getUserId(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Text('Loading...');
                  }
                  else {
                    return FutureBuilder(
                      future: getRestaurantData(snapshot.data.toString()),
                      builder: (context, restSnap) {
                        if (restSnap.data == null) {
                          return Text('Loading...');
                        }
                        else {
                          List<GetEntity> listEntty = restSnap.data as List<GetEntity>;
                          if (listEntty.length == 1) {
                            selectEntity = listEntty[0].entityName;
                            return Container(
                                height: 45.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: app_theme_dark_color,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20))
                                ),
                                child: Center(
                                    child: Text(selectEntity))
                            );
                          }
                          else {
                            return InkWell(
                              onTap: () async {
                                GetEntity result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectRestaurant(),
                                    ));
                                setState(() {
                                  print(result);
                                  selectEntity = result.entityName;
                                  String entityId = result.entityId.toString();
                                  getRestaurantLocations(snapshot.data.toString(), entityId);
                                });
                              },
                              child: Container(
                                  height: 45.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: app_theme_dark_color,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))
                                  ),
                                  child: Center(child: Text(selectEntity))
                              ),
                            );
                          }
                        }
                      },
                    );
                  }
                },
              ),
              FutureBuilder(
                future: getLocation(),
                builder: (context, snapshot){
                  if(snapshot.data == null||snapshot.data.toString() == 'null'){
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0,left: 5.0, bottom: 5.0),
                      child: Text('Select Location'),
                    );
                  }
                  else{
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0,left: 5.0, bottom: 5.0),
                      child: Text('Select Location('+snapshot.data.toString()+')'),
                    );
                  }
                },
              ),
              InkWell(
                onTap: () async {
                  if(selectEntity == 'Select Entity'){
                    CommonMethods.showToast('Please select entity first');
                  }
                  else {
                    GetLocation result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectLocation(),
                        ));
                    setState(() {
                      selectedLocation = result.locationAddress;
                      print(result);
                    });
                  }
                },
                child: Container(
                    height: 45.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: app_theme_dark_color,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: Center(
                      child: FutureBuilder(
                        future: getLocation(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Text('Loading...');
                          }
                          else if (snapshot.data == ''||snapshot.data == 'null') {
                            return Text(selectedLocation);
                          }
                          else {
                            return Text(snapshot.data as String);
                          }
                        },
                      ),
                    )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: RaisedButton(
                    color: app_theme_dark_color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () async {
                      if (selectedLocation == '' || selectedLocation == 'Select Location'||selectEntity == ''||selectEntity == 'Select Entity') {
                        CommonMethods.showToast(
                            'Please select entity and location');
                      }
                      else {
                        SharedPreferences mPref = await SharedPreferences
                            .getInstance();
                        mPref.setBool("login_status", true);
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (BuildContext context) => Dashboard()));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 8.0),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white
                        ),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

