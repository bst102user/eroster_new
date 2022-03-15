import 'dart:convert';
import 'dart:io';

import 'package:clean_swiper/clean_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/scheduler_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NextWeekPage extends StatelessWidget{
  late int clockStatus;
  bool isMonthBreak = false;
  String mCrntMnth = '';
  String getDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  int getNumberOfDayOfWeek(){
    DateTime date = DateTime.now();
    print("weekday is ${date.weekday}");
    return date.weekday-1;
  }

  List<String> listOf7Days(){
    List<String> dayList = [];
    DateTime today = DateTime.now();
    for(int i=0;i<7;i++) {
      var _firstDayOfTheweek = today.subtract(
          new Duration(days: today.weekday - 8-i));
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate2 = formatter.format(_firstDayOfTheweek);
      dayList.add(formattedDate2);
    }
    return dayList;
  }

  String compareCurrentDate(List<dynamic> list, String myDate){
    String returnDate = '';
    for(int i=0;i<list.length;i++){
      if(myDate == list[i].scheduleDate){
        returnDate = list[i].scheduleDate!;
      }
    }
    return returnDate;
  }

  String getStartTime(List<dynamic> list, String myDate){
    String startDate = 'no_roster';
    for(int i=0;i<list.length;i++){
      if(myDate == list[i].scheduleDate){
        startDate = list[i].scheduleStartTime!;
      }
    }
    return startDate;
  }

  String getEndTime(List<dynamic> list, String myDate){
    String endTime = '';
    for(int i=0;i<list.length;i++){
      if(myDate == list[i].scheduleDate){
        endTime = list[i].scheduleEndTime!;
      }
    }
    return endTime;
  }

  Future<List<String>> getLoginToken()async{
    List<String> prefDataList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token').toString();
    String userEntity = prefs.getString('user_entity_str').toString();
    String userLocation = prefs.getString('user_location_str').toString();
    prefDataList.add(userToken);
    prefDataList.add(userEntity);
    prefDataList.add(userLocation);
    return prefDataList;
  }

  Future<dynamic>getCurrentWeekSchedular1(String startDate, String endDate,String loginToken,String entityId, locationId)async{
    isMonthBreak = false;
    mCrntMnth = '';
    var mBody = {
      "remember_token": loginToken,
      "start_date": startDate,
      "last_date": endDate,
      "entityID":entityId,
      "locationID":locationId
    };
    Uri mUri = Uri.parse(ApiInterface.SCHEDULER);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if (response.statusCode == 200) {
      final String loginResponse = response.body;
      print(response.body);
      Map<String, dynamic> d = json.decode(loginResponse.trim());
      var status = d["success"];
      // clockStatus = d["clock_status"];
      // attendanceIdInt = d["attendanceID"]
      // if(attendanceIdInt == null){
      //   attendanceIdInt = '0';
      // }
      if (status != 'success') {
        CommonMethods.showToast('We are experiencing a technical error. Please try again in sometime');
        return 'data_not_found';
      }
      else {
        SchedulerModel schedulerModel = schedulerModelFromJson(response.body);
        List<Datum> userSchedule = schedulerModel.data as List<Datum>;
        if(userSchedule.length == 0){
          return 'data_not_found';
        }
        else {
          List<Datum> testSchedule = [];
          List<String> myDates = listOf7Days();
          String mtFirstDate = myDates[0].substring(myDates[0].length - 2);
          int mtFirstDateInt = int.parse(mtFirstDate);
          int shouldLen = listOf7Days().length;
          for (int i = 0; i < shouldLen; i++) {
            if(i==userSchedule.length){
              testSchedule.add(new Datum(
                  scheduleDate: DateTime.parse(listOf7Days()[0]).toString(),
                  scheduleStartTime: 'not found',
                  scheduleEndTime: 'not found'));
              i--;
              shouldLen--;
            }
            else {
              int serverDate = int.parse(userSchedule[i].scheduleDate!.split('-')[2]);
              String currentMonth = userSchedule[i].scheduleDate!.split('-')[1];
              if(currentMonth != mCrntMnth&&mCrntMnth!=''){
                isMonthBreak = true;
              }
              mCrntMnth = currentMonth;
              String currentYear = CommonMethods.getCurrentYear();
              int currentYearInt = int.parse(currentYear);
              if(currentMonth == '01'||currentMonth == '03'||currentMonth == '05'||currentMonth == '07'||currentMonth == '08'||currentMonth == '10'||currentMonth == '12'){
                if (mtFirstDateInt == 32||(mtFirstDateInt == 29&&isMonthBreak)) {
                  mtFirstDateInt = 1;
                }
              }
              else if(currentMonth == '04'||currentMonth == '06'||currentMonth == '09'||currentMonth == '11'){
                if (mtFirstDateInt == 31||(mtFirstDateInt == 32&&isMonthBreak)) {
                  mtFirstDateInt = 1;
                }
              }
              else{
                if (currentYearInt/4==0) {
                  if(mtFirstDateInt == 29) {
                    mtFirstDateInt = 1;
                  }
                }
                else{
                  if(mtFirstDateInt == 32) {
                    mtFirstDateInt = 1;
                  }
                }
              }
              if (mtFirstDateInt != serverDate) {
                testSchedule.add(new Datum(
                    scheduleDate: DateTime.parse(listOf7Days()[0]).toString(),
                    scheduleStartTime: 'not found',
                    scheduleEndTime: 'not found'));
                i--;
                shouldLen--;
              }
              else {
                testSchedule.add(userSchedule[i]);
              }
              if(currentMonth == '04'||currentMonth == '06'||currentMonth == '09'||currentMonth == '11'){
                if(mtFirstDateInt == 30){
                  mtFirstDateInt = mtFirstDateInt+1;
                }
              }
              mtFirstDateInt++;
            }
          }
          if (userSchedule.length == 0) {
            return 'data_not_found';
          }
          else {
            return testSchedule;
          }
        }
      }
    }
  }

  Future<dynamic>getCurrentWeekSchedular(String startDate, String endDate,String loginToken,String entityId, locationId)async{
    List<Datum> usedList = [];
    var mBody = {
      "remember_token": loginToken,
      "start_date": startDate,
      "last_date": endDate,
      "entityID":entityId,
      "locationID":locationId
    };
    Uri mUri = Uri.parse(ApiInterface.SCHEDULER);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if (response.statusCode == 200) {
      final String loginResponse = response.body;
      print(response.body);
      Map<String, dynamic> d = json.decode(loginResponse.trim());
      var status = d["success"];
      clockStatus = d["clock_status"];
      if (status != 'success') {
        CommonMethods.showToast('We are experiencing a technical error. Please try again in sometime');
        return 'data_not_found';
      }
      else {
        SchedulerModel schedulerModel = schedulerModelFromJson(response.body);
        List<Datum> userSchedule = schedulerModel.data as List<Datum>;
        if(userSchedule.length == 0){
          return 'data_not_found';
        }
        else{
          int listLen = userSchedule.length;
          int addLength = 7-listLen;
          for(int i=0;i<addLength;i++){
            usedList.add(Datum(
                scheduleDate: '',
                scheduleStartTime: 'not found',
                scheduleEndTime: 'not found'));
          }
          var newList = new List.from(usedList)..addAll(userSchedule);
          return newList;
        }
      }
    }
  }


  String getFirstDateOfNextWeek(int daysNum){
    DateTime today = DateTime.now();
    var _firstDayOfTheweek = today.subtract(new Duration(days: today.weekday-8-daysNum));
    var formatter = new DateFormat('dd MMM');
    String formattedDate2 = formatter.format(_firstDayOfTheweek);
    String day = DateFormat('EEEE').format(_firstDayOfTheweek);
    return formattedDate2+' ('+day+')';
  }

  Widget mCustomPage(String dateStr, String startTimeStr, String endTimeStr, int pageNumber,Datum userSchedule){
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                dateStr,
                style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: '.SF UI Display',
                    fontWeight: FontWeight.w800,
                    color: app_theme_dark_color
                ),
              ),
              startTimeStr == 'no_roster'?Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.speaker_notes_off_rounded,
                        size: 50.0,
                        color: app_theme_dark_color,
                      ),
                      Text(
                        'You are not scheduled on the Roster',
                        style: TextStyle(
                          color: app_theme_dark_color,

                        ),
                      ),
                    ],
                  ),
                ),
              ):Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Text(
                      'Start Time: '+startTimeStr,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: app_theme_dark_color
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'End Time: '+endTimeStr,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: app_theme_dark_color
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget nextWeekData(){
    final date = DateTime.now();
    return FutureBuilder(
      future: getLoginToken(),
      builder: (context,snapshot1){
        if(snapshot1.data == null){
          return Text('');
        }
        else{
          List mList = snapshot1.data as List;
          return FutureBuilder(
            future: getCurrentWeekSchedular(anyDayOfWeek(7),anyDayOfWeek(13),mList[0],mList[1],mList[2]),
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
              else if(snapshot.data == 'data_not_found'){
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.speaker_notes_off_rounded,
                        size: 50.0,
                        color: app_theme_dark_color,
                      ),
                      Text(
                        'You are not scheduled on the Roster this week',
                        style: TextStyle(
                          color: app_theme_dark_color,

                        ),
                      ),
                    ],
                  ),
                );
              }
              else{
                List userSchedule = snapshot.data as List;
                return CleanSwiper(
                    viewportFraction: 0.9,
                    initialPage: 0,
                    children: <Widget>[
                      mCustomPage(anyDayOfWeek(7),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 8)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 8)))),0,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(8),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 9)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 9)))),1,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(9),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 10)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 10)))),2,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(10),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 11)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 11)))),3,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(11),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 12)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 12)))),4,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(12),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 13)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 13)))),5,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(13),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 14)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 14)))),6,userSchedule[0]
                      ),
                    ]
                );
              }
            },
          );
        }
      },
    );
  }

  String anyDayOfWeek(int daysNum){
    DateTime today = DateTime.now();
    var _firstDayOfTheweek = today.subtract(new Duration(days: today.weekday-1-daysNum));
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate2 = formatter.format(_firstDayOfTheweek);
    return formattedDate2;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return nextWeekData();
  }

}