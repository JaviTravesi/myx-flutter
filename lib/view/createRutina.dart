import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ejercicio {
  int id;
  final String nombre;
  final int n_reps;
  final int n_rondas;
  final String video;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.n_reps,
    required this.n_rondas,
    required this.video,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      id: json['id'],
      nombre: json['nombre'],
      n_reps: json['n_reps'],
      n_rondas: json['n_rondas'],
      video: json['video'],
    );
  }

  // ...

  @override
  String toString() {
    return 'Ejercicio{id: $id, nombre: $nombre, n_reps: $n_reps, n_rondas: $n_rondas, video: $video}';
  }
}

class CreateRutina extends StatefulWidget {
  @override
  _CreateRutinaState createState() => _CreateRutinaState();
}

class _CreateRutinaState extends State<CreateRutina> {
  List<Ejercicio> ejercicioList = [];
  List<bool> ejercicioCheckedList = [];
  bool isLoading = true;
  String nivelSeleccionado = 'Scaled';
  List<String> niveles = ['Scaled', 'Intermedio', 'RX'];
  TextEditingController nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getEjercicios();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> getEjercicios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse('http://localhost:8000/api/auth/getEjercicios');
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      ejercicioList.clear();
      ejercicioCheckedList.clear();
      jsonData.forEach((ejercicio) {
        Ejercicio newEjercicio = Ejercicio.fromJson(ejercicio);
        ejercicioList.add(newEjercicio);
        ejercicioCheckedList.add(false);
        setState(() {
          isLoading = false;
        });
        print('ejercicioList: $ejercicioList');
        print('ejercicioCheckedList: $ejercicioCheckedList');
      });
    } else {
      throw Exception('No se han podido cargar los ejercicios.');
    }
  }

  Widget buildEjercicioCheckboxList(List<Ejercicio> ejercicios) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: ejercicios.length,
      itemBuilder: (BuildContext context, int index) {
        final ejercicio = ejercicios[index];
        return CheckboxListTile(
          title: Text(ejercicio.nombre),
          value: ejercicioCheckedList[index],
          onChanged: (bool? value) {
            setState(() {
              ejercicioCheckedList[index] = value ?? false;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Rutina'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Nivel:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            DropdownButton<String>(
              value: nivelSeleccionado,
              onChanged: (String? newValue) {
                setState(() {
                  nivelSeleccionado = newValue!;
                });
              },
              items: niveles.map((String nivel) {
                return DropdownMenuItem<String>(
                  value: nivel,
                  child: Text(nivel),
                );
              }).toList(),
            ),
            SizedBox(height: 8.0),
            Text(
              'Selecciona los ejercicios:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            isLoading
                ? CircularProgressIndicator()
                : buildEjercicioCheckboxList(ejercicioList),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String nombreRutina = nombreController.text;
              },
              child: Text('Añadir Rutina'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CreateRutina(),
  ));
}
