import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'CreateUser.dart';
import 'EditUser.dart';

class Usuario extends StatefulWidget {
  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<Usuario> {
  List<dynamic> usuarios = [];

  Future<void> showErrorModal(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showDeleteConfirmationModal() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar usuario'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar este usuario?'),
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

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> getUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken();
    var url = Uri.parse('http://localhost:8000/api/auth/getUsers');

    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var filteredUsers =
          data.where((user) => user['tipo'] != 'admin').toList();
      setState(() {
        usuarios = filteredUsers;
      });
    } else {
      showErrorModal('Error: ${response.statusCode}');
    }
  }

  Future<void> createUser() async {
    var url = Uri.parse('http://localhost:8000/api/auth/createUser');
    var token = await getToken();

    var response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': 'Nuevo Usuario',
        'email': 'Nuevo email',
        'password': 'Nueva contraseña',
        'direccion': 'Nueva direccion',
        'edad': 'Nueva edad',
        'peso': 'Nuevo peso',
        'altura': 'Nuevo peso',
        'tipo': 'Tipo de Usuario',
      },
    );

    if (response.statusCode == 200) {
      print('Usuario creado exitosamente');
      getUsers();
    } else {
      showErrorModal('Error: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(dynamic usuario) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await getToken(); // Obtener el token de las SharedPreferences
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

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Tipo')),
                          DataColumn(label: Text('Nivel')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: usuarios
                            .map(
                              (usuario) => DataRow(cells: [
                                DataCell(Text(usuario['name'])),
                                DataCell(
                                    Text(usuario['tipo'].toString() ?? ' ')),
                                DataCell(
                                    Text(usuario['nivel'].toString() ?? ' ')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => EditUser(
                                                    userId: usuario['id']
                                                        .toString())),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          bool? deleteConfirmed =
                                              await showDeleteConfirmationModal();
                                          if (deleteConfirmed != null &&
                                              deleteConfirmed) {
                                            deleteUser(usuario);
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
                              builder: (context) => CreateUser(),
                            ),
                          );
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
