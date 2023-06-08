import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateUser extends StatefulWidget {
  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  String _selectedTipo = 'Coach';
  String _selectedNivel = 'Scaled';

  void _submitForm() {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String direccion = _direccionController.text;
    final String edad = _edadController.text;
    final String peso = _pesoController.text;
    final String altura = _alturaController.text;
    final String tipo = _selectedTipo;
    final String nivel = _selectedNivel;

    createUser(
        name, email, password, direccion, edad, peso, altura, tipo, nivel);
    Navigator.pop(context, true);
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
    final url = Uri.parse('http://localhost:8000/api/auth/createUser');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _edadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edad',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Peso',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _alturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Altura',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: _selectedTipo,
              items: [
                DropdownMenuItem(
                  value: 'Coach',
                  child: Text('Coach'),
                ),
                DropdownMenuItem(
                  value: 'Atleta',
                  child: Text('Atleta'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTipo = value.toString();
                });
              },
              decoration: InputDecoration(
                labelText: 'Tipo',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: _selectedNivel,
              items: [
                DropdownMenuItem(
                  value: 'Scaled',
                  child: Text('Scaled'),
                ),
                DropdownMenuItem(
                  value: 'Intermedio',
                  child: Text('Intermedio'),
                ),
                DropdownMenuItem(
                  value: 'RX',
                  child: Text('RX'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedNivel = value.toString();
                });
              },
              decoration: InputDecoration(
                labelText: 'Nivel',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Enviar'),
              onPressed: () {
                _submitForm();
                Navigator.pop(context, true);
                final snackBar = SnackBar(
                  content: Text('Usuario creado'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        ),
      ),
    );
  }
}
