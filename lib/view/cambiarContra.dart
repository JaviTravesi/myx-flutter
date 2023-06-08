import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CambiarContra extends StatefulWidget {
  final String userId;

  CambiarContra({required this.userId});

  @override
  _CambiarContraState createState() => _CambiarContraState();
}

class _CambiarContraState extends State<CambiarContra> {
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url =
        Uri.parse('http://localhost:8000/api/auth/getUser/${widget.userId}');
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        passwordController.text = data['password'];
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> updateUser(String password) async {
    var url =
        Uri.parse('http://localhost:8000/api/auth/update/${widget.userId}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();

    var response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      print('Usuario actualizado exitosamente');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void changePassword(String newPassword) {
    if (newPassword.isNotEmpty) {
      updateUser(newPassword);
    } else {
      print('La contraseña no puede estar vacía');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Contraseña'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String newPassword = passwordController.text;
                  changePassword(newPassword);
                },
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
