import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:prev_out/appbar.dart';

class ListApp extends StatefulWidget {
  @override
  _ListApp createState() => _ListApp();
}

class _ListApp extends State<ListApp> {
  List<Map<String, dynamic>> data = []; // Datos cargados desde el CSV

  // Función para seleccionar y leer el archivo CSV
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'], // Aceptar solo archivos CSV
    );

    if (result != null) {
      var filePath = result.files.single.path;
      _readCsvFile(filePath!);
    }
  }

  // Función para leer el archivo CSV
  Future<void> _readCsvFile(String filePath) async {
    var file = File(filePath);

    try {
      String csvString = await file.readAsString(encoding: latin1);
      List<List<dynamic>> rows =
          CsvToListConverter(fieldDelimiter: ";").convert(csvString);

      List<Map<String, dynamic>> extractedData = [];
      final Map<String, String> carreraMap = {
        '0': 'Administración',
        '1': 'Automotriz',
        '2': 'Manufactura',
        '3': 'Mecatrónica',
        '4': 'Negocios',
        '5': 'Redes y Telecomunicaciones',
        '6': 'Sistemas',
        '7': 'Carrera 8',
      };

      for (var row in rows) {
        if (row.length > 145) {
          var matricula = row[0];
          var carrera = row[6]?.toString() ?? '';
          var porcentaje = row[145]?.toString() ?? '0';

          var carreraTexto = carreraMap[carrera] ?? 'Carrera desconocida';
          extractedData.add({
            'matricula': matricula,
            'carrera': carreraTexto,
            'porcentaje': porcentaje,
          });
        }
      }

      setState(() {
        data = extractedData;
      });
    } catch (e) {
      print("Error al leer el archivo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text("Seleccionar archivo CSV"),
            ),
            SizedBox(height: 20),
            data.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        "No hay datos cargados",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Matrícula')),
                            DataColumn(label: Text('Carrera')),
                            DataColumn(label: Text('Porcentaje')),
                          ],
                          rows: data
                              .map(
                                (row) => DataRow(
                                  cells: [
                                    DataCell(Text(row['matricula'].toString())),
                                    DataCell(Text(row['carrera'].toString())),
                                    DataCell(Text('${row['porcentaje']}%')),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ListApp(),
    theme: ThemeData(primarySwatch: Colors.blue),
  ));
}
