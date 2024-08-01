import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Necesario para manejar archivos

class FilesUpload extends StatefulWidget {
  const FilesUpload({super.key});

  @override
  _FilesUploadState createState() => _FilesUploadState();
}

class _FilesUploadState extends State<FilesUpload> {
  List<String> fileNames = [];

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
              nuevoUsuario(),
              usuarios(),
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

  Widget nuevoUsuario() {
    return Container(
      width: 500,
      height: 250,
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
          const Positioned(
            top: 60,
            left: 10,
            child: SizedBox(
              width: 250,
              height: 40,
              child: TextField(
                style: TextStyle(
                  fontSize: 12,
                ),
                decoration: InputDecoration(
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
          const Positioned(
            top: 120,
            left: 10,
            child: SizedBox(
              width: 250,
              height: 40,
              child: TextField(
                obscureText: true,
                style: TextStyle(
                  fontSize: 12,
                ),
                decoration: InputDecoration(
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
      child: const Text(
        'Usuarios',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget botonSubir() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xff0D00A4)),
      ),
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          setState(() {
            fileNames.add(result.files.single.name);
          });
          File file = File(result.files.single.path!);
          // Maneja el archivo seleccionado
          file;
        } else {
          FilePickerResult? multipleResults =
              await FilePicker.platform.pickFiles(allowMultiple: true);

          if (multipleResults != null) {
            setState(() {
              fileNames.addAll(multipleResults.files.map((file) => file.name));
            });
            List<File> files =
                multipleResults.paths.map((path) => File(path!)).toList();
            // Maneja los archivos seleccionados
            files;
          } else {
            FilePickerResult? customResults =
                await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'png', 'pdf', 'doc'],
            );

            if (customResults != null) {
              setState(() {
                fileNames.addAll(customResults.files.map((file) => file.name));
              });
              // Maneja los archivos seleccionados con extensiones personalizadas
            }
          }
        }
      },
      child: const Text(
        'Subir',
        style: TextStyle(color: Color(0xffffffff)),
      ),
    );
  }

  Widget botonAdd() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xff0D00A4)),
      ),
      onPressed: () {},
      child: const Text(
        'Añadir',
        style: TextStyle(color: Color(0xffffffff)),
      ),
    );
  }
}
