// To parse this JSON data, do
//
//     final schedulerModel = schedulerModelFromJson(jsonString);

import 'dart:convert';

SchedulerModel schedulerModelFromJson(String str) => SchedulerModel.fromJson(json.decode(str));

String schedulerModelToJson(SchedulerModel data) => json.encode(data.toJson());

class SchedulerModel {
  SchedulerModel({
    this.success,
    this.data,
  });

  String? success;
  List<Datum>? data;

  factory SchedulerModel.fromJson(Map<String, dynamic> json) => SchedulerModel(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.scheduleId,
    this.rosterId,
    this.userId,
    this.scheduleDate,
    this.scheduleStartTime,
    required this.scheduleEndTime,
    this.scheduleNote,
    this.latitude,
    this.longitude,
    this.createdOn,
    this.updatedOn,
    this.createdBy,
    this.updatedBy,
    this.rosterGroupId,
    this.rosterDate,
    this.rosterEndDate,
    this.rosterStatus,
  });

  int? scheduleId;
  int? rosterId;
  int? userId;
  String? scheduleDate;
  String? scheduleStartTime;
  late String scheduleEndTime;
  String? scheduleNote;
  dynamic latitude;
  dynamic longitude;
  DateTime? createdOn;
  dynamic updatedOn;
  int? createdBy;
  int? updatedBy;
  int? rosterGroupId;
  DateTime? rosterDate;
  DateTime? rosterEndDate;
  String? rosterStatus;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    scheduleId: json["ScheduleID"],
    rosterId: json["RosterID"],
    userId: json["UserID"],
    scheduleDate: json["ScheduleDate"],
    scheduleStartTime: json["ScheduleStartTime"],
    scheduleEndTime: json["ScheduleEndTime"],
    scheduleNote: json["ScheduleNote"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    updatedOn: json["UpdatedOn"],
    createdBy: json["CreatedBy"],
    updatedBy: json["UpdatedBy"],
    rosterGroupId: json["RosterGroupID"],
    rosterDate: DateTime.parse(json["RosterDate"]),
    rosterEndDate: DateTime.parse(json["RosterEndDate"]),
    rosterStatus: json["RosterStatus"],
  );

  Map<String, dynamic> toJson() => {
    "ScheduleID": scheduleId,
    "RosterID": rosterId,
    "UserID": userId,
    "ScheduleDate": scheduleDate,
    "ScheduleStartTime": scheduleStartTime,
    "ScheduleEndTime": scheduleEndTime,
    "ScheduleNote": scheduleNote,
    "latitude": latitude,
    "longitude": longitude,
    "CreatedOn": createdOn!.toIso8601String(),
    "UpdatedOn": updatedOn,
    "CreatedBy": createdBy,
    "UpdatedBy": updatedBy,
    "RosterGroupID": rosterGroupId,
    "RosterDate": "${rosterDate!.year.toString().padLeft(4, '0')}-${rosterDate!.month.toString().padLeft(2, '0')}-${rosterDate!.day.toString().padLeft(2, '0')}",
    "RosterEndDate": "${rosterEndDate!.year.toString().padLeft(4, '0')}-${rosterEndDate!.month.toString().padLeft(2, '0')}-${rosterEndDate!.day.toString().padLeft(2, '0')}",
    "RosterStatus": rosterStatus,
  };
}
