import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';

class ListApp extends StatelessWidget {
  const ListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CombinedWidget(),
    );
  }
}

class CombinedWidget extends StatefulWidget {
  const CombinedWidget({super.key});

  @override
  State<CombinedWidget> createState() => _CombinedWidgetState();
}

class _CombinedWidgetState extends State<CombinedWidget> {
  final Map<String, bool> selectedOptions = {
    'Matrícula': false,
    'Carrera': false,
    'Cuatrimestre': false,
    'Estado': false,
  };

  String? selectedCarrera;
  final List<String> carreras = [
    'ING. Sistemas Computacionales',
    'ING. Manufactura',
    'LIC. Administración y gestión Empresarial',
    'LIC. Negocios Internacionales',
    'ING. Tecnología Automotriz',
    'ING. Redes y Telecomunicaciones',
    'ING. Mecatronica',
    'ING. De Datos',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 255, 255, 255), // Color de fondo de toda la página
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          contenido(),
        ],
      ),
    );
  }

//Barra con nombre de la pagina
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
        'Listado de alumnos',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget contenido() {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            bar(),
            lista(),
          ],
        ),
      ),
    );
  }

  Widget lista() {
    return Container(
      color: const Color.fromARGB(
          255, 255, 255, 255), // Color de fondo de toda la página
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Container(
          width: 1445, // Ocupar todo el espacio horizontal
          height: MediaQuery.of(context)
              .size
              .height, // Ocupar todo el espacio vertical
          decoration: BoxDecoration(
            color: Color(0xffFFE5E5), // Color del card
            borderRadius: BorderRadius.circular(13.0), // Bordes redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3), // Cambia la posición de la sombra
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(11.0),
            child: Text('Aquí debe de ir la lista de alumnos'),
          ),
        ),
      ),
    );
  }
}
