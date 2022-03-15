// To parse this JSON data, do
//
//     final productsModel = productsModelFromJson(jsonString);

import 'dart:convert';

ProductsModel productsModelFromJson(String str) => ProductsModel.fromJson(json.decode(str));

String productsModelToJson(ProductsModel data) => json.encode(data.toJson());

class ProductsModel {
  ProductsModel({
    required this.result,
    required this.data,
  });

  String result;
  List<Map<String, String>> data;

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    result: json["result"],
    data: List<Map<String, String>>.from(json["data"].map((x) => Map.from(x).map((k, v) => MapEntry<String, String>(k, v == null ? null : v)))),
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "data": List<dynamic>.from(data.map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v == null ? null : v)))),
  };
}
