import 'package:app_myx/view/cambiarContra.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'calculo.dart';
import 'login.dart';
import 'ejercicio_lista.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'cronometro.dart';

class Menuatleta extends StatefulWidget {
  final int id_usuario;

  const Menuatleta(this.id_usuario, {super.key});

  @override
  _MenuatletaState createState() => _MenuatletaState();
}

class _MenuatletaState extends State<Menuatleta> {
  List<dynamic> users = [];
  List<dynamic> ejercicios = [];
  List<dynamic> rutinas = [];
  List<bool> realizados = [];
  List<Map<String, dynamic>> historial = [];
  late SharedPreferences sharedPreferences;
  int usuario_id = 0;

  @override
  void initState() {
    usuario_id = widget.id_usuario;
    super.initState();
    getRutinas();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse('http://localhost:8000/api/auth/getUser');
    // Reemplaza con el token válido

    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      showErrorModal('Error al obtener los usuarios');
    }
  }

  Future<void> deleteUser(dynamic usuario) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    try {
      final url =
          Uri.parse('http://localhost:8000/api/auth/delete/${usuario['id']}');
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Usuario eliminado correctamente');
      } else {
        showErrorModal('No se pudo eliminar el usuario');
      }
    } catch (error) {
      showErrorModal('Error al eliminar el usuario: $error');
    }
  }

  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorModal('No se pudo abrir la URL');
    }
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void showErrorModal(String message) {
    // Implementa la lógica para mostrar un modal de error
  }

  Future<void> getRutinas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse(
        'http://localhost:8000/api/auth/rutinaxejercicios/$usuario_id');

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

  void showCompletionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Ejercicio completado!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmación'),
              content: Text('¿Estás seguro de que deseas recargar la página?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );

        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Perfil'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Salir", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Container(
          color: Color.fromARGB(248, 239, 239, 240),
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Rutina')),
                      DataColumn(label: Text('Realizado')),
                    ],
                    rows: List<DataRow>.generate(rutinas.length, (index) {
                      bool realizado = realizados[index];
                      Color colorFondo =
                          realizado ? Colors.green.shade100 : Colors.white;

                      return DataRow(
                        color: MaterialStateColor.resolveWith(
                            (states) => colorFondo),
                        cells: [
                          DataCell(
                            Wrap(
                              children: [
                                Text(rutinas[index]['nombre'] ?? ''),
                              ],
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                setState(() {
                                  realizados[index] = !realizados[index];
                                  if (realizados[index]) {
                                    var now = DateTime.now();
                                    var formattedDate =
                                        DateFormat('yyyy-MM-dd – kk:mm')
                                            .format(now);
                                    historial.add({
                                      'nombre': rutinas[index]['nombre'],
                                      'fecha': formattedDate,
                                    });
                                    showCompletionMessage();
                                  }
                                });
                              },
                              child: Icon(
                                realizado
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: realizado ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Ejercicios',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      rutinas[index]['isExpanded'] = !isExpanded;
                    });
                  },
                  children:
                      List<ExpansionPanel>.generate(rutinas.length, (index) {
                    var rutina = rutinas[index];
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text('${rutina['nombre']}'),
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nº Reps: ${rutina['n_reps']}'),
                            Text('Nº Rondas: ${rutina['n_rondas']}'),
                            ElevatedButton(
                              onPressed: () async {
                                var videoUrl = rutina['video'];
                                if (await canLaunch(videoUrl)) {
                                  await launch(videoUrl);
                                } else {
                                  throw 'No se pudo abrir el video';
                                }
                              },
                              child: Text('Ver video'),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: rutina['isExpanded'] ?? false,
                    );
                  }),
                ),
                SizedBox(height: 16),
                Text(
                  'Historial de actividades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: rutinas.length,
                  itemBuilder: (BuildContext context, int index) {
                    var rutina = rutinas[index];
                    DateTime fechaActual = DateTime.now();
                    String nombre = rutina['nombre'] ?? '';
                    String fecha = rutina['created_at'] ?? '';
                    String fechaFormateada =
                        DateFormat('dd/MM/yyyy').format(fechaActual);

                    return Card(
                      child: ListTile(
                        title: Text(nombre),
                        subtitle: Text('Realizado el: $fechaFormateada'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Acciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calculate),
                    title: Text('Calcular IMC'),
                    onTap: () {
                      Navigator.pushNamed(context, '/calcularIMC');
                    },
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Cronómetro'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Cronometro(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Encuentra tu box más cercano'),
                    onTap: () {
                      launchURL('https://map.crossfit.com/');
                    },
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.open_in_browser),
                    title: Text('Ir a Crossfit.com'),
                    onTap: () {
                      launchURL('https://www.crossfit.com/');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
