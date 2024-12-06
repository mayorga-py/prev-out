import 'dart:async'; // Para usar Stream y listeners
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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



  @override
  void initState() {
    super.initState();
    _getCurrentUserRole();
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

  // Comprobar si el usuario tiene rol de administrador
  Future<bool> _isAdmin() async {
    if (currentUserRole == null) {
      await _getCurrentUserRole();
    }
    return currentUserRole == 'admin';
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

  Widget nuevoUsuario() {
  const TextStyle commonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  const TextStyle boldTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  return Container(
    width: 1450,
    height: 290, // Aumentamos el tamaño para acomodar el nuevo campo
    margin: const EdgeInsets.only(top: 80, left: 45, right: 20),
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
              style: commonTextStyle,
              decoration: const InputDecoration(
                hintText: 'Correo',
                fillColor: Color.fromARGB(0, 255, 255, 255),
                filled: true,
                hintStyle: commonTextStyle,
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
              style: commonTextStyle,
              decoration: const InputDecoration(
                hintText: 'Contraseña',
                fillColor: Color.fromARGB(0, 255, 255, 255),
                filled: true,
                hintStyle: commonTextStyle,
              ),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: 10,
          child: Row(
            children: [
              const Text('Rol:', style: commonTextStyle),
              DropdownButton<String>(
                value: _selectedRole,
                items: <String>['user', 'admin'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role, style: boldTextStyle), // Opciones en negritas
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
    width: 1450,
    height: 290,
    margin: const EdgeInsets.only(top: 390, left: 45, right: 20),
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
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('usuarios').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No se encontraron usuarios');
            }

            final docs = snapshot.data!.docs;
            return Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return ListTile(
                    title: Text(doc['email']),
                    subtitle: Text('Rol:  ${doc['role']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _firestore.collection('usuarios').doc(doc.id).delete();
                      },
                    ),
                  );
                },
              ),
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
