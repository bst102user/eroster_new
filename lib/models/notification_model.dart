// To parse required this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  NotificationModel({
    required this.success,
  });

  List<Success> success;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    success: List<Success>.from(json["success"].map((x) => Success.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x.toJson())),
  };
}

class Success {
  Success({
    required this.title,
    required this.massege,
    required this.createdAt,
  });

  String title;
  String massege;
  DateTime createdAt;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    title: json["title"],
    massege: json["massege"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "massege": massege,
    "created_at": createdAt.toIso8601String(),
  };
}
