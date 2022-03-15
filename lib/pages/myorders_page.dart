// import 'package:ecommerce_int2/apis/api_interface.dart';
// import 'package:ecommerce_int2/app_properties.dart';
// import 'package:ecommerce_int2/models/myorders_model.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';

import 'package:roster_app/common/api_interface.dart';

// import '../common_methods.dart';

class MyOrdersPage extends StatefulWidget {
  MyOrdersPageState createState() => MyOrdersPageState();
}

class MyOrdersPageState extends State<MyOrdersPage> {
  Future<dynamic> getAllOrders() async {
    var mBody = {
      "remember_token": '3kPVdSOe41fY7aldirqS9YTnhMUy8OAK8H2nuq0LAJuLdIzWbqNkpiukcuX0',
      // "start_date": '2020-10-11',
      "start_date": '2020-10-11',
      "last_date": '2020-10-11'
    };
    Uri mUri = Uri.parse(ApiInterface.SCHEDULER);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);
    final response = await http.post(mUri, body: mBody);
    print(response.body);
    if (response.statusCode == 200) {
      final String orderResponse = response.body;
      print(response.body);
      Map<String, dynamic> d = json.decode(orderResponse.trim());
      var status = d["result"];
      if (status == 'success') {
        // MyOrdersModel myOrdersModel = myOrdersModelFromJson(response.body);
        // List<Datum> dataList = myOrdersModel.data;
        return 'No data found';
      } else {
        return 'No data found';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color.fromRGBO(253, 192, 84, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'My Orders',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.0),
        ),
      ),
      body: FutureBuilder(
        future: getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
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
          } else {
            return Center(
              child: Text(
                'test data'
              ),
            );
          }
        },
      ),
    );
  }
  Widget _status(status) {
    if (status == 'pending') {
      return FlatButton.icon(
          label: Text(
            status,
            style: TextStyle(color: Colors.red),
          ),
          icon: const Icon(
            Icons.highlight_off,
            size: 18.0,
            color: Colors.red,
          ),
          onPressed: () {
            // Perform some action
          });
    } else {
      return FlatButton.icon(
          label: Text(
            status,
            style: TextStyle(color: Colors.green),
          ),
          icon: const Icon(
            Icons.check_circle,
            size: 18.0,
            color: Colors.green,
          ),
          onPressed: () {
            // Perform some action
          });
    }
    if (status == "3") {
      return Text('Process');
    } else if (status == "1") {
      return Text('Order');
    } else {
      return Text("Waiting");
    }
  }
}
