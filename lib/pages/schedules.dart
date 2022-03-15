// import 'dart:convert';
// import 'package:clean_swiper/clean_swiper.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:roster_app/common/api_interface.dart';
// import 'package:roster_app/common/common_methods.dart';
// import 'package:roster_app/models/scheduler_model.dart';
// import 'package:roster_app/pages/login.dart';
// import 'package:rosr_app/pages/notification_page.dart';
// import 'package:roster_app/pages/profile_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'next_week_page.dart';
//
// class Dashboard extends StatefulWidget{
//   DashboardState createState() => DashboardState();
// }
//
// class DashboardState extends State<Dashboard>{
//   Position _currentPosition;
//   String _currentAddress;
//   final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//   bool isCurrentWeek = true;
//   Widget bodyWidget;
//   String mToken;
//   bool changeClockInState = false;
//   String fNameStr = '';
//   String lNameStr = '';
//   String emailStr = '';
//   String mobileStr = '';
//   String titleStr;
//   String userToken;
//   String userId;
//   int index = 0;
//   int _selectedIndex = 0;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   double distanceInMeters;
//   String serverLat;
//   String serverLongi;
//   String attendanceId = '0';
//
//   getPrefData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       fNameStr = (prefs.getString('f_name_pref') ?? '');
//       lNameStr = (prefs.getString('l_name_pref') ?? '');
//       emailStr = (prefs.getString('email_pref') ?? '');
//       mobileStr = (prefs.getString('mobile_pref') ?? '');
//       userId = (prefs.getString('user_id') ?? '');
//       serverLat = (prefs.getString('server_latitude') ?? '');
//       serverLongi = (prefs.getString('server_longitude') ?? '');
//       mToken = (prefs.getString('user_token') ?? '');
//     });
//   }
//
//   Future getLoginToken()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String userToken = prefs.getString('user_token');
//     return userToken;
//   }
//
//   _getCurrentLocation() {
//     geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//         .then((Position position) {
//       setState(() {
//         _currentPosition = position;
//       });
//       _getAddressFromLatLng();
//     }).catchError((e) {
//       print(e);
//     });
//   }
//
//   _getAddressFromLatLng() async {
//     try {
//       List<Placemark> p = await geolocator.placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
//       Placemark place = p[0];
//       setState(() {
//         _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
//         print(_currentPosition.latitude);
//         print(_currentPosition.longitude);
//       });
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   String anyDayOfWeek(int daysNum){
//     DateTime today = DateTime.now();
//     var _firstDayOfTheweek = today.subtract(new Duration(days: today.weekday-1-daysNum));
//     var formatter = new DateFormat('yyyy-MM-dd');
//     String formattedDate2 = formatter.format(_firstDayOfTheweek);
//     return formattedDate2;
//   }
//
//   Future<String> getToken() async{
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String token = preferences.getString('user_token');
//     return token;
//   }
//
//   List<String> listOf7Days(){
//     List<String> dayList = [];
//     DateTime today = DateTime.now();
//     for(int i=0;i<7;i++) {
//       var _firstDayOfTheweek = today.subtract(
//           new Duration(days: today.weekday - 1-i));
//       var formatter = new DateFormat('yyyy-MM-dd');
//       String formattedDate2 = formatter.format(_firstDayOfTheweek);
//       dayList.add(formattedDate2);
//     }
//     return dayList;
//   }
//
//   goToProfilePage(){
//     Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
//   }
//
//   saveClockInTime(String rosterId,String userGrpId){
//     CommonMethods.showAlertDialog(context);
//     setState(()async {
//       var mBody = {
//         "user_id":userId,
//         "roster_id":rosterId,
//         "user_group_id":userGrpId,
//         "attendance_date":CommonMethods.getCurrentDate(0),
//         "check_in_time": CommonMethods.getCurrentTime(),
//         "location":'0'
//       };
//       final response = await http.post(ApiInterface.CLOCK_IN, body: mBody);
//       print(response.body);
//       if (response.statusCode == 200) {
//         Navigator.pop(context);
//         final String loginResponse = response.body;
//         print(response.body);
//         Map<String, dynamic> d = json.decode(loginResponse.trim());
//         var status = d["success"];
//         attendanceId = d['attendanceId'].toString();
//         if (status == 'success') {
//           CommonMethods.showToast('Successfully clocked in');
//           setState(() {
//             changeClockInState = true;
//           });
//           (context as Element).reassemble();
//         } else {
//           CommonMethods.showToast('Something went wrong');
//         }
//         print(loginResponse);
//       }
//     });
//   }
//
//   saveClockOutTime()async{
//     CommonMethods.showAlertDialog(context);
//     var mBody = {
//       "attendance_id": attendanceId,
//       "clock_out_time": CommonMethods.getCurrentTime(),
//       "remember_token": mToken,
//       "location": '0',
//     };
//     final response = await http.post(ApiInterface.CLOCK_OUT, body: mBody);
//     print(response.body);
//     if (response.statusCode == 200) {
//       Navigator.pop(context);
//       final String loginResponse = response.body;
//       print(response.body);
//       Map<String, dynamic> d = json.decode(loginResponse.trim());
//       var status = d["success"];
//       if (status == 'success') {
//         CommonMethods.showToast('Successfully clocked out');
//         setState(() {
//           changeClockInState = false;
//         });
//         (context as Element).reassemble();
//       } else {
//         CommonMethods.showToast('Something went wrong');
//       }
//       print(loginResponse);
//     }
//   }
//
//   Future<dynamic>getCurrentWeekSchedular(String startDate, String endDate,String token)async{
//     var mBody = {
//       "remember_token": token,
//       "start_date": startDate,
//       "last_date": endDate
//     };
//     final response = await http.post(ApiInterface.SCHEDULER, body: mBody);
//     print(response.body);
//     if (response.statusCode == 200) {
//       final String loginResponse = response.body;
//       print(response.body);
//       Map<String, dynamic> d = json.decode(loginResponse.trim());
//       var status = d["success"];
//       if (status != 'success') {
//         CommonMethods.showToast('No Scheduler found');
//       } else {
//         SchedulerModel schedulerModel = schedulerModelFromJson(response.body);
//         List<Datum> userSchedule = schedulerModel.data;
//         if(userSchedule.length == 0){
//           return 'data_not_found';
//         }
//         else {
//           List<Datum> testSchedule = [];
//           List<String> myDates = listOf7Days();
//           String mtFirstDate = myDates[0].substring(myDates[0].length - 2);
//           int mtFirstDateInt = int.parse(mtFirstDate);
//           int shouldLen = listOf7Days().length;
//           for (int i = 0; i < shouldLen; i++) {
//             if(i==userSchedule.length){
//               testSchedule.add(new Datum(
//                   scheduleDate: DateTime.parse(listOf7Days()[0]).toString(),
//                   scheduleStartTime: 'not found',
//                   scheduleEndTime: 'not found'));
//               i--;
//               shouldLen--;
//             }
//             else {
//               int serverDate = int.parse(
//                   userSchedule[i].scheduleDate.split('-')[0]);
//               if (mtFirstDateInt == 31) {
//                 mtFirstDateInt = 1;
//               }
//               if (mtFirstDateInt != serverDate) {
//                 testSchedule.add(new Datum(
//                     scheduleDate: DateTime.parse(listOf7Days()[0]).toString(),
//                     scheduleStartTime: 'not found',
//                     scheduleEndTime: 'not found'));
//                 i--;
//                 shouldLen--;
//               }
//               else {
//                 testSchedule.add(userSchedule[i]);
//               }
//               mtFirstDateInt++;
//             }
//           }
//           if (userSchedule.length == 0) {
//             return 'data_not_found';
//           }
//           else {
//             return testSchedule;
//           }
//         }
//       }
//       print(loginResponse);
//     }
//   }
//
//   Widget popupMenuButton(){
//
//     return PopupMenuButton<String>(
//       elevation: 50,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       icon: Icon(Icons.menu, size: 30, color: app_theme_dark_color),
//       onSelected: (newValue) { // add this property
//         setState(() {
//           switch(newValue){
//             case 'Profile':
//               goToProfilePage();
//               break;
//             case 'Logout':
//               showLogoutDialog();
//               break;
//           }
//         });
//       },
//       itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//
//         PopupMenuItem<String>(
//           value: "Profile",
//           child: Row(
//             children: [
//               Icon(
//                 Icons.person_rounded,
//                 color: const Color(0xFF401461),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Text("Profile"),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: "Settings",
//           child: Row(
//             children: [
//               Icon(
//                 Icons.settings,
//                 color: const Color(0xFF401461),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Text("Settings"),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: "Logout",
//           child: Row(
//             children: [
//               Icon(
//                 Icons.logout,
//                 color: const Color(0xFF401461),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Text("Logout"),
//               ),
//             ],
//           ),
//         ),
//
//       ],
//
//     );}
//
//   showLogoutDialog() {
//     // set up the buttons
//     Widget cancelButton = FlatButton(
//       child: Text("Cancel"),
//       onPressed: () {
//         Navigator.pop(context);
//       },
//     );
//     Widget continueButton = FlatButton(
//       child: Text("Yes"),
//       onPressed: () async {
//         SharedPreferences mPref = await SharedPreferences.getInstance();
//         mPref.setBool("login_status", false);
//         Navigator.pop(context);
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => Login()),
//             ModalRoute.withName("/payment"));
//       },
//     );
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("Logout"),
//       content: Text("Would you like to logout from the Application"),
//       actions: [
//         cancelButton,
//         continueButton,
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   int getNumberOfDayOfWeek(){
//     DateTime date = DateTime.now();
//     // print("weekday is ${date.weekday}");
//     return date.weekday-1;
//   }
//
//   String getFirstDateOfWeek(int daysNum){
//     DateTime today = DateTime.now();
//     var _firstDayOfTheweek = today.subtract(new Duration(days: today.weekday-1-daysNum));
//     var formatter = new DateFormat('dd MMM');
//     String formattedDate2 = formatter.format(_firstDayOfTheweek);
//     String day = DateFormat('EEEE').format(_firstDayOfTheweek);
//     return formattedDate2+' ('+day+')';
//   }
//
//
//   Future getDistanceBtwnTwoPoints(double startLatitude,double startLongitude,double endLatitude,double endLongitude) async{
//     if(startLatitude == null){
//       startLatitude = 0.0;
//     }
//     else if(startLongitude == null){
//       startLongitude = 0.0;
//     }
//     else if(endLatitude == null){
//       endLatitude = 0.0;
//     }
//     else if(endLongitude == null){
//       endLongitude = 0.0;
//     }
//     distanceInMeters = await Geolocator().distanceBetween(startLatitude,startLongitude,endLatitude,endLongitude);
//     return distanceInMeters;
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print(CommonMethods.getCurrentTime());
//     bodyWidget = mBodyWidget();
//     _getCurrentLocation();
//     getPrefData();
//     getLoginToken().then((value){
//       setState(() {
//         userToken = value;
//       });
//     });
//     titleStr = 'My Scheduler';
//     // getDistanceBtwnTwoPoints().then((value){
//     //
//     // })
//   }
//
//   Widget customPage(int pageNumber, Datum userSchedule){
//     return Padding(
//       padding: const EdgeInsets.only(top: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             children: [
//               Text(
//                 getFirstDateOfWeek(pageNumber),
//                 style: TextStyle(
//                     fontSize: 30.0,
//                     fontFamily: '.SF UI Display',
//                     fontWeight: FontWeight.w800
//                 ),
//               ),
//               userSchedule.scheduleStartTime == 'not found'?Padding(
//                 padding: const EdgeInsets.only(top: 200.0),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.speaker_notes_off_rounded,
//                       size: 50.0,
//                       color: app_theme_dark_color,
//                     ),
//                     Text(
//                         'No data found for this date'
//                     ),
//                   ],
//                 ),
//               ):Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 100.0),
//                     child: Text(
//                       'Start Time: '+userSchedule.scheduleStartTime,
//                       style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.w600
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20.0),
//                     child: Text(
//                       'End Time: '+userSchedule.scheduleEndTime,
//                       style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.w600
//                       ),
//                     ),
//                   ),
//
//                   (pageNumber==getNumberOfDayOfWeek())?Padding(
//                     padding: const EdgeInsets.only(top: 100.0),
//                     child: MaterialButton(
//                         onPressed: (){
//                           if(!changeClockInState) {
//                             getDistanceBtwnTwoPoints(double.parse(serverLat),
//                                 double.parse(serverLongi),
//                                 _currentPosition.latitude,
//                                 _currentPosition.longitude).then((value) {
//                               if(value<=50.0){
//                                 saveClockInTime(userSchedule.rosterId.toString(),userSchedule.rosterGroupId.toString());
//                               }
//                               else{
//                                 CommonMethods.showToast('You are not at the location');
//                               }
//                             });
//                           }
//                           else{
//                             saveClockOutTime();
//                           }
//                         },
//                         color: const Color(0xFF401461),
//                         child: !changeClockInState?Text(
//                           "Clock In",
//                           style: TextStyle(
//                               color: Colors.white
//                           ),
//                         ):Text(
//                           "Clock Out",
//                           style: TextStyle(
//                               color: Colors.white
//                           ),
//                         ),
//
//                         shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
//                   ):
//                   Text(''),
//                 ],
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget getSchedulerView(bool isCurrentWeek,List<Datum> userSchedule){
//     List<Widget> viewList = [];
//     for(int i=0;i<userSchedule.length;i++){
//       viewList.add(customPage(i,userSchedule[i]));
//     }
//     return CleanSwiper(children: viewList,
//       initialPage: getNumberOfDayOfWeek(),
//       viewportFraction: 0.9,);
//   }
//
//   Widget mBodyWidget(){
//     return FutureBuilder(
//       future: getToken(),
//       builder: (context,snapshot1){
//         if(snapshot1.data == null){
//           return Text('');
//         }
//         else{
//           return FutureBuilder(
//             future: getCurrentWeekSchedular(anyDayOfWeek(0),anyDayOfWeek(6),snapshot1.data),
//             builder: (context, snapshot){
//               if(snapshot.data == null){
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       CircularProgressIndicator(),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Loading...',
//                           style: TextStyle(
//                             fontSize: 18.0,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 );
//               }
//               else if(snapshot.data == 'data_not_found'){
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.no_cell,
//                         size: 50.0,
//                         color: app_theme_dark_color,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: Text(
//                           'You are not scheduled on the Roster this week',
//                           style: TextStyle(
//                             color: app_theme_dark_color,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               else{
//                 return getSchedulerView(true,snapshot.data);
//               }
//             },
//           );
//         }
//       },
//     );
//
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color(0xffE9ECEF),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Image.asset(
//                 'assets/images/app_icon.png',
//                 fit: BoxFit.contain,
//                 height: 32,
//               ),
//               Text(
//                 titleStr,
//                 style: TextStyle(
//                     color: app_theme_dark_color
//                 ),
//               ),
//               Text('')
//             ],
//           ),
//           actions: <Widget>[
//             popupMenuButton()
//           ],
//         ),
//         body: DefaultTabController(
//             length: 2,
//             child: Scaffold(
//               appBar: PreferredSize(
//                 preferredSize: Size.fromHeight(40.0),
//                 child: AppBar(
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   bottom: TabBar(
//                       unselectedLabelColor: app_theme_dark_color,
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       indicator: BoxDecoration(
//                           gradient: LinearGradient(
//                               colors: [app_theme_dark_color, app_theme_dark_color]),
//                           borderRadius: BorderRadius.circular(50),
//                           color: Colors.redAccent),
//                       tabs: [
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.5,
//                           height: 30.0,
//                           child: Center(
//                             child: Text(
//                                 'My Roster'
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.5,
//                           child: Center(
//                             child: Text(
//                                 'Next Week'
//                             ),
//                           ),
//                         ),
//                       ],
//                       isScrollable: true),
//                 ),
//               ),
//               body: Padding(
//                 padding: EdgeInsets.only(top: 10.0),
//                 child: TabBarView(
//                     children: [
//                       bodyWidget,
//                       NextWeekPage(),
//                     ]
//                 ),
//               ),
//             )),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: index,
//           onTap: (int index) {
//             setState((){
//               this.index = index;
//               switch(index){
//                 case 0:
//                   isCurrentWeek = true;
//                   bodyWidget = mBodyWidget();
//                   titleStr = 'My Roster';
//                   break;
//                 case 1:
//                   isCurrentWeek = true;
//                   bodyWidget = NotificationPage();
//                   titleStr = 'Notification';
//                   break;
//               }
//             });
//           },
//           items: <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: new Icon(Icons.schedule),
//               title: new Text("My Roster"),
//             ),
//             // BottomNavigationBarItem(
//             //   icon: new Icon(Icons.schedule_send),
//             //   title: new Text("Next week"),
//             // ),
//             BottomNavigationBarItem(
//               icon: new Icon(Icons.notification_important),
//               title: new Text("Notification"),
//             ),
//           ],
//         ),
//         // body: TabBar(
//         //   tabs: [
//         //     Tab(icon: Icon(Icons.directions_car)),
//         //     Tab(icon: Icon(Icons.directions_transit)),
//         //     Tab(icon: Icon(Icons.directions_bike)),
//         //   ],
//         // ),
//         // body: bodyWidget,
//
//       ),
//     );
//   }
//
// }