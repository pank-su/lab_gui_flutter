import 'dart:convert';

import 'package:collection/collection.dart';

class Jwt {
  final String? token;

  const Jwt({this.token});

  @override
  String toString() => 'Jwt(token: $token)';

  factory Jwt.fromMap(Map<String, dynamic> data) => Jwt(
        token: data['token'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'token': token,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Jwt].
  factory Jwt.fromJson(String data) {
    return Jwt.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Jwt] to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Jwt) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => token.hashCode;
}
