import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:http/http.dart' as http;
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/restaurant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectRestaurant extends StatefulWidget{
  SelectRestaurantState createState() => SelectRestaurantState();
}

class SelectRestaurantState extends State<SelectRestaurant>{

  Future<String> getUserId() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String userId = mPref.getString('user_id').toString();
    return userId;
  }

  Future getRestaurantData(String userId) async {
    Uri mUri = Uri.parse(ApiInterface.ALL_RESTAURANT+userId);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    final response = await http.get(mUri);
    print('response.statusCode '+ApiInterface.ALL_RESTAURANT + userId);
    if (response.statusCode == 200) {
      final String restrntResponse = response.body;
      print(response.body);
      Map<String, dynamic> resMap = json.decode(restrntResponse.trim());
      var status = resMap['status'];
      if(status == 'error'){
        return 'no_entity';
      }
      else{
        RestaurantModel restaurantModel = restaurantModelFromJson(
            restrntResponse);
        List<Entity> restrntList = restaurantModel.entity;
        if(restrntList.length == 1){
          // isEntityOne = true;
        }
        if (restrntList.length != 0) {
          List<GetEntity> gtEnttList = [];
          for(int i=0;i<restrntList.length;i++){
            GetEntity getEntity = restrntList[i].getEntity[0];
            gtEnttList.add(getEntity);
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Restaurant'),
      ),
      body: FutureBuilder(
        future: getUserId(),
        builder: (context,snapshot){
          if(snapshot.data == null){
            return Text('Loading...');
          }
          else{
            return FutureBuilder(
              future: getRestaurantData(snapshot.data.toString()),
              builder: (context, restSnap){
                if(restSnap.data == null){
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
                  List<GetEntity> mListData = restSnap.data as List<GetEntity>;
                  return ListView.builder(
                    itemCount: mListData.length,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: ()async{
                          SharedPreferences mPrf = await SharedPreferences.getInstance();
                          mPrf.setString('user_entity_str', mListData[i].entityId.toString());
                          mPrf.setString('user_entity_name', mListData[i].entityName);
                          Navigator.pop(context,mListData[i]);
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
                                      mListData[i].entityName
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