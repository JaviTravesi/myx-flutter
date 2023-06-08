import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataBaseHelper {
  String serverUrl = "http://localhost:8000/api/auth/";
  String serverLogin = "http://localhost:8000/api/auth/login";

  var status;

  var token;

  loginData(String email, String password) async {
    String myUrl = "$serverUrl/login";
    final response = await http.post(Uri.parse(myUrl),
        headers: {'Accept': 'application/json'},
        body: {"email": "$email", "password": "$password"});
    status = response.body.contains('error');
    var data = json.decode(response.body);

    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["token"]}');
      _save(data["token"]);
    }
  }

  _save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = token;
    prefs.setString(key, value);
  }

  //function read
  read() async {
    final prefs = await SharedPreferences.getInstance();

    final key = 'token';

    final value = prefs.get(key) ?? 0;

    print('read : $value');
  }
}
