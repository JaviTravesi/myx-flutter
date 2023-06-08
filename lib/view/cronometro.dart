import 'dart:async';
import 'package:flutter/material.dart';

class Cronometro extends StatefulWidget {
  @override
  _CronometroState createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  int segundos = 0;
  bool cronometroActivo = false;
  Timer? cronometro;

  void iniciarCronometro() {
    cronometroActivo = true;
    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundos++;
      });
    });
  }

  void detenerCronometro() {
    cronometro?.cancel();
    cronometroActivo = false;
  }

  @override
  void dispose() {
    cronometro?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tiempo transcurrido: ${segundos}s',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (cronometroActivo) {
              detenerCronometro();
            } else {
              iniciarCronometro();
            }
          },
          child: Text(cronometroActivo ? 'Detener Cronómetro' : 'Iniciar Cronómetro'),
        ),
      ],
    );
  }
}
