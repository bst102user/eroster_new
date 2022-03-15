// To parse this JSON data, do
//
//     final restaurantModel = restaurantModelFromJson(jsonString);

import 'dart:convert';

RestaurantModel restaurantModelFromJson(String str) => RestaurantModel.fromJson(json.decode(str));

String restaurantModelToJson(RestaurantModel data) => json.encode(data.toJson());

class RestaurantModel {
  RestaurantModel({
    required this.status,
    required this.entity,
  });

  String status;
  List<Entity> entity;

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
    status: json["status"],
    entity: List<Entity>.from(json["entity"].map((x) => Entity.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "entity": List<dynamic>.from(entity.map((x) => x.toJson())),
  };
}

class Entity {
  Entity({
    required this.userMappingId,
    required this.userId,
    required this.entityId,
    required this.locationId,
    required this.userTypeId,
    required this.groupId,
    required this.createdOn,
    required this.updatedOn,
    required this.createdBy,
    required this.updatedBy,
    required this.getEntity,
  });

  int userMappingId;
  int userId;
  int entityId;
  int locationId;
  int userTypeId;
  int groupId;
  DateTime createdOn;
  dynamic updatedOn;
  int createdBy;
  int updatedBy;
  List<GetEntity> getEntity;

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
    userMappingId: json["UserMappingID"],
    userId: json["UserID"],
    entityId: json["EntityID"],
    locationId: json["LocationID"],
    userTypeId: json["UserTypeID"],
    groupId: json["GroupID"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    updatedOn: json["UpdatedOn"],
    createdBy: json["CreatedBy"],
    updatedBy: json["UpdatedBy"],
    getEntity: List<GetEntity>.from(json["get_entity"].map((x) => GetEntity.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "UserMappingID": userMappingId,
    "UserID": userId,
    "EntityID": entityId,
    "LocationID": locationId,
    "UserTypeID": userTypeId,
    "GroupID": groupId,
    "CreatedOn": createdOn.toIso8601String(),
    "UpdatedOn": updatedOn,
    "CreatedBy": createdBy,
    "UpdatedBy": updatedBy,
    "get_entity": List<dynamic>.from(getEntity.map((x) => x.toJson())),
  };
}

class GetEntity {
  GetEntity({
    required this.entityId,
    required this.entityName,
    required this.entityAbn,
    required this.entityAddress,
    required this.entityContact,
    required this.entityContactEmail,
    required this.entityContactPhone,
    required this.entityLocations,
    required this.entityLogo,
    required this.createdOn,
    required this.updatedOn,
    required this.createdBy,
    required this.updatedBy,
  });

  int entityId;
  String entityName;
  String entityAbn;
  String entityAddress;
  String entityContact;
  String entityContactEmail;
  String entityContactPhone;
  int entityLocations;
  String entityLogo;
  DateTime createdOn;
  dynamic updatedOn;
  int createdBy;
  int updatedBy;

  factory GetEntity.fromJson(Map<String, dynamic> json) => GetEntity(
    entityId: json["EntityID"],
    entityName: json["EntityName"],
    entityAbn: json["EntityABN"],
    entityAddress: json["EntityAddress"],
    entityContact: json["EntityContact"],
    entityContactEmail: json["EntityContactEmail"],
    entityContactPhone: json["EntityContactPhone"],
    entityLocations: json["EntityLocations"],
    entityLogo: json["EntityLogo"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    updatedOn: json["UpdatedOn"],
    createdBy: json["CreatedBy"],
    updatedBy: json["UpdatedBy"],
  );

  Map<String, dynamic> toJson() => {
    "EntityID": entityId,
    "EntityName": entityName,
    "EntityABN": entityAbn,
    "EntityAddress": entityAddress,
    "EntityContact": entityContact,
    "EntityContactEmail": entityContactEmail,
    "EntityContactPhone": entityContactPhone,
    "EntityLocations": entityLocations,
    "EntityLogo": entityLogo,
    "CreatedOn": createdOn.toIso8601String(),
    "UpdatedOn": updatedOn,
    "CreatedBy": createdBy,
    "UpdatedBy": updatedBy,
  };
}
