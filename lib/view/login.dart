import 'dart:convert';
import 'package:app_myx/view/admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'menucoach.dart';
import 'menuatleta.dart';
import 'createUser.dart';
import 'registroNuevos.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final String apiUrl = "http://localhost:8000/api/auth/login";
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.teal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: <Widget>[
                        headerSection(),
                        SizedBox(height: 20),
                        textSection(),
                        SizedBox(height: 60),
                        buttonSection(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> signIn(String email, String pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> data = {'email': email, 'password': pass};
    var jsonResponse;

    var response = await http.post(Uri.parse(apiUrl), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);
        if (jsonResponse['tipo'] == 'admin') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Admin()),
            (Route<dynamic> route) => false,
          );
        } else if (jsonResponse['tipo'] == 'Coach') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Menucoach()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    Menuatleta(jsonResponse['id_usuario'])),
            (Route<dynamic> route) => false,
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  signIn(emailController.text, passwordController.text);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Por favor introduce las credenciales.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                "Entrar",
                style: TextStyle(color: Colors.white70),
              ),
      ),
    );
  }

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Email",
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Contraseña",
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.blue,
              textStyle: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistroNuevos(),
                ),
              );
            },
            child: Text("¿No tienes una cuenta? Regístrate",
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("MY X",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<dynamic> createUser(
      String name,
      String email,
      String password,
      String direccion,
      String edad,
      String peso,
      String altura,
      String tipo,
      String nivel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    final url = Uri.parse('http://localhost:8000/api/auth/register');
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'name': name,
      'email': email,
      'password': password,
      'direccion': direccion,
      'edad': edad,
      'peso': peso,
      'altura': altura,
      'tipo': tipo,
      'nivel': nivel
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to create user.');
    }
  }
}
