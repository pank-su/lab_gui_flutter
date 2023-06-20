import 'package:intl/intl.dart';

enum DateType { all, mounthAndYear, year }

class CollectionItem {
  int id;
  String? catalogueNumber;
  String? collectId;
  String? order;
  String? family;
  String? genus;
  String? species;
  String? age;
  String? gender;
  String? scientificInstitute;
  String? voucherId;
  double? latitude;
  double? longitude;
  String? country;
  String? region;
  String? subregion;
  String? geoComment;
  DateTime? date;
  bool? rna;
  String? comment;
  String? collectors;
  bool? hasFile;
  DateType dateType;

  CollectionItem(
      {required this.id,
      this.catalogueNumber,
      this.collectId,
      this.order,
      this.family,
      this.genus,
      this.species,
      this.age,
      this.gender,
      this.scientificInstitute,
      this.voucherId,
      this.latitude,
      this.longitude,
      this.country,
      this.region,
      this.subregion,
      this.geoComment,
      this.date,
      this.rna,
      this.comment,
      this.collectors,
      this.hasFile,
      required this.dateType});

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    var dateType = DateType.all;
    DateTime? date;
    try {
      date = DateFormat('d.M.y').parse(json['Дата']);
    } on Error catch (_) {
    } on FormatException catch (_) {
      dateType = DateType.mounthAndYear;
      try {
        date = DateFormat('M.y').parse(json['Дата']);
      } on Error catch (_) {
      } on FormatException catch (_) {
        dateType = DateType.year;
        date = DateFormat('y').parse(json['Дата']);
      }
    }

    return CollectionItem(
        id: json['id'] as int,
        catalogueNumber: json['CatalogueNumber'] as String?,
        collectId: json['collect_id'] as String?,
        order: json['Отряд'] as String?,
        family: json['Семейство'] as String?,
        genus: json['Род'] as String?,
        species: json['Вид'] as String?,
        age: json['Возраст'] as String?,
        gender: json['Пол'] as String?,
        scientificInstitute: json['Вауч. институт'] as String?,
        voucherId: json['Ваучерный ID'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longtitude'] as num?)?.toDouble(),
        country: json['Страна'] as String?,
        region: json['Регион'] as String?,
        subregion: json['Субрегион'] as String?,
        geoComment: json['Геокомментарий'] as String?,
        date: date,
        rna: json['rna'] as bool?,
        comment: json['Комментарий'] as String?,
        collectors: json['Коллекторы'] as String?,
        hasFile: json["Файл"] as bool,
        dateType: dateType);
  }
}
