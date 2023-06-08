import 'package:flutter/material.dart';
import 'usuario.dart';
import 'ejercicio_lista.dart';
import 'rutina_lista.dart';
import 'grafica.dart';

import 'package:app_myx/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends StatelessWidget {
  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Usuario()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('Usuarios',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EjercicioListView()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('Ejercicios',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Rutina()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('Rutinas',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
