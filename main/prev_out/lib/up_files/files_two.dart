import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prev_out/appbar.dart';
import 'package:file_picker/file_picker.dart';
// ignore: unused_import
import 'package:path/path.dart' as path;
import 'dart:io';



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

  @override
  void initState() {
    super.initState();
    _getCurrentUserRole();
    _listFiles(); // Listar los archivos al iniciar
  }


void _listFiles() {
  final directory = Directory(
      r'C:\Users\Oswaldo Larrinaga\Desktop\prev-out\main\prev_out\app\services\uploads');

  if (directory.existsSync()) {
    setState(() {
      fileNames = directory
          .listSync()
          .where((item) => item is File)
          .map((item) => path.basename(item.path))
          .toList()
          .cast<String>();
    });
  }
}


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

  Future<bool> _isAdmin() async {
    if (currentUserRole == null) {
      await _getCurrentUserRole();
    }
    return currentUserRole == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFE5E5),
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          Stack(
            children: [
              menu(),
              archivos(),
              if (currentUserRole == 'admin') nuevoUsuario(),
              if (currentUserRole == 'admin') usuarios(),
            ],
          ),
        ],
      ),
    );
  }

  Widget menu() {
    return Container(
      width: double.infinity,
      height: 30,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xffFFC1CC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Archivos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  

  Widget nuevoUsuario() {
    return Container(
      width: 500,
      height: 300, // Aumentamos el tamaño para acomodar el nuevo campo
      margin: const EdgeInsets.only(top: 90, left: 800, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffF0D2D1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          const Text(
            'Añadir nuevo usuario',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned(
            top: 60,
            left: 10,
            child: SizedBox(
              width: 250,
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
      width: 500,
      height: 250,
      margin: const EdgeInsets.only(top: 390, left: 800, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffF0D2D1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usuarios Registrados',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final users = snapshot.data!.docs;
                List<Widget> userWidgets = [];
                for (var user in users) {
                  final userEmail = user['email'];
                  final userUid = user.id;
                  final userRole = user['role'];

                  final userWidget = ListTile(
                    title: Text('$userEmail - $userRole'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _eliminarUsuario(userUid);
                      },
                    ),
                  );
                  userWidgets.add(userWidget);
                }
                return ListView(
                  children: userWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarUsuario(String uid) async {
  try {
    // Obtener la referencia del usuario en FirebaseAuth
    User? userToDelete = await _auth.getUser(uid);

    // Verificar si el usuario existe en FirebaseAuth
    if (userToDelete != null) {
      // Eliminar al usuario de FirebaseAuth
      await userToDelete.delete();
    }

    // Eliminar el documento del usuario de Firestore
    await _firestore.collection('usuarios').doc(uid).delete();

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuario eliminado exitosamente'),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al eliminar el usuario: $e'),
      ),
    );
  }
}

  Widget archivos() {
  return Container(
    width: 700,
    height: 550,
    margin: const EdgeInsets.only(top: 90, left: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xffF0D2D1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Añade el archivo a utilizar',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xffffffff),
              ),
              width: 200,
              height: 30,
            ),
            const SizedBox(width: 20),
            botonSubir(),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          'Historial de archivos',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: fileNames.length,
            itemBuilder: (context, index) {
              return Text(fileNames[index]);
            },
          ),
        ),
      ],
    ),
  );
}

Widget botonSubir() {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(const Color(0xff0D00A4)),
    ),
    onPressed: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        // Ruta de la carpeta de destino
        final directory = Directory(
            r'C:\Users\Oswaldo Larrinaga\Desktop\prev-out\main\prev_out\app\services\uploads');

        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        // Guardar el archivo en la carpeta de destino
        final File newFile = await file.copy('${directory.path}/$fileName');

        // Actualizar la lista de archivos
        setState(() {
          fileNames.add(newFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo subido exitosamente'),
          ),
        );
      } else {
        // El usuario canceló la selección del archivo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se seleccionó ningún archivo'),
          ),
        );
      }
    },
    child: const Text(
      'Subir',
      style: TextStyle(color: Colors.white),
    ),
  );
}



  Widget botonAdd() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xff0D00A4)),
      ),
      onPressed: () async {
        final String email = _emailController.text;
        final String password = _passwordController.text;
        final String role = _selectedRole;

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, complete todos los campos'),
            ),
          );
          return;
        }

        try {
          final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Agregar el usuario con el rol a Firestore
          await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
            'email': email,
            'role': role,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario añadido exitosamente'),
            ),
          );

          // Limpiar los campos después de crear el usuario
          _emailController.clear();
          _passwordController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al añadir el usuario: $e'),
            ),
          );
        }
      },
      child: const Text(
        'Añadir',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

extension on FirebaseAuth {
  getUser(String uid) {}
}
