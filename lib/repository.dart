import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lab_gui_flutter/models/collection_item.dart';
import 'package:lab_gui_flutter/models/jwt.dart';

const URL = "localhost:3000";

Future<Jwt> login(String login, String password) async {
  var url = Uri.http(URL, 'rpc/login');

  final response =
      await http.post(url, body: {'email': login, 'pass': password});
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
  print(url.toString());
  final response = await http.get(url);
  print(response.statusCode);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<CollectionItem> collection = List<CollectionItem>.from(
        l.map((model) => CollectionItem.fromJson(model)));
    return collection;
  } else {
    throw Exception("Network not found.");
  }
}
