import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lab_gui_flutter/models/base_model.dart';
import 'package:lab_gui_flutter/models/collection_dto.dart';
import 'package:lab_gui_flutter/models/collection_item.dart';
import 'package:lab_gui_flutter/models/jwt.dart';
import 'package:lab_gui_flutter/my_app_state.dart';

import 'models/collector.dart';
import 'models/user.dart';
import 'models/voucher_institute.dart';

const URL = "localhost:3000";

Future<Jwt> login(String login, String password) async {
  var url = Uri.http(URL, 'rpc/login');

  final response =
      await http.post(url, body: {'login': login, 'pass': password});
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
  final response = await http.get(url);

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

Future<List<Collector>> getCollectors() async {
  var url = Uri.http(URL, 'collector');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<Collector> orders = List<Collector>.from(
        l.map((collector) => Collector.fromJson(collector)));
    return orders;
  } else {
    throw Exception("Network not found.");
  }
}

Future<int> getLastIdCollection() async {
  var url = Uri.http(
      URL, 'collection', {"select": "id", "limit": "1", "order": "id.desc"});
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    return l.first["id"] as int;
  } else {
    throw Exception("Network not found.");
  }
}

Future<User> getUserInfoByToken(String token) async {
  var url = Uri.http(URL, "rpc/get_user_info");
  final response =
      await http.get(url, headers: {"Authorization": "Bearer $token"});
  if (response.statusCode == 200) {
    return User.fromJson(response.body);
  } else {
    throw Exception("Token is expired");
  }
}

Future<List<VoucherInstitute>> getVoucherInstitute() async {
  var url = Uri.http(URL, 'voucher_institute');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<VoucherInstitute> vis = List<VoucherInstitute>.from(
        l.map((vi) => VoucherInstitute.fromJson(vi)));
    return vis;
  } else {
    throw Exception("Network not found.");
  }
}

Future<void> addCollection({
  required String age,
  required String sex,
  required String vauchInst,
  required String vauchId,
  required String dateCollect,
  required List<List<String>> collectors,
  required String token,
  String? country,
  String? region,
  String? subregion,
  String? geocomment,
  String? comment,
  String? point,
  bool rna = false,
  String? collectId,
  String? order,
  String? family,
  String? genus,
  String? kind,
}) async {
  final url = Uri.http(URL, "rpc/add_collection");

  final body = {
    'age': age,
    'sex': sex,
    'vauch_inst': vauchInst,
    'vauch_id': vauchId,
    'date_collect': dateCollect,
    'collectors':
        '{${collectors.map((collector) => '{"${collector[0]}", "${collector[1]}", "${collector[2]}"}').join(', ')}}',
    'rna': rna.toString(),
  };

  if (country != null) body['country'] = country;
  if (region != null) body['region'] = region;
  if (subregion != null) body['subregion'] = subregion;
  if (geocomment != null) body['geocomment'] = geocomment;
  if (comment != null) body['comment'] = comment;
  if (point != null) body['point'] = point;
  if (collectId != null) body["collect_id"] = collectId;
  if (order != null) body["order"] = order;
  if (family != null) body["family"] = family;
  if (genus != null) body["genus"] = genus;
  if (kind != null) body["kind"] = kind;

  print(body);

  final response = await http
      .post(url, body: body, headers: {"Authorization": "Bearer $token"});
  print(response.body);
  print(response.statusCode);
}

Future<void> updateCollection({
  required int col_id,
  required String age,
  required String sex,
  required String vauchInst,
  required String vauchId,
  required String dateCollect,
  required List<List<String>> collectors,
  required String token,
  String? country,
  String? region,
  String? subregion,
  String? geocomment,
  String? comment,
  String? point,
  bool rna = false,
  String? collectId,
  String? order,
  String? family,
  String? genus,
  String? kind,
}) async {
  final url = Uri.http(URL, "rpc/update_collection_by_id");

  final body = {
    'col_id': col_id.toString(),
    'age': age,
    'sex': sex,
    'vauch_inst': vauchInst,
    'vauch_id': vauchId,
    'date_collect': dateCollect,
    'collectors':
        '{${collectors.map((collector) => '{"${collector[0]}", "${collector[1]}", "${collector[2]}"}').join(', ')}}',
    'rna': rna.toString(),
  };

  if (country != null) body['country'] = country;
  if (region != null) body['region'] = region;
  if (subregion != null) body['subregion'] = subregion;
  if (geocomment != null) body['geocomment'] = geocomment;
  if (comment != null) body['comment'] = comment;
  if (point != null) body['point'] = point;
  if (collectId != null) body["collect_id"] = collectId;
  if (order != null) body["order"] = order;
  if (family != null) body["family"] = family;
  if (genus != null) body["genus"] = genus;
  if (kind != null) body["kind"] = kind;
  final response = await http
      .post(url, body: body, headers: {"Authorization": "Bearer $token"});
  print(response.body);
}

Future<CollectionItem> getCollectionItemById(int id) async {
  var url = Uri.http(URL, "basic_view", {"id": "eq.$id"});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<CollectionItem> collection = List<CollectionItem>.from(
        l.map((model) => CollectionItem.fromJson(model)));
    return collection[0];
  }
  throw Exception();
}

