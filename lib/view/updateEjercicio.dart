import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateEjercicio extends StatefulWidget {
  final String ejercicioId;

  UpdateEjercicio({required this.ejercicioId});

  @override
  _UpdateEjercicioState createState() => _UpdateEjercicioState();
}

class _UpdateEjercicioState extends State<UpdateEjercicio> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _nRepsController = TextEditingController();
  TextEditingController _nRondasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getEjercicioDetails();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> getEjercicioDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse(
        'http://localhost:8000/api/auth/getEjercicio/${widget.ejercicioId}');
    var response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _nombreController.text = data['nombre'];
        _nRepsController.text = data['n_reps'].toString();
        _nRondasController.text = data['n_rondas'].toString();
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void editarEjercicio(String nombre, int n_reps, int n_rondas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse(
        'http://localhost:8000/api/auth/ejercicio_listas/${widget.ejercicioId}');
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'nombre': nombre,
      'n_reps': n_reps.toString(),
      'n_rondas': n_rondas.toString(),
    });

    if (response.statusCode == 200) {
      print('Ejercicio actualizado exitosamente');
      // Navigator.pop(context);
    } else {
      throw Exception('Fallo en la carga del ejercicio');
    }
  }

  void _submitForm() {
    final String nombre = _nombreController.text;
    final String nReps = _nRepsController.text;
    final String nRondas = _nRondasController.text;

    editarEjercicio(nombre, int.parse(nReps), int.parse(nRondas));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Ejercicio'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _nRepsController,
              decoration: InputDecoration(labelText: 'N Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nRondasController,
              decoration: InputDecoration(labelText: 'N Rondas'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String nombre = _nombreController.text;
                int n_reps = int.parse(_nRepsController.text);
                int n_rondas = int.parse(_nRondasController.text);

                editarEjercicio(nombre, n_reps, n_rondas);
                _submitForm();
                Navigator.pop(context, true);
                final snackBar = SnackBar(
                  content: Text('Ejercicio actualizado.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
