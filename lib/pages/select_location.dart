import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/rest_location_model.dart';
import 'package:roster_app/pages/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SelectLocation extends StatefulWidget{
  SelectLocationState createState() => SelectLocationState();
}

class SelectLocationState extends State<SelectLocation>{

  Future<List<String>> getUserIdAndEntityId() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String userId = mPref.getString('user_id').toString();
    String entityId = mPref.getString('user_entity_str').toString();
    List<String> mPrefList = [];
    mPrefList.add(userId);
    mPrefList.add(entityId);
    return mPrefList;
  }

  savePrefValue(String key, String value)async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    mPref.setString(key, value);
  }


  Future<dynamic> getRestaurantLocations(String userId, String entityId) async {
    // CommonMethods.showAlertDialog(context);
    Uri mUri = Uri.parse(ApiInterface.ALL_REST_LOCATION + userId+'/'+entityId);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    final response = await http.get(mUri);
    print('response.statusCode '+ApiInterface.ALL_RESTAURANT + userId);
    print('response.statusCode '+response.statusCode.toString());
    if (response.statusCode == 200) {
      print(response.body);
      // Navigator.pop(context);
      final String restrntLocationResponse = response.body;
      // Map mMap = jsonDecode(restrntLocationResponse);
      Map mMap = json.decode(restrntLocationResponse);
      String mStatus = mMap['status'];
      if(mStatus == 'error'){
        return 'no_entity';
      }
      else {
        RestrntLocationModel locationModel = restrntLocationModelFromJson(
            restrntLocationResponse);
        List<Location> allLocations = locationModel.location;
        // if(isEntityOne){
        if (allLocations.length == 1) {
          SharedPreferences mPref = await SharedPreferences.getInstance();
          GetLocation getEntity = allLocations[0].getLocation[0];
          mPref.setBool("login_status", true);
          savePrefValue('user_entity', getEntity.entityId.toString());
          savePrefValue('user_location', getEntity.locationId.toString());
          // Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => Dashboard()));
        }
        // }
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
        title: Text('Select Location'),
      ),
      body: FutureBuilder(
        future: getUserIdAndEntityId(),
        builder: (context,snapshot){
          if(snapshot.data == null){
            return Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(
                      fontSize: 17.0,
                      color: app_theme_dark_color,
                      fontWeight: FontWeight.w600
                  ),
                )
            );
          }
          else{
            List<String> listData = snapshot.data as List<String>;
            return FutureBuilder(
              future: getRestaurantLocations(listData[0],listData[1]),
              builder: (context, restSnap){
                if(restSnap.data == null){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: null,
                          strokeWidth: 3.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:5.0),
                          child: Center(
                              child: Text(
                                'Loading...',
                                style: TextStyle(
                                    fontSize: 17.0,
                                    color: app_theme_dark_color,
                                    fontWeight: FontWeight.w600
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else if(restSnap.data.toString() == 'no_entity'){
                  return Center(
                      child: Text(
                          'No Location found',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: app_theme_dark_color,
                          fontWeight: FontWeight.w600
                        ),
                      )
                  );
                }
                else{
                  List<GetLocation> mListData = restSnap.data as List<GetLocation>;
                  return ListView.builder(
                    itemCount: mListData.length,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: ()async{
                          SharedPreferences mPrf = await SharedPreferences.getInstance();
                          mPrf.setString('user_location_str', mListData[i].locationId.toString());
                          mPrf.setString('user_location_name', mListData[i].locationAddress);
                          Navigator.pop(context, mListData[i]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(
                                      mListData[i].locationAddress
                                  ),
                                ),
                              ),
                              Divider(thickness: 0.5,)
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}