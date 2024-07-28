import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';

class FilesUpload extends StatelessWidget {
  const FilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(),
        body: Stack(
          children: [
            fondo(),
            menu(),
            archivos(),
            nuevoUsuario(context),
            usuarios(),
          ],
        ));
  }

  Widget fondo() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xffFFE5E5)),
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
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            child: Text(
              'Añade el archivo a utilizar',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 100,
            left: 5, // Cambiado para evitar superposición
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xffffffff),
              ),
              width: 200,
              height: 30,
            ),
          ),
          Positioned(
            top: 100,
            left: 250,
            child: botonSubir(),
          ),
          const Positioned(
            top: 200,
            left: 0,
            child: Text(
              'Historial de archivos',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
          ),
          const Positioned(
            top: 250,
            left: 0,
            child: Text(
              'Nombre',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
          const Positioned(
            top: 250,
            left: 300,
            child: Text(
              'Fecha',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget nuevoUsuario(BuildContext context) {
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
                    )),
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
                      )),
                ),
              )),
          Positioned(bottom: 10, right: 10, child: botonAdd(context))
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
      onPressed: () {},
      child: const Text(
        'Subir',
        style: TextStyle(color: Color(0xffffffff)),
      ),
    );
  }

  Widget botonAdd(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xff0D00A4))),
        onPressed: () {
          Navigator.pushNamed(context, '/guide');
        },
        child: const Text(
          'Añadir',
          style: TextStyle(color: Color(0xffffffff)),
        ));
  }
}