Future<CollectionDTO> getCollectionDtoById(int id) async {
  var url = Uri.http(URL, "collection", {"id": "eq.$id"});
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<CollectionDTO> collection = List<CollectionDTO>.from(
        l.map((model) => CollectionDTO.fromJson(model)));
    return collection[0];
  }
  throw Exception();
}

Future<Collector> getCollectorById(int id) async {
  var url = Uri.http(URL, "collector", {"id": "eq.$id"});
  final response = await http.get(url);
  print(response.body);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<Collector> collectors = List<Collector>.from(
        l.map((collector) => Collector.fromJson(collector)));
    return collectors[0];
  }
  throw Exception();
}

Future<List<Collector>> getCollectorsByColItemId(int id) async {
  var url = Uri.http(URL, "collector_to_collection",
      {"select": "collector_id", "collection_id": "eq.$id"});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    print(response.body);
    Iterable l = json.decode(response.body);
    List<int> collectorIds =
        List<int>.from(l.map((e) => e["collector_id"] as int));
    List<Collector> collectors = List.empty(growable: true);
    for (int collector_id in collectorIds) {
      collectors.add(await getCollectorById(collector_id));
    }
    return collectors;
  }
  throw Exception();
}

Future<int> getOrderIdByName(String name) async {
  var url = Uri.http(URL, "order", {"select": "id", "name": "eq.$name"});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<int> orderIds = List<int>.from(l.map((e) => e["id"] as int));
    return orderIds[0];
  }
  throw Exception();
}

Future<int> getFamilyIdByName(String name, int orderId) async {
  var url = Uri.http(URL, "family",
      {"select": "id", "name": "eq.$name", "order_id": "eq.$orderId"});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<int> familyIds = List<int>.from(l.map((e) => e["id"] as int));
    return familyIds[0];
  }
  throw Exception();
}

Future<int> getGenusIdByName(String name, int familyId) async {
  var url = Uri.http(URL, "genus",
      {"select": "id", "name": "eq.$name", "family_id": "eq.$familyId"});
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<int> genusIds = List<int>.from(l.map((e) => e["id"] as int));
    return genusIds[0];
  }
  throw Exception();
}

Future<int> getKindIdByName(String name, int genusId) async {
  var url = Uri.http(URL, "kind",
      {"select": "id", "name": "eq.$name", "genus_id": "eq.$genusId"});
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<int> kindIds = List<int>.from(l.map((e) => e["id"] as int));
    return kindIds[0];
  }
  throw Exception();
}

Future<BaseModel> getBaseModelByNames(String orderName, String familyName,
    String genusName, String kindName) async {
  var orderId = await getOrderIdByName(orderName);
  var familyId = await getFamilyIdByName(familyName, orderId);
  var genusId = await getGenusIdByName(genusName, familyId);
  var kindId = await getKindIdByName(kindName, genusId);

  return (await getKindsById((await getGenusesById((await getFamiliesById(
                  (await getOrders())
                      .firstWhere((element) => element.id == orderId)))
              .firstWhere((element) => element.id == familyId)))
          .firstWhere((element) => element.id == genusId)))
      .firstWhere((element) => element.id == kindId);
}

Future<int> getLastCollectorId() async {
  var url = Uri.http(
      URL, 'collector', {"select": "id", "limit": "1", "order": "id.desc"});
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    return l.first["id"] as int;
  } else {
    throw Exception("Network not found.");
  }
}

Future<void> addCollector(
    String lastName, String firstName, String secondName, String token) async {
  var url = Uri.http(URL, 'collector');
  final body = {
    'last_name': lastName,
    'first_name': firstName,
    'second_name': secondName
  };
  final response = await http
      .post(url, body: body, headers: {"Authorization": "Bearer $token"});
  print(response.body);
}

Future<void> updateCollector(String lastName, String firstName,
    String secondName, String token, int id) async {
  var url = Uri.http(URL, 'collector', {"id": "eq.$id"});
  final body = {
    'last_name': lastName,
    'first_name': firstName,
    'second_name': secondName
  };
  final response = await http
      .patch(url, body: body, headers: {"Authorization": "Bearer $token"});
  print(response.body);
}

final topology = [
  BaseModelsTypes.order,
  BaseModelsTypes.family,
  BaseModelsTypes.genus,
  BaseModelsTypes.kind
];

Future<void> addBaseModel(
  BaseModel baseModel,
  String name,
  String token,
) async {
  final headers = {"Authorization": "Bearer $token"};
  var structure = {BaseModelsTypes.values[baseModel.type.index + 1].name: name};
  var father = baseModel;
  while ((father.type) != BaseModelsTypes.father) {
    structure[father.type.name] = father.name ?? "";
    father = father.parent ?? FATHER;
  }
  var url = Uri.http(URL, "rpc/add_topology");
  final response = await http.post(url, body: structure, headers: headers);
  print(response.body);
}

Future<void> updateBaseModel(
  BaseModel baseModel,
  String newName,
  String token,
) async {
  final headers = {"Authorization": "Bearer $token"};

  var url = Uri.http(URL, baseModel.type.name, {"id": "eq.${baseModel.id}"});

  final response =
      await http.patch(url, body: {"name": newName}, headers: headers);
  print(response.body);
}
