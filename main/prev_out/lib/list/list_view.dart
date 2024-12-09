import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
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
  List<Map<String, dynamic>> data = []; // Datos cargados desde el JSON
  List<Map<String, dynamic>> filteredData = []; // Datos filtrados
  TextEditingController _searchController = TextEditingController(); // Controlador para el campo de búsqueda

  // Ruta del directorio a monitorear
  final String _watchDirectory = '/ruta/a/tu/directorio';
  // StreamSubscription para escuchar cambios en el directorio
  StreamSubscription<FileSystemEvent>? _directorySubscription;

  @override
  void initState() {
    super.initState();
    _listFiles(); // Listar archivos actuales al iniciar
    _watchDirectoryChanges(); // Empezar a monitorear cambios en el directorio
    filteredData = data;  // Inicializa los datos filtrados
    
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




 // Función para seleccionar y leer el archivo JSON
  Future<void> _pickFileJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Aceptar solo archivos JSON
    );

    if (result != null) {
      var filePath = result.files.single.path;
      _readJsonFile(filePath!);
    }
  }


//Función para leer JSON
Future<void> _readJsonFile(String filePath) async {
  var file = File(filePath);

  try {
    String jsonString = await file.readAsString();
    var jsonData = jsonDecode(jsonString);
    var sheetData = jsonData['Sheet1']; // Aseguramos acceder a la clave correcta.

    // Mapeo de los códigos de "PROGRAMA EDUCATIVO" a los nombres de carrera
    final Map<int, String> carreraMap = {
      0: 'Administración',
      1: 'Automotriz',
      2: 'Manufactura',
      3: 'Mecatrónica',
      4: 'Negocios',
      5: 'Redes y Telecomunicaciones',
      6: 'Sistemas',
      7: 'Otro',
    };

    List<Map<String, dynamic>> extractedData = [];
    for (var item in sheetData) {
      // Obtener matrícula
      var matricula = item['Matricula'] ?? 'Sin matrícula';

      // Obtener carrera
      var carreraNumero = item['PROGRAMA EDUCATIVO'];
      String carreraNombre = 'Carrera desconocida';
      if (carreraNumero is int) {
        carreraNombre = carreraMap[carreraNumero] ?? 'Carrera desconocida';
      }

      // Obtener porcentaje
      var porcentaje = item['Probabilidad Baja (%)']?.toString() ?? '0.0';

      // Agregar datos procesados
      extractedData.add({
        'matricula': matricula.toString(),
        'carrera': carreraNombre,
        'porcentaje': porcentaje,
      });
    }

    setState(() {
      data = extractedData;
      filteredData = extractedData; // Inicializar datos filtrados
    });
  } catch (e) {
    print("Error al leer el archivo JSON: $e");
  }
}


void _searchMatricula() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredData = data
          .where((item) => item['matricula'].toString().toLowerCase().contains(query))
          .toList();
    });
  }


void filterByCareer(String career) {
    if (career == "Todas") {
      setState(() {
        filteredData = List.from(data);
      });
    } else {
      setState(() {
        filteredData = data.where((row) => row['carrera'] == career).toList();
      });
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Campo de búsqueda
                Container(
                  width: 400,
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Inserta una matrícula para buscar',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                   icon: Icon(Icons.search, color: Color.fromARGB(255, 135, 9, 9)),
                  onPressed: _searchMatricula,
                ),
                const SizedBox(width: 20), // Espaciado entre elementos
                // Botón para seleccionar JSON
                ElevatedButton(
                  onPressed: _pickFileJson,
                  child: const Text("Seleccionar archivo JSON"),
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
            Expanded(
              child: filteredData.isEmpty
                  ? Center(
                      child: const Text(
                        "No hay resultados para esta matrícula",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Matrícula')),
                            DataColumn(label: Text('Carrera')),
                            DataColumn(label: Text('Porcentaje')),
                          ],
                          rows: filteredData
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