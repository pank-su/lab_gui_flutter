class Collector {
  final int? id;
  final String? lastName;
  final String? firstName;
  final String? secondName;

  Collector({
    this.id,
    this.lastName,
    this.firstName,
    this.secondName,
  });

  factory Collector.fromJson(Map<String, dynamic> json) {
    return Collector(
      id: json['id'] as int?,
      lastName: json['last_name'] as String?,
      firstName: json['first_name'] as String?,
      secondName: json['second_name'] as String?,
    );
  }
}
