class CollectionItem {
  int? id;
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
  String? date;
  bool? rna;
  String? comment;
  String? stringAgg;

  CollectionItem({
    this.id,
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
    this.stringAgg,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] as int?,
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
      date: json['Дата'] as String?,
      rna: json['rna'] as bool?,
      comment: json['Комментарий'] as String?,
      stringAgg: json['string_agg'] as String?,
    );
  }
}
