import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Importar el paquete necesario
import 'dart:io';
import 'dart:convert';

import 'package:prev_out/appbar.dart';

class GraphicsApp extends StatelessWidget {
  const GraphicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CombinedWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CombinedWidget extends StatefulWidget {
  const CombinedWidget({super.key});

  @override
  State<CombinedWidget> createState() => _CombinedWidgetState();
}

class _CombinedWidgetState extends State<CombinedWidget> {
  List<dynamic>? jsonData; // Variable para almacenar datos del archivo JSON

  // Función para seleccionar y leer el archivo JSON
  Future<void> _pickFileJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Aceptar solo archivos JSON
    );

    if (result != null) {
      var filePath = result.files.single.path;
      if (filePath != null) {
        await _readJsonFile(filePath);
      }
    }
  }

  // Función para leer el archivo JSON
  Future<void> _readJsonFile(String filePath) async {
    var file = File(filePath);

    try {
      String jsonString = await file.readAsString();
      setState(() {
        jsonData = jsonDecode(jsonString); // Procesar el archivo JSON
      });
      print("Archivo JSON cargado con éxito: $jsonData");
    } catch (e) {
      print("Error al leer el archivo JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fondo
      appBar: const CustomAppBar(), // Respetar la CustomAppBar
      body: ListView(
        children: [
          contenido(context),
          // Botón para cargar archivo JSON
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _pickFileJson, // Asignar función al botón
              child: const Text("Seleccionar archivo JSON"),
            ),
          ),
          if (jsonData != null) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Datos del archivo JSON:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                jsonData.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget contenido(context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            bar(),
            lista(context),
          ],
        ),
      ),
    );
  }

  Widget bar() {
    return Container(
      width: double.infinity,
      height: 30,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 135, 9, 9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Gráficas',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget lista(BuildContext context) {
    return Container(
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: const [
              Graphics(titulo: "Gráfica de barra 1", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "Gráfica de barra 2", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "Gráfica de barra 3", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "Gráfica de barra 1", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "Gráfica de barra 2", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "Gráfica de barra 3", fcolor: Color(0xffFFE5E5)),
            ],
          ),
        ),
      ),
    );
  }
}

class Graphics extends StatelessWidget {
  final String titulo;
  final Color fcolor;

  const Graphics({
    Key? key,
    required this.titulo,
    required this.fcolor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 365,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: fcolor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




