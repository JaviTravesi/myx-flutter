import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateEjercicio extends StatefulWidget {
  @override
  _CreateEjercicioState createState() => _CreateEjercicioState();
}

class _CreateEjercicioState extends State<CreateEjercicio> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nRepsController = TextEditingController();
  final TextEditingController _nRondasController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Ejercicio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _nRepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de Repeticiones',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _nRondasController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de Rondas',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _videoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Vídeo',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Enviar'),
              onPressed: () {
                _submitForm();
                Navigator.pop(context, true);
                final snackBar = SnackBar(
                  content: Text('Ejercicio creado.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    final String nombre = _nombreController.text;
    final String nReps = _nRepsController.text;
    final String nRondas = _nRondasController.text;
    final String video = _videoController.text;

    createEjercicio(nombre, nReps, nRondas, video);
    Navigator.pop(context, true);
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<dynamic> createEjercicio(
      String nombre, String n_reps, String n_rondas, String video) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    final url = Uri.parse(
        'http://localhost:8000/api/auth/ejercicio_lista/createEjercicio');
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'nombre': nombre,
      'n_reps': n_reps,
      'n_rondas': n_rondas,
      'video': video
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to create ejercicio.');
    }
  }
}
