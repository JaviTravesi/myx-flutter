import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'createEjercicio.dart';
import 'updateEjercicio.dart';
import 'package:url_launcher/url_launcher.dart';

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
}

class EjercicioList {
  List<Ejercicio> ejercicios = [];

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
      ejercicios.clear();
      jsonData.forEach((ejercicio) {
        Ejercicio newEjercicio = Ejercicio.fromJson(ejercicio);
        ejercicios.add(newEjercicio);
      });
    } else {
      throw Exception('No se han podido cargar los ejercicios.');
    }
  }

  Future<void> deleteEjercicio(Ejercicio ejercicio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    try {
      final url = Uri.parse(
          'http://localhost:8000/api/auth/ejercicio_lista/${ejercicio.id}');
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print('Ejercicio eliminado correctamente');
      } else {
        throw Exception('No se pudo eliminar el ejercicio');
      }
    } catch (error) {
      print('Error al eliminar el ejercicio: $error');
    }
  }
}

class EjercicioListView extends StatefulWidget {
  @override
  _EjercicioListViewState createState() => _EjercicioListViewState();
}

class _EjercicioListViewState extends State<EjercicioListView> {
  final EjercicioList ejercicioList = EjercicioList();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ejercicioList.getEjercicios().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void showDeleteConfirmationModal(Ejercicio ejercicio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Ejercicio'),
          content:
              Text('¿Estás seguro de que quieres eliminar este ejercicio?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                ejercicioList.deleteEjercicio(ejercicio);
                setState(() {
                  ejercicioList.ejercicios.remove(ejercicio);
                });
                Navigator.of(context).pop();
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
        title: const Text('Ejercicios'),
      ),
      body: isLoading
          ? Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            )
          : LayoutBuilder(
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
                              DataColumn(label: Text('Vídeo')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: ejercicioList.ejercicios.map((ejercicio) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(ejercicio.nombre)),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.play_arrow),
                                      onPressed: () async {
                                        var videoUrl = ejercicio.video;
                                        if (await canLaunch(videoUrl)) {
                                          await launch(videoUrl);
                                        } else {
                                          throw 'No se pudo abrir el video';
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateEjercicio(
                                                  ejercicioId:
                                                      ejercicio.id.toString(),
                                                ),
                                              ),
                                            ).then((value) {
                                              setState(() {
                                                ejercicioList.getEjercicios();
                                              });
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            showDeleteConfirmationModal(
                                                ejercicio);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Icon(Icons.add),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateEjercicio(),
                                  ),
                                ).then((value) {
                                  setState(() {
                                    ejercicioList.getEjercicios();
                                  });
                                });
                              },
                            ),
                          ),
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
