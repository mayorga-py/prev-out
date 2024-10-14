import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';

class GuideApp extends StatelessWidget {
  const GuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CombinedWidget(),
    );
  }
}

class CombinedWidget extends StatefulWidget {
  const CombinedWidget({super.key});

  @override
  State<CombinedWidget> createState() => _CombinedWidgetState();
}

class _CombinedWidgetState extends State<CombinedWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFE5E5), // Color de fondo de toda la página
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          contenido(),
        ],
      ),
    );
  }

  Widget contenido() {
    return Center(
      child: Column(
        children: <Widget>[
          checklist(),
          lista(),
        ],
      ),
    );
  }

  Widget checklist() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffF5BCBA), // Color del card
            borderRadius: BorderRadius.circular(7.0), // Bordes redondeados
          ),
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Manual de uso',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff000000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget lista() {
    return Container(
      color: const Color(0xffFFE5E5), // Color de fondo de toda la página
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context)
                  .size
                  .height, // Ocupar todo el espacio vertical
              decoration: BoxDecoration(
                color: Colors.white, // Color del card
                borderRadius: BorderRadius.circular(13.0), // Bordes redondeados
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset:
                        const Offset(0, 3), // Cambia la posición de la sombra
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 80, right: 800, top: 100),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alineación a la izquierda
                  children: [
                    Text(
                      'Pantalla de inicio',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20), // Añade espacio entre los textos
                    Text(
                      'La aplicación nos recibe con un inicio de sesión. El perfil del Administrador tiene la función de que puede agregar un nuevo usuario o puede borrarlos. En el perfil de Usuario, por ahora, tiene todas las funcionalidades del Administrador, salvo que no puede agregar o eliminar usuarios.',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 90,
              child: imagen(), // Aquí se inserta la imagen
            ),
          ],
        ),
      ),
    );
  }

  Widget imagen() {
    return Container(
      width: 700,
      height: 300,
      alignment: Alignment.topRight,
      child: Image.asset(
        'assets/images/foto_manual_1.webp',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget titleHomeScreen() {
    return const Text(
      'Pantalla de inicio',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget textHomeScreen() {
    return const Text(
      'La aplicación nos recibe con un inicio de sesión. El perfil del Administrador tiene la función de que puede agregar un nuevo usuario o puede borrarlos. En el perfil de Usuario, por ahora, tiene todas las funcionalidades del Administrador, salvo que no puede agregar o eliminar usuarios.',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }
}
