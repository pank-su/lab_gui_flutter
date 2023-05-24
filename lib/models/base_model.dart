enum BaseModelsTypes { order, family, genus, kind, father }

/// Класс который работает с топологией
/// [id] - идентификатор
/// [name] - название
/// [type] - тип
/// [parent] - отец
class BaseModel {
  int id;
  String? name;
  BaseModelsTypes type;
  BaseModel? parent;

  BaseModel({required this.id, required this.name, required this.type, this.parent});

  factory BaseModel.fromJson(Map<String, dynamic> json, BaseModelsTypes type,
      {BaseModel? parent}) {
    return BaseModel(
        id: json['id'] as int, name: json['name'] as String?, type: type, parent: parent);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  /// Получение списка топологии
  List<String> getFullTopology(){
    var first = this;
    List<String> topology = List.empty(growable: true);
    topology.add(first.name ?? "");
    while (first.parent != null){
      first = first.parent!;
      topology.add(first.name ?? "");
    }
    
    return topology.reversed.toList();
  }
}
