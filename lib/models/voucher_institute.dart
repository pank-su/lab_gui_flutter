class VoucherInstitute {
  int id;
  String name;

  VoucherInstitute({required this.id, required this.name});

  factory VoucherInstitute.fromJson(Map<String, dynamic> json) {
    return VoucherInstitute(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}