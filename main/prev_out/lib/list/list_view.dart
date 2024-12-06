import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:prev_out/appbar.dart';

class ListApp extends StatefulWidget {
  @override
  _ListApp createState() => _ListApp();
}

class _ListApp extends State<ListApp> {
  String? _selectedFilePath;
  String _predictionResult = "";
  List<String> fileNames = [];
  List<Map<String, dynamic>> data = []; // Datos cargados desde el CSV

  // Ruta del directorio a monitorear
  final String _watchDirectory = '/ruta/a/tu/directorio';
  // StreamSubscription para escuchar cambios en el directorio
  StreamSubscription<FileSystemEvent>? _directorySubscription;

  @override
  void initState() {
    super.initState();
    _listFiles(); // Listar archivos actuales al iniciar
    _watchDirectoryChanges(); // Empezar a monitorear cambios en el directorio
  }

  @override
  void dispose() {
    _directorySubscription?.cancel(); // Detener el listener al cerrar
    super.dispose();
  }

  // Listar los archivos existentes en el directorio
  void _listFiles() {
    final directory = Directory(_watchDirectory);
    if (directory.existsSync()) {
      setState(() {
        fileNames = directory
            .listSync()
            .where((item) => item is File)
            .map((item) => path.basename(item.path))
            .toList();
      });
    }
  }

  // Monitorear cambios en el directorio
  void _watchDirectoryChanges() {
    final directory = Directory(_watchDirectory);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true); // Crear directorio si no existe
    }

    _directorySubscription = directory.watch().listen((event) {
      if (event.type == FileSystemEvent.create) {
        // Nuevo archivo detectado
        final newFilePath = event.path;
        setState(() {
          fileNames
              .add(path.basename(newFilePath)); // Actualizar lista de archivos
          _selectedFilePath =
              newFilePath; // Seleccionar automáticamente el nuevo archivo
        });

        // Llamar a la predicción automáticamente
        _uploadAndPredict(newFilePath);
      }
    });
  }

  Future<void> _uploadAndPredict(String filePath) async {
    var uri =
        Uri.parse('http://192.168.0.16:5001/predict'); // Cambia a la URL de tu API
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await http.Response.fromStream(response);
      var decodedResponse = json.decode(responseBody.body);
      setState(() {
        _predictionResult = decodedResponse['message'];
      });
    } else {
      setState(() {
        _predictionResult = "Error al realizar la predicción.";
      });
    }
  }

 Future<void> _pickFilexlsx() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }













  // Función para seleccionar y leer el archivo CSV
  Future<void> _pickFilecsv() async {
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
          // Fila para todos los botones en la parte superior
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Alinea al inicio
            crossAxisAlignment: CrossAxisAlignment.center, // Centra verticalmente
            children: [
              // Campo de búsqueda
              Container(
                width: 400, // Ajusta el ancho según tus necesidades
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Inserta una matrícula para buscar',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 135, 9, 9)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 20), // Espaciado entre elementos
              // Botón para seleccionar CSV
              ElevatedButton(
                onPressed: _pickFilecsv,
                child: const Text("Seleccionar archivo CSV"),
              ),
              const SizedBox(width: 20),
              // Botón para seleccionar archivo general
              ElevatedButton(
                onPressed: _pickFilexlsx,
                child: const Text("Seleccionar archivo"),
              ),
              const SizedBox(width: 20),
              // Botón para subir y predecir
              ElevatedButton(
                onPressed: () {
                  if (_selectedFilePath != null) {
                    _uploadAndPredict(_selectedFilePath!);
                  }
                },
                child: const Text("Subir y predecir"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Información del archivo seleccionado
          if (_selectedFilePath != null)
            Text(
              "Archivo seleccionado: ${path.basename(_selectedFilePath!)}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 10),
          if (_predictionResult.isNotEmpty)
            Text(
              "Resultado de la predicción: $_predictionResult",
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 20),
          // Tabla de datos o mensaje de datos no cargados
          data.isEmpty
              ? Expanded(
                  child: Center(
                    child: const Text(
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
                        columns: const [
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