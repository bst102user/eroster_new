import 'dart:convert';

import 'package:clean_swiper/clean_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:roster_app/common/api_interface.dart';
import 'package:roster_app/common/common_methods.dart';
import 'package:roster_app/models/location_model.dart';
import 'package:roster_app/models/scheduler_model.dart';
import 'package:roster_app/pages/login.dart';
import 'package:roster_app/pages/next_week_page.dart';
import 'package:roster_app/pages/notification_page.dart';
import 'package:roster_app/pages/profile_page.dart';
import 'package:roster_app/pages/show_restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Tes extends StatefulWidget{
  TesState createState() => TesState();
}

class TesState extends State<Tes>{
  late int clockStatus;
  var location = Location();
  bool checkLocationFirstTime = true;
  bool checkLocationFirstTime2 = true;
  late double distanceInMeters;
  late String userId;
  String fNameStr = '';
  String lNameStr = '';
  String emailStr = '';
  String mobileStr = '';
  late String titleStr;
  late String userToken;
  late String serverLat;
  late String serverLongi;
  late String attendanceId;
  late bool isUserClockIn;
  bool isCurrentWeek = true;
  late String mToken;
  double mLatitude = 0.0;
  double mLongitude = 0.0;
  late Widget bodyWidget;
  String attendanceIdInt = '0';
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  late String _hour, _minute, _lateClockOutTime;
  late String rosterIdCurrentDay;
  int index = 0;
  String getDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  // String dates = DateFormat('yyyy-MM-dd – kk:mm').format(now)

  String anyDayOfWeek(int daysNum){
    DateTime today = DateTime.now();
    var _firstDayOfTheweek = today.subtract(new Duration(days: today.weekday-1-daysNum));
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate2 = formatter.format(_firstDayOfTheweek);
    return formattedDate2;
  }

  getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fNameStr = (prefs.getString('f_name_pref') ?? '');
      lNameStr = (prefs.getString('l_name_pref') ?? '');
      emailStr = (prefs.getString('email_pref') ?? '');
      mobileStr = (prefs.getString('mobile_pref') ?? '');
      userId = (prefs.getString('user_id') ?? '');
      serverLat = (prefs.getString('server_latitude') ?? '');
      serverLongi = (prefs.getString('server_longitude') ?? '');
      mToken = (prefs.getString('user_token') ?? '');
      attendanceId = (prefs.getString('attendance_id') ?? '');
      isUserClockIn = (prefs.getBool('is_clock_in') ?? false);
    });
  }

  int getNumberOfDayOfWeek(){
    DateTime date = DateTime.now();
    return date.weekday-1;
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
      attendanceIdInt = d["attendanceID"];
      if(attendanceIdInt == null){
        attendanceIdInt = '0';
      }
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
          rosterIdCurrentDay = newList[getNumberOfDayOfWeek()].rosterId.toString();
          return newList;
        }
      }
    }
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

  Future<List<String>> getPreferenceData() async{
    List<String> saveDataList = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('user_token').toString();
    String entityId = preferences.getString('user_entity_str').toString();
    String locationId = preferences.getString('user_location_str').toString();
    String userId = preferences.getString('user_id').toString();
    saveDataList.add(token);
    saveDataList.add(entityId);
    saveDataList.add(locationId);
    saveDataList.add(userId);
    return saveDataList;
  }

  Future<String> getAttandenceId() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('attendance_id').toString();
    return token;
  }

  Future getDistanceBtwnTwoPoints(double startLatitude,double startLongitude,double endLatitude,double endLongitude) async{
    if(startLatitude == null){
      startLatitude = 0.0;
    }
    else if(startLongitude == null){
      startLongitude = 0.0;
    }
    else if(endLatitude == null){
      endLatitude = 0.0;
    }
    else if(endLongitude == null){
      endLongitude = 0.0;
    }
    distanceInMeters = Geolocator.distanceBetween(startLatitude,startLongitude,endLatitude,endLongitude);
    return distanceInMeters;
  }

  saveClockInTime(String rosterId,String userGrpId,String beforeFlag,String entityId, String locationId)async{
    CommonMethods.showAlertDialog(context);
    var mBody = {
      "user_id":userId,
      "roster_id":rosterId,
      "user_group_id":userGrpId,
      "attendance_date":CommonMethods.getCurrentOnlyDate(),
      "check_in_time": CommonMethods.getCurrentTime(),
      "remember_token":mToken,
      "before_time":beforeFlag,
      "entity_id":entityId,
      "location_id":locationId
    };
    print('mBody: '+mBody.toString());
    Uri mUri = Uri.parse(ApiInterface.CLOCK_IN);
    // final ioc = new HttpClient();
    // ioc.badCertificateCallback =
    //     (X509Certificate cert, String host, int port) => true;
    // final http = new IOClient(ioc);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if (response.statusCode == 200) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('is_clock_in', true);
      Navigator.pop(context);
      final String loginResponse = response.body;
      print(response.body);
      Map<String, dynamic> d = json.decode(loginResponse.trim());
      var status = d["success"];
      String attendanceId = d['attendanceId'].toString();
      preferences.setString('attendance_id', attendanceId);
      if (status == 'success') {
        CommonMethods.showToast('Successfully clocked in');
        if(mounted){
          setState(() {
            isUserClockIn = true;
          });
        }
        (context as Element).reassemble();
      } else {
        CommonMethods.showToast('Something went wrong');
      }
      print(loginResponse);
    }
  }

  _getCurrentLocation() {
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          mLatitude = locationData.latitude!;
          mLongitude = locationData.longitude!;
        });
      }
    });
  }

  Future _getEmailId()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('email_pref');
  }

  _checkDeviceValidation(){
    _getEmailId().then((emailStr){
      CommonMethods.getId(context).then((deviceId)async{
        Map sendMap = {
          'email':emailStr,
          'device_id':deviceId,
        };
        Uri mUri = Uri.parse(ApiInterface.DEVICE_VALIDATION);
        // final ioc = new HttpClient();
        // ioc.badCertificateCallback =
        //     (X509Certificate cert, String host, int port) => true;
        // final http = new IOClient(ioc);
        final response = await http.post(mUri, body: sendMap);
        final String orderResponse = response.body;
        Map<String, dynamic> d = json.decode(orderResponse.trim());
        var status = d["message"];
        if(status != 'Authorized'){
          SharedPreferences mPref = await SharedPreferences.getInstance();
          mPref.setBool("login_status", false);
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              ModalRoute.withName("/payment"));
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bodyWidget = mBodyWidget();
    _getCurrentLocation();
    getPrefData();
    getLoginToken().then((value){
      if(mounted){
        setState(() {
          userToken = value as String;
        });
      }
    });
    titleStr = 'My Roster';
    _checkDeviceValidation();
    // _showNotification();
  }

  Widget mBodyWidget(){
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(40.0),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: TabBar(
                  unselectedLabelColor: app_theme_dark_color,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [app_theme_dark_color, app_theme_dark_color]),
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.redAccent),
                  tabs: [
                    Container(
                      // width: MediaQuery.of(context).size.width * 0.5,
                      // width: 100,
                      // height: 30.0,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                          child: Text(
                              'This Week'
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width * 0.5,
                      // width: 100,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                          child: Text(
                              'Next Week'
                          ),
                        ),
                      ),
                    ),
                  ],
                  isScrollable: true),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: TabBarView(
                children: [
                  thisWeekData(),
                  NextWeekPage(),
                ]
            ),
          ),
        ));
  }


  saveClockOutTime(String clockOutTime,locationFlag, String rosterId)async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String entityId = mPref.getString('user_entity_str').toString();
    String locationId = mPref.getString('user_location_str').toString();
    String userId = mPref.getString('user_id').toString();
    CommonMethods.showAlertDialog(context);
    var mBody = {
      "attendance_id": attendanceIdInt,
      "clock_out_time": clockOutTime,
      "remember_token": mToken,
      "roster_id": rosterId,
      "location": locationFlag,
      "entity_id": entityId,
      "location_id": locationId,
      "user_id": userId,
    };
    print("locationFlag   "+mBody.toString());
    Uri mUri = Uri.parse(ApiInterface.CLOCK_OUT);
    // final ioc = new HttpClient();
    // ioc.badCertificateCallback =
    //     (X509Certificate cert, String host, int port) => true;
    // final http = new IOClient(ioc);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      final String loginResponse = response.body;
      print(response.body);
      Map<String, dynamic> d = json.decode(loginResponse.trim());
      var status = d["success"];
      if (status == 'success') {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setBool('is_clock_in', false);
        CommonMethods.showToast('Successfully clocked out');
        if(mounted){
          setState(() {
            isUserClockIn = false;
          });
        }
        (context as Element).reassemble();
      } else {
        CommonMethods.showToast('Something went wrong');
      }
      print(loginResponse);
    }
  }


  Future<dynamic> getLocationData(String loginToken, String entityId, String locationId, String userId)async{
    var mBody = {
      "remember_token": loginToken,
      "entity_id": entityId,
      "location_id": locationId,
      "user_id": userId,
    };
    Uri mUri = Uri.parse(ApiInterface.GET_LOCATION);
    // final ioc = new HttpClient();
    // ioc.badCertificateCallback =
    //     (X509Certificate cert, String host, int port) => true;
    // final http = new IOClient(ioc);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if (response.statusCode == 200) {
      final String locationResponse = response.body;
      print(response.body);
      LocationModel locationModel = locationModelFromJson(locationResponse);
      List<Success> scsData = locationModel.success;
      String latiStr = scsData[0].locationLatitude;
      String longiStr = scsData[0].locationLongitude;
      SharedPreferences mPref = await SharedPreferences.getInstance();
      mPref.setString("server_latitude", latiStr);
      mPref.setString("server_longitude", longiStr);
      List<String> latLongList = [];
      latLongList.add(latiStr);
      latLongList.add(longiStr);
      return latLongList;
    } else {
      CommonMethods.showToast('Something went wrong');
      return null;
    }
  }

  _selectTime(BuildContext context) async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      if(mounted){
        setState(() {
          selectedTime = picked;
          String clockInDate = mPref.getString('clockin_date').toString();
          _hour = selectedTime.hour.toString();
          _minute = selectedTime.minute.toString();
          _lateClockOutTime = _hour + ':' + _minute+':'+'00';
          // String sendClockOutTime = CommonMethods.getCurrentOnlyDate()+' '+_lateClockOutTime;
          String sendClockOutTime = clockInDate+' '+_lateClockOutTime;
          saveClockOutTime(sendClockOutTime,'1',rosterIdCurrentDay);
        });
      }
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
                (pageNumber == getNumberOfDayOfWeek()&&startTimeStr!='no_roster')?Padding(
                padding: const EdgeInsets.only(top: 100.0,left: 50.0, right: 50.0),
                child: MaterialButton(
                    onPressed: ()async{
                      SharedPreferences mPref = await SharedPreferences.getInstance();
                      if(clockStatus == 0) {
                        checkLocationFirstTime = true;
                        CommonMethods.showAlertDialog(context);
                        getPreferenceData().then((sharedValue){
                          getLocationData(sharedValue[0],sharedValue[1],sharedValue[2],sharedValue[3]).then((value){
                            location.requestPermission().then((permissionStatus){
                              if (permissionStatus == PermissionStatus.granted) {
                                location.onLocationChanged.listen((locationData) {
                                  double mLatitude = locationData.latitude!;
                                  double mLongitude = locationData.longitude!;
                                  getDistanceBtwnTwoPoints(double.parse(value[0]), double.parse(value[1]),
                                      mLatitude,
                                      mLongitude).then((value){
                                    // Navigator.pop(context);
                                    if(checkLocationFirstTime){
                                      checkLocationFirstTime = false;
                                      if (value <= 50.0) {
                                        Navigator.pop(context);
                                        DateTime now = DateTime.now();
                                        String timeNow = DateFormat('HH:mm').format(now);
                                        String clockInDate = DateFormat('yyyy-MM-dd').format(now);
                                        mPref.setString('clockin_date', clockInDate);
                                        var format = DateFormat("HH:mm");
                                        var ctFormat = format.parse(userSchedule.scheduleStartTime!);
                                        var nowTimeFormat = format.parse(timeNow);
                                        print("${ctFormat.difference(nowTimeFormat)}");
                                        int lateTimeInt = ctFormat.difference(nowTimeFormat).inMinutes;
                                        String beforeFlag;
                                        if(userSchedule.scheduleEndTime == null){
                                          beforeFlag = '1';
                                        }
                                        else{
                                          var ctFormatOut = format.parse(userSchedule.scheduleEndTime);
                                          var nowTimeFormatOut = format.parse(timeNow);
                                          print("${ctFormat.difference(nowTimeFormat)}");
                                          int timeIntOut = ctFormatOut.difference(nowTimeFormatOut).inMinutes;
                                          if(lateTimeInt>0 || timeIntOut<0){
                                            beforeFlag = '1';
                                          }
                                          else{
                                            beforeFlag = '0';
                                          }
                                        }
                                        if(lateTimeInt>=5){
                                          Widget cancelButton = FlatButton(
                                            child: Text("Cancel"),
                                            onPressed:  () {
                                              Navigator.pop(context);
                                            },
                                          );
                                          Widget continueButton = FlatButton(
                                            child: Text("Continue"),
                                            onPressed:  () {
                                              Navigator.pop(context);
                                              saveClockInTime(
                                                  userSchedule.rosterId.toString(),
                                                  userSchedule.rosterGroupId
                                                      .toString(),beforeFlag,sharedValue[1],sharedValue[2]);
                                            },
                                          );

                                          // set up the AlertDialog
                                          AlertDialog alert = AlertDialog(
                                            title: Text("Alert"),
                                            content: Text("Would you like to clock in before the time?"),
                                            actions: [
                                              cancelButton,
                                              continueButton,
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
                                        else{
                                          saveClockInTime(
                                              userSchedule.rosterId.toString(),
                                              userSchedule.rosterGroupId
                                                  .toString(),beforeFlag,sharedValue[1],sharedValue[2]);
                                        }
                                      }
                                      else {
                                        Navigator.pop(context);
                                        CommonMethods.showToast('Please check-in to your shift when you are at the Work Location');
                                      }
                                    }
                                  });
                                });
                              }
                            });
                          });
                        });
                      }
                      else{
                        checkLocationFirstTime2 = true;
                        DateTime now = DateTime.now();
                        String timeNow = DateFormat('HH:mm').format(now);
                        var format = DateFormat("HH:mm");
                        int lateTimeInt;
                        if(userSchedule.scheduleEndTime != null){
                          var ctFormat = format.parse(userSchedule.scheduleEndTime);
                          var nowTimeFormat = format.parse(timeNow);
                          lateTimeInt = ctFormat.difference(nowTimeFormat).inMinutes;
                        }
                        else{
                          lateTimeInt = -1;
                        }
                        getPreferenceData().then((sharedValue){
                          getLocationData(sharedValue[0],sharedValue[1],sharedValue[2],sharedValue[3]).then((value){
                            location.requestPermission().then((permissionStatus){
                              if(permissionStatus == PermissionStatus.granted){
                                location.onLocationChanged.listen((locationData) {
                                  double mLatitude = locationData.latitude!;
                                  double mLongitude = locationData.longitude!;
                                  getDistanceBtwnTwoPoints(double.parse(value[0]), double.parse(value[1]),
                                      mLatitude,
                                      mLongitude).then((value) {
                                    print('value'+value.toString());
                                    if(checkLocationFirstTime2){
                                      checkLocationFirstTime2 = false;
                                      if (value <= 50.0) {
                                        DateTime now = DateTime.now();
                                        String lastClockInDate = mPref.getString('clockin_date').toString();
                                        String currentDate = DateFormat('yyyy-MM-dd').format(now);
                                        if(lastClockInDate == currentDate) {
                                          saveClockOutTime(CommonMethods
                                              .getCurrentTime(), '0',
                                              userSchedule.rosterId
                                                  .toString());
                                        }
                                        else{
                                          _selectTime(context);
                                        }
                                      }
                                      else {
                                        _selectTime(context);
                                      }
                                    }
                                  });
                                });
                              }
                            });
                          });
                        });
                      }
                    },
                    color: (clockStatus == 0)?Colors.green:Colors.redAccent,
                    child: (clockStatus == 0)?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Clock In",
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ):Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Clock Out",
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
              ):Text(''),
              (pageNumber == getNumberOfDayOfWeek())?FutureBuilder(
                future: lastClockInTime(),
                builder: (context, snapshot){
                  if(snapshot.data == null){
                    return Text('');
                  }
                  else{
                    return snapshot.data==''?Text(''):Text(
                      'Your last clocked in: '+CommonMethods.convertDateTimeDisplay2(snapshot.data.toString()),
                      style: TextStyle(
                          color: app_theme_dark_color
                      ),
                    );
                  }
                },
              ):Text('')
            ],
          ),
        ],
      ),
    );
  }

  Future<String> lastClockInTime()async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String timeStr = mPref.getString('clockin_date').toString();
    if(timeStr == 'null'){
      timeStr = '';
    }
    return timeStr;
  }

  Widget thisWeekData(){
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
            future: getCurrentWeekSchedular(anyDayOfWeek(0),anyDayOfWeek(6),mList[0],mList[1],mList[2]),
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
                    initialPage: getNumberOfDayOfWeek(),
                    children: <Widget>[
                      mCustomPage(anyDayOfWeek(0),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 1)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 1)))),0,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(1),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 2)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 2)))),1,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(2),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 3)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 3)))),2,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(3),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 4)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 4)))),3,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(4),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 5)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 5)))),4,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(5),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 6)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 6)))),5,userSchedule[0]
                      ),
                      mCustomPage(anyDayOfWeek(6),
                          getStartTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 7)))),
                          getEndTime(userSchedule, getDate(date.subtract(Duration(days: date.weekday - 7)))),6,userSchedule[0]
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

  goToProfilePage(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
  }

  logoutFromApi() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String userId = mPref.getString('user_id').toString();
    String rememberToken = mPref.getString('user_token').toString();
    CommonMethods.showAlertDialog(context);
    var logoutBody = {
      'user_id':userId,
      'remember_token':rememberToken
    };
    Uri mUri = Uri.parse(ApiInterface.SIGNOUT);
    // final ioc = new HttpClient();
    // ioc.badCertificateCallback =
    //     (X509Certificate cert, String host, int port) => true;
    // final http = new IOClient(ioc);
    final response = await http.post(mUri, body: logoutBody);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      print(response.body);
      Map<String, dynamic> d = json.decode(response.body.trim());
      var status = d['status'];
      if(status == 'success'){
        mPref.setBool("login_status", false);
        mPref.setString("user_location", '');
        mPref.setString("user_entity", '');
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            ModalRoute.withName("/payment"));
      }
    }
  }

  showLogoutDialog() {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed: () async {
        logoutFromApi();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Would you like to logout from the Application"),
      actions: [
        cancelButton,
        continueButton,
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

  Widget popupMenuButton(){

    return PopupMenuButton<String>(
      elevation: 50,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      icon: Icon(Icons.menu, size: 30, color: app_theme_dark_color),
      onSelected: (newValue) { // add this property
        if(mounted){
          setState(() {
            switch(newValue){
              case 'Profile':
                goToProfilePage();
                break;
              case 'Settings':
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ShowRestaurant()));
                break;
              case 'Logout':
                showLogoutDialog();
                break;
            }
          });
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

        PopupMenuItem<String>(
          value: "Profile",
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: const Color(0xFF401461),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Profile"),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "Settings",
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: const Color(0xFF401461),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Settings"),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "Logout",
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: const Color(0xFF401461),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Logout"),
              ),
            ],
          ),
        ),

      ],

    );}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffE9ECEF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Text(
              titleStr,
              style: TextStyle(
                  color: app_theme_dark_color
              ),
            ),
            Text('')
          ],
        ),
        actions: <Widget>[
          popupMenuButton()
        ],
      ),
      body: bodyWidget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (int index) {
          if(mounted){
            switch(index){
              case 0:
                if(this.index != 0) {
                  this.index = index;
                  setState(() {
                    isCurrentWeek = true;
                    bodyWidget = mBodyWidget();
                    titleStr = 'My Roster';
                  });
                }
                break;
              case 1:
              // if(index != 1) {
                this.index = index;
                setState(() {
                  isCurrentWeek = true;
                  bodyWidget = NotificationPage();
                  titleStr = 'Notification';
                });
                // }
                break;
            }
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: new Icon(Icons.schedule),
            label: "My Roster",
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.notification_important),
            label: "Notification",
          ),
        ],
      ),
    );
  }
}