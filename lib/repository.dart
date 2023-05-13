import 'package:http/http.dart' as http;
import 'package:lab_gui_flutter/jwt.dart';

const URL = "localhost:3000";

Future<Jwt> login(String login, String password) async {
  var url = Uri.http(URL, 'rpc/login');
  print(url.toString());
  final response =
      await http.post(url, body: {'email': login, 'pass': password});
  print(response.body);
  print(response.statusCode);

  if (response.statusCode == 200)
    return Jwt.fromJson(response.body);
  else
    throw Exception("Bad login or password");
}

Future<bool> testRequest(String jwt) async {
  var url = Uri.http(URL, "rpc/test");
  final response = await http.post(url);
  if (response.statusCode == 200)
    return true;
  else
    return true;
  throw Exception("Bad login or password");
}
