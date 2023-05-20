import 'dart:convert';

import 'package:collection/collection.dart';

class User {
  final String? login;
  final dynamic avatarUrl;
  final String? role;

  const User({this.login, this.avatarUrl, this.role});

  @override
  String toString() {
    return 'User(login: $login, avatarUrl: $avatarUrl, role: $role)';
  }

  factory User.fromMap(Map<String, dynamic> data) => User(
        login: data['login'] as String?,
        avatarUrl: data['avatar_url'] as dynamic,
        role: data['role'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'login': login,
        'avatar_url': avatarUrl,
        'role': role,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [User].
  factory User.fromJson(String data) {
    return User.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [User] to a JSON string.
  String toJson() => json.encode(toMap());

  User copyWith({
    String? login,
    dynamic avatarUrl,
    String? role,
  }) {
    return User(
      login: login ?? this.login,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! User) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => login.hashCode ^ avatarUrl.hashCode ^ role.hashCode;
}
