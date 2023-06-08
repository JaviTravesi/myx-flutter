import 'package:flutter/material.dart';

class CalculoIMCPage extends StatefulWidget {
  @override
  _CalculoIMCPageState createState() => _CalculoIMCPageState();
}

class _CalculoIMCPageState extends State<CalculoIMCPage> {
  TextEditingController alturaController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  double bmi = 0.0;
  String result = '';

  void calculaIMC() {
    double? altura = double.tryParse(alturaController.text);
    double? peso = double.tryParse(pesoController.text);

    if (altura != null && peso != null && altura > 0 && peso > 0) {
      setState(() {
        bmi = peso / ((altura / 100) * (altura / 100));
        result = resultadoIMC(bmi);
      });
    } else {
      setState(() {
        bmi = 0.0;
        result = '';
      });
    }
  }

  String resultadoIMC(double bmi) {
    if (bmi < 18.5) {
      return 'Delgado';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Sobrepeso';
    } else {
      return 'Obesidad';
    }
  }

  @override
  void dispose() {
    alturaController.dispose();
    pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calcula tu IMC'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: alturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Altura (cm)',
              ),
            ),
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Calcular'),
              onPressed: calculaIMC,
            ),
            SizedBox(height: 16.0),
            Text(
              'IMC: ${bmi.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Estado: $result',
              style: TextStyle(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }
}
