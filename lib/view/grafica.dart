import 'package:flutter/material.dart';

class Grafica extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfica'),
      ),
      body: Container(
        child: Center(
          child: Text(
            'Esta es la vista de la Gráfica',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
