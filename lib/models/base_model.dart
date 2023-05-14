enum BaseModelsTypes { order, family, genus, kind, father }

class BaseModel {
  int id;
  String? name;
  BaseModelsTypes type;
  BaseModel? parent;

  BaseModel({required this.id, required this.name, required this.type});

  factory BaseModel.fromJson(Map<String, dynamic> json, BaseModelsTypes type,
      {BaseModel? parent}) {
    return BaseModel(
        id: json['id'] as int, name: json['name'] as String?, type: type);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
