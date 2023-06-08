import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'createRutina.dart';
import 'calculo.dart';

class Rutina extends StatefulWidget {
  @override
  _RutinaPageState createState() => _RutinaPageState();
}

class _RutinaPageState extends State<Rutina> {
  List<dynamic> rutinas = [];
  List<bool> realizados = [];

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
  void initState() {
    super.initState();
    getRutinas();
  }

  Future<void> getRutinas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse('http://localhost:8000/api/auth/getRutinas');

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
        rutinas = data;
        realizados = List<bool>.filled(data.length, false);
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  Future<int> createRutina(
    String nombre,
    int n_reps,
    int n_rondas,
    String nivel,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    final url = Uri.parse('http://localhost:8000/api/auth/rutina_lista');
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'nombre': nombre,
      'n_reps': n_reps.toString(),
      'n_rondas': n_rondas.toString(),
      'nivel': nivel,
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to create rutina.');
    }
  }

  Future<void> deleteRutina(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    try {
      var url = Uri.parse('http://localhost:8000/api/auth/rutina_lista/$id');
      var response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Rutina eliminada correctamente');
      } else {
        throw Exception('No se pudo eliminar la rutina');
      }
    } catch (error) {
      print('Error al eliminar la rutina: $error');
    }
  }

  Future<bool?> showDeleteConfirmationModal() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar rutina'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar esta rutina?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas de entrenamiento'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: rutinas
                          .map(
                            (rutina) => DataRow(cells: [
                              DataCell(Text(rutina['rutina_nombre'])),
                              DataCell(Text(rutina['ejercicio_nombre'])),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        var rutinaId = rutina['id'];
                                        if (rutinaId != null) {
                                          deleteRutina(
                                              int.parse(rutinaId.toString()));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          )
                          .toList(),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRutina(),
                            ),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
