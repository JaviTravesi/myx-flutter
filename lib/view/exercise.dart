import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Exercise {
  final int id;
  final String name;
  final int nReps;
  final int nRounds;
  final String createdAt;
  final String updatedAt;

  Exercise({
    required this.id,
    required this.name,
    required this.nReps,
    required this.nRounds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['nombre'],
      nReps: json['n_reps'],
      nRounds: json['n_rondas'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ExerciseForm extends StatefulWidget {
  ExerciseForm();

  @override
  _ExerciseFormState createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  List<Exercise> exercises = [];
  TextEditingController _textFieldController = TextEditingController();
  String selectedValue = 'rx';
  List<bool> exerciseCheckboxes = [];

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    final response = await http.get(Uri.parse('URL_DE_TU_API'));
    final jsonData = json.decode(response.body);

    setState(() {
      exercises = (jsonData as List)
          .map((exerciseJson) => Exercise.fromJson(exerciseJson))
          .toList();

      exerciseCheckboxes = List.generate(exercises.length, (index) => false);
    });
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicio Formulario'),
      ),
      body: exercises.isNotEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _textFieldController,
                      decoration: InputDecoration(labelText: 'Campo de texto'),
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedValue,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                      items: ['rx', 'intermedio', 'scaled']
                          .map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      decoration: InputDecoration(labelText: 'Selector'),
                    ),
                    SizedBox(height: 16.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          value: exerciseCheckboxes[index],
                          onChanged: (value) {
                            setState(() {
                              exerciseCheckboxes[index] = value!;
                            });
                          },
                          title: Text(exercises[index].name),
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        String textFieldValue = _textFieldController.text;
                        print(textFieldValue);
                        print(selectedValue);
                        print(exerciseCheckboxes);

                        Exercise selectedExercise = exercises.firstWhere(
                          (exercise) =>
                              exerciseCheckboxes[exercises.indexOf(exercise)],
                          orElse: () => Exercise(
                            id: -1,
                            name: '',
                            nReps: 0,
                            nRounds: 0,
                            createdAt: '',
                            updatedAt: '',
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExerciseDetailScreen(exercise: selectedExercise),
                          ),
                        );
                      },
                      child: Text('Enviar'),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  ExerciseDetailScreen({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Ejercicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nombre: ${exercise.name}'),
            Text('Repeticiones: ${exercise.nReps}'),
            Text('Rondas: ${exercise.nRounds}'),
            Text('Creado en: ${exercise.createdAt}'),
            Text('Actualizado en: ${exercise.updatedAt}'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ExerciseForm(),
  ));
}
