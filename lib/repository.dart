import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lab_gui_flutter/models/base_model.dart';
import 'package:lab_gui_flutter/models/collection_item.dart';
import 'package:lab_gui_flutter/models/jwt.dart';

import 'models/collector.dart';

const URL = "localhost:3000";

Future<Jwt> login(String login, String password) async {
  var url = Uri.http(URL, 'rpc/login');

  final response =
      await http.post(url, body: {'login': login, 'pass': password});
  print(response.body);

  if (response.statusCode == 200) {
    return Jwt.fromJson(response.body);
  } else {
    throw Exception("Bad login or password");
  }
}

Future<bool> testRequest(String jwt) async {
  var url = Uri.http(URL, "rpc/test");
  final response = await http.post(url);
  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception("Bad login or password");
  }
}

Future<List<CollectionItem>> getCollection() async {
  var url = Uri.http(URL, 'basic_view');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<CollectionItem> collection = List<CollectionItem>.from(
        l.map((model) => CollectionItem.fromJson(model)));
    return collection;
  } else {
    throw Exception("Network not found.");
  }
}

Future<List<BaseModel>> getOrders() async {
  var url = Uri.http(URL, 'order');
  print(url.toString());
  final response = await http.get(url);
  print(response.statusCode);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    try {
      List<BaseModel> orders = List<BaseModel>.from(
          l.map((model) => BaseModel.fromJson(model, BaseModelsTypes.order)));
      return orders;
    } catch (e) {
      print(e.toString());
    }
    return [];
  } else {
    throw Exception("Network not found.");
  }
}

Future<List<BaseModel>> getFamiliesById(BaseModel order) async {
  var url = Uri.http(URL, 'family', {"order_id": "eq.${order.id}"});

  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<BaseModel> orders = List<BaseModel>.from(l.map((model) =>
        BaseModel.fromJson(model, BaseModelsTypes.family, parent: order)));
    return orders;
  } else {
    throw Exception("Network not found.");
  }
}

Future<List<BaseModel>> getGenusesById(BaseModel family) async {
  var url = Uri.http(URL, 'genus', {"family_id": "eq.${family.id}"});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<BaseModel> orders = List<BaseModel>.from(l.map((model) =>
        BaseModel.fromJson(model, BaseModelsTypes.genus, parent: family)));
    return orders;
  } else {
    throw Exception("Network not found.");
  }
}

Future<List<BaseModel>> getKindsById(BaseModel genus) async {
  var url = Uri.http(URL, 'kind', {"genus_id": "eq.${genus.id}"});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<BaseModel> orders = List<BaseModel>.from(l.map((model) =>
        BaseModel.fromJson(model, BaseModelsTypes.kind, parent: genus)));
    return orders;
  } else {
    throw Exception("Network not found.");
  }
}


Future<List<Collector>> getCollectors() async{
  var url = Uri.http(URL, 'collector');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<Collector> orders = List<Collector>.from(l.map((collector) =>
        Collector.fromJson(collector)));
    return orders;
  } else {
    throw Exception("Network not found.");
  }
}