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
      backgroundColor: const Color(0xffFFE5E5), // Color de fondo de toda la página
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          contenido(),
        ],
      ),
    );
  }

  Widget contenido() {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            //checklist(),
            lista(),
          ],
        ),
      ),
    );
  }

  Widget checklist() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffF5BCBA), // Color del card
              borderRadius: BorderRadius.circular(7.0), // Bordes redondeados
            ),
            child: Row(
              children: selectedOptions.keys.map((String key) {
                List<Widget> children = [];
                children.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Checkbox(
                      value: selectedOptions[key],
                      onChanged: (bool? newValue) {
                        setState(() {
                          selectedOptions[key] = newValue!;
                        });
                      },
                    ),
                  ),
                );

                if (key == 'Carrera') {
                  children.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: DropdownButton<String>(
                        value: selectedCarrera,
                        hint: Text(key),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCarrera = newValue;
                          });
                        },
                        items: carreras.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                } else {
                  children.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(key),
                    ),
                  );
                }

                return Row(children: children);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget lista() {
    return Container(
      color: const Color(0xffFFE5E5), // Color de fondo de toda la página
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Container(
          width: double.infinity, // Ocupar todo el espacio horizontal
          height: MediaQuery.of(context).size.height, // Ocupar todo el espacio vertical
          decoration: BoxDecoration(
            color: Colors.white, // Color del card
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
