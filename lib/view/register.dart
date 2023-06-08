import 'dart:convert';

import 'package:app_myx/view/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class BoolEditingController extends TextEditingController {
  bool get boolValue => text == 'true';
  set boolValue(bool value) => text = value.toString();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController edadController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  TextEditingController alturaController = TextEditingController();
  TextEditingController tipoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  Future<void> signUp(String name, String email, String password,
      String direccion, int edad, int peso, int altura, bool tipo) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'password': password,
      'direccion': direccion,
      'edad': edad,
      'peso': peso,
      'altura': altura,
      'tipo': tipo,
      'role': 'atleta'
    };
    var jsonResponse;

    var response = await http
        .post(Uri.parse("http://localhost:8000/api/auth/register"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
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
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });
            signUp(
                nameController.text,
                emailController.text,
                passwordController.text,
                direccionController.text,
                int.parse(edadController.text),
                int.parse(pesoController.text),
                int.parse(alturaController.text),
                bool.fromEnvironment(tipoController.text));
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: Colors.purple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: Text("Sign Up", style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: nameController,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                icon: Icon(Icons.person, color: Colors.white70),
                hintText: "Name",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Name can't be empty";
                }
                return null;
              },
            ),
            SizedBox(height: 30.0),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                icon: Icon(Icons.email, color: Colors.white70),
                hintText: "Email",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Email can't be empty";
                } else if (!RegExp(
                        r'^.+@[a-zA-Z]+.{1}[a-zA-Z]+(.{0,1}[a-zA-Z]+)$')
                    .hasMatch(value)) {
                  return "Please enter a valid email";
                }
                return null;
              },
            ),
            SizedBox(height: 30.0),
            TextFormField(
              controller: passwordController,
              cursorColor: Colors.white,
              obscureText: true,
              style: TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                icon: Icon(Icons.lock, color: Colors.white70),
                hintText: "Password",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Password can't be empty";
                } else if (value.length < 6) {
                  return "Password should be at least 6 characters long";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Sign Up", style: TextStyle(color: Colors.white)),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RegisterPage(),
    );
  }
}

void main() {
  runApp(MyApp());
}
