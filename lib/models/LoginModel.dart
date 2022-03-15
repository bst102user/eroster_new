// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel({
    required this.success,
    required this.userDetails,
    required this.data,
  });

  String success;
  UserDetails userDetails;
  String data;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    userDetails: UserDetails.fromJson(json["userDetails"]),
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "userDetails": userDetails.toJson(),
    "data": data,
  };
}

class UserDetails {
  UserDetails({
    required this.userId,
    required this.userTypeId,
    required this.userFirstName,
    required this.userLastName,
    required this.userAddress,
    required this.userLoginEmail,
    required this.userPhoneNo,
    required this.userStatus,
    required this.createdOn,
    required this.updatedOn,
    required this.createdBy,
    required this.updatedBy,
    required this.userLoginEmailVerifiedAt,
    required this.userToken,
  });

  int userId;
  int userTypeId;
  String userFirstName;
  String userLastName;
  String userAddress;
  String userLoginEmail;
  String userPhoneNo;
  String userStatus;
  DateTime createdOn;
  dynamic updatedOn;
  int createdBy;
  int updatedBy;
  dynamic userLoginEmailVerifiedAt;
  String userToken;

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
    userId: json["UserID"],
    userTypeId: json["UserTypeID"],
    userFirstName: json["UserFirstName"],
    userLastName: json["UserLastName"],
    userAddress: json["UserAddress"],
    userLoginEmail: json["UserLoginEmail"],
    userPhoneNo: json["UserPhoneNo"],
    userStatus: json["UserStatus"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    updatedOn: json["UpdatedOn"],
    createdBy: json["CreatedBy"],
    updatedBy: json["UpdatedBy"],
    userLoginEmailVerifiedAt: json["UserLoginEmailVerifiedAt"],
    userToken: json["userToken"],
  );

  Map<String, dynamic> toJson() => {
    "UserID": userId,
    "UserTypeID": userTypeId,
    "UserFirstName": userFirstName,
    "UserLastName": userLastName,
    "UserAddress": userAddress,
    "UserLoginEmail": userLoginEmail,
    "UserPhoneNo": userPhoneNo,
    "UserStatus": userStatus,
    "CreatedOn": createdOn.toIso8601String(),
    "UpdatedOn": updatedOn,
    "CreatedBy": createdBy,
    "UpdatedBy": updatedBy,
    "UserLoginEmailVerifiedAt": userLoginEmailVerifiedAt,
    "userToken": userToken,
  };
}
