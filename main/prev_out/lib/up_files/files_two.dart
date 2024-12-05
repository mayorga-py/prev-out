import 'dart:io';
import 'dart:async'; // Para usar Stream y listeners
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:prev_out/appbar.dart';

class FilesUpload extends StatefulWidget {
  const FilesUpload({super.key});

  @override
  _FilesUploadState createState() => _FilesUploadState();
}

class _FilesUploadState extends State<FilesUpload> {
  List<String> fileNames = [];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserRole;
  String _selectedRole = 'user'; // Default role

  String? _selectedFilePath;
  String _predictionResult = "";

  // Ruta del directorio a monitorear
  final String _watchDirectory = '/ruta/a/tu/directorio';

  // StreamSubscription para escuchar cambios en el directorio
  StreamSubscription<FileSystemEvent>? _directorySubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentUserRole();
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

  // Obtener el rol del usuario actual
  Future<void> _getCurrentUserRole() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();
      setState(() {
        currentUserRole = userDoc['role'];
      });
    }
  }

  // Subir archivo y realizar predicción
  Future<void> _uploadAndPredict(String filePath) async {
    var uri =
        Uri.parse('http://127.0.0.1:5001/predict'); // Cambia a la URL de tu API
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

  // Comprobar si el usuario tiene rol de administrador
  Future<bool> _isAdmin() async {
    if (currentUserRole == null) {
      await _getCurrentUserRole();
    }
    return currentUserRole == 'admin';
  }

  // Selección de archivo
  Future<void> _pickFile() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          Stack(
            children: [
              bar(),
              archivos(),
              if (currentUserRole == 'admin') nuevoUsuario(),
              if (currentUserRole == 'admin') usuarios(),
            ],
          ),
        ],
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
        'Archivos',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget archivos() {
    return Container(
      margin: const EdgeInsets.only(top: 70, left: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text("Seleccionar archivo"),
          ),
          if (_selectedFilePath != null)
            Text("Archivo seleccionado: ${path.basename(_selectedFilePath!)}"),
          ElevatedButton(
            onPressed: () => _uploadAndPredict(_selectedFilePath!),
            child: const Text("Subir y predecir"),
          ),
          if (_predictionResult.isNotEmpty)
            Text("Resultado de la predicción: $_predictionResult"),
        ],
      ),
    );
  }

  Widget nuevoUsuario() {
    return Container(
      width: 725,
      height: 290, // Aumentamos el tamaño para acomodar el nuevo campo
      margin: const EdgeInsets.only(top: 80, left: 775, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 213, 213),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          const Text(
            'Añadir nuevo usuario',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned(
            top: 60,
            left: 10,
            child: SizedBox(
              width: 500,
              height: 40,
              child: TextField(
                controller: _emailController,
                style: const TextStyle(
                  fontSize: 12,
                ),
                decoration: const InputDecoration(
                  hintText: 'Correo',
                  fillColor: Color.fromARGB(0, 255, 255, 255),
                  filled: true,
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 10,
            child: SizedBox(
              width: 250,
              height: 40,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 12,
                ),
                decoration: const InputDecoration(
                  hintText: 'Contraseña',
                  fillColor: Color.fromARGB(0, 255, 255, 255),
                  filled: true,
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: 10,
            child: Row(
              children: [
                const Text('Rol: '),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: <String>['user', 'admin'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Positioned(bottom: 10, right: 10, child: botonAdd()),
        ],
      ),
    );
  }

  Widget usuarios() {
    return Container(
      width: 725,
      height: 290,
      margin: const EdgeInsets.only(top: 390, left: 775, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 213, 213),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usuarios',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder(
            future: _firestore.collection('usuarios').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return const Text('No se encontraron usuarios');
              }
              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map<Widget>((doc) {
                  return ListTile(
                    title: Text(doc['email']),
                    subtitle: Text('Rol: ${doc['role']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _firestore
                            .collection('usuarios')
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget botonAdd() {
    return ElevatedButton(
      onPressed: () async {
        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
          return;
        }
        await _createUser();
      },
      child: const Text('Añadir usuario'),
    );
  }

  Future<void> _createUser() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).set({
        'email': _emailController.text,
        'role': _selectedRole,
      });

      setState(() {
        _emailController.clear();
        _passwordController.clear();
      });
    } catch (e) {
      print("Error creando usuario: $e");
    }
  }
}
