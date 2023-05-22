class CollectionDTO {
  final int? id;
  final String? catalogueNumber;
  final String? collectId;
  final int? kindId;
  final int? subregionId;
  final String? genBankId;
  final String? point;
  final int? vouchInstId;
  final String? vouchId;
  final bool? rna;
  final int? sexId;
  final int? ageId;
  final int? day;
  final int? month;
  final int? year;
  final String? comment;
  final String? geoComment;

  CollectionDTO({
    this.id,
    this.catalogueNumber,
    this.collectId,
    this.kindId,
    this.subregionId,
    this.genBankId,
    this.point,
    this.vouchInstId,
    this.vouchId,
    this.rna,
    this.sexId,
    this.ageId,
    this.day,
    this.month,
    this.year,
    this.comment,
    this.geoComment,
  });

  factory CollectionDTO.fromJson(Map<String, dynamic> json) {
    return CollectionDTO(
      id: json['id'] as int?,
      catalogueNumber: json['CatalogueNumber'] as String?,
      collectId: json['collect_id'] as String?,
      kindId: json['kind_id'] as int?,
      subregionId: json['subregion_id'] as int?,
      genBankId: json['gen_bank_id'] as String?,
      point: json['point'] as String?,
      vouchInstId: json['vouch_inst_id'] as int?,
      vouchId: json['vouch_id'] as String?,
      rna: json['rna'] as bool?,
      sexId: json['sex_id'] as int?,
      ageId: json['age_id'] as int?,
      day: json['day'] as int?,
      month: json['month'] as int?,
      year: json['year'] as int?,
      comment: json['comment'] as String?,
      geoComment: json['geo_comment'] as String?,
    );
  }
}
