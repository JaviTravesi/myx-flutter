import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditUser extends StatefulWidget {
  final String userId;

  EditUser({required this.userId});

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  String _selectedTipo = 'Coach';
  String _selectedNivel = 'Scaled';

  void _submitForm() {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String direccion = _direccionController.text;
    final String edad = _edadController.text;
    final String peso = _pesoController.text;
    final String altura = _alturaController.text;
    final String tipo = _selectedTipo;
    final String nivel = _selectedNivel;

    updateUser(name, email, direccion, edad, peso, altura, tipo, nivel);
    Navigator.pop(context, true);
  }

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
      // Asigna los valores obtenidos a los controladores de los campos de texto
      setState(() {
        _nameController.text = data['name'];
        _emailController.text = data['email'];
        _direccionController.text = data['direccion'];
        _edadController.text = data['edad'].toString();
        _pesoController.text = data['peso'].toString();
        _alturaController.text = data['altura'].toString();
        _selectedTipo = data['tipo'];
        _selectedNivel = data['nivel'];
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void updateUser(String name, String email, String direccion, String edad,
      String peso, String altura, String tipo, String nivel) async {
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
        'name': name,
        'email': email,
        'direccion': direccion,
        'edad': edad,
        'peso': peso,
        'altura': altura,
        'tipo': tipo,
        'nivel': nivel,
      },
    );

    if (response.statusCode == 200) {
      print('Usuario actualizado exitosamente');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _edadController,
                decoration: InputDecoration(
                  labelText: 'Edad',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _pesoController,
                decoration: InputDecoration(
                  labelText: 'Peso',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _alturaController,
                decoration: InputDecoration(
                  labelText: 'Altura',
                ),
                keyboardType: TextInputType.number,
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
                onPressed: () {
                  _submitForm();
                  Navigator.pop(context, true);
                  final snackBar = SnackBar(
                    content: Text('Usuario actualizado'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
