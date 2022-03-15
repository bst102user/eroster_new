import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget{
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage>{

  Future<List> getLoginToken()async{
    List prefData = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token').toString();
    String userId = prefs.getString('user_id').toString();
    prefData.add(userToken);
    prefData.add(userId);
    return prefData;
  }

  Future<dynamic> getNotifData(String userToken,String userId)async{
    var mBody = {
      "remember_token": userToken,
      "user_id": userId,
    };
    Uri mUri = Uri.parse(ApiInterface.NOTIFICATION_LIST);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if(response.statusCode == 200){
      NotificationModel notificationModel = notificationModelFromJson(response.body);
      List<Success> dataList = notificationModel.success;
      if(dataList.length == 0){
        return 'no_data_key';
      }
      else{
        return dataList;
      }
    }
    else{
      return 'no_data_key';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getLoginToken(),
          builder: (context, tokenSnap){
            if(tokenSnap.data == null){
              return Text('');
            }
            else{
              List tokenSnpList = tokenSnap.data as List;
              return FutureBuilder(
                future: getNotifData(tokenSnpList[0],tokenSnpList[1]),
                builder: (context, snapshot){
                  if(snapshot.data == null){
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  else if(snapshot.data == 'no_data_key'){
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.notifications_off_outlined,
                            color: app_theme_dark_color,
                            size: 50.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No Notification found for you',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: app_theme_dark_color
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  else{
                    List<Success> itemList = snapshot.data as List<Success>;
                    return itemList[0].massege==null?Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.notifications_off_outlined,
                            color: app_theme_dark_color,
                            size: 50.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No Notification found for you',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: app_theme_dark_color
                              ),
                            ),
                          )
                        ],
                      ),
                    ):ListView.builder(
                      itemCount: itemList.length,
                      itemBuilder: (context, index){
                        List<Success> itemList = snapshot.data as List<Success>;
                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      itemList[index].title.toString()==null?'No Data':itemList[index].title.toString().replaceFirst(r"Title.",""),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.0,
                                        color: app_theme_dark_color
                                      ),
                                    ),
                                    Text(
                                        CommonMethods.convertDateTimeDisplay(itemList[index].createdAt.toString()),
                                    style: TextStyle(
                                      color: app_theme_dark_color
                                    ),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    itemList[index].massege==null?'No Data':itemList[index].massege,
                                  style: TextStyle(
                                    color: app_theme_dark_color
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              );
            }
          },
        )
      ),
    );
  }

}