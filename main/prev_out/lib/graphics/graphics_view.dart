import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';
class GraphicsApp extends StatelessWidget {
  const GraphicsApp({super.key});

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255), // Color de fondo de toda la página
      appBar:const CustomAppBar(),
      body: ListView(
        children: [
          contenido(context),
        ],
      ),
    );
  }
}
   Widget contenido(context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            bar(),
            lista(context),
          ],
        ),
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
        'Gráficas',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


Widget lista(BuildContext context) {
  return Container(
    child: Container(
        width: double.infinity, // Ocupar todo el espacio horizontal// Ocupar todo el espacio vertical
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Wrap(
            spacing: 14, // Espacio horizontal entre tarjetas
            runSpacing: 14, // Espacio vertical entre tarjetas
            children: const [
              Graphics(titulo: "grafica de barra 1", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "grafica de barra 2", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "grafica de barra 3", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "grafica de barra 1", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "grafica de barra 2", fcolor: Color(0xffFFE5E5)),
              Graphics(titulo: "grafica de barra 3", fcolor: Color(0xffFFE5E5)),
            ],
          ),
        ),
    ),
  );
}



class Graphics extends StatelessWidget {
  final String titulo;
  final Color fcolor;

  const Graphics({
    Key? key,
    required this.titulo,
    required this.fcolor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 365, // Ajusta el ancho de Graphics
      height: 200, // Ajusta la altura de Graphics
      child: Container(
        decoration: BoxDecoration(
          color: fcolor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}