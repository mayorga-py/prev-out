import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';
import 'package:flutter/services.dart';

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
          const Color.fromARGB(255, 255, 255, 255), // Color de fondo de toda la página
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          contenido(context),
        ],
      ),
    );
  }
}


  Widget contenido(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          bar(),
          lista(context),
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
        'Manual de uso',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

Widget lista(BuildContext context) {
  return Container(
    color: const Color.fromARGB(255, 255, 255, 255), // Color de fondo de toda la página
    margin: const EdgeInsets.all(8),
    child: Center(
      child: Container(
        width: 1445, // Ocupar todo el espacio horizontal
        height: MediaQuery.of(context).size.height, // Ocupar todo el espacio vertical
        decoration: BoxDecoration(
          color: Color (0xffFFE5E5), // Color del card
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
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Center(
            child: CodeBox(
              code: '''
  void main() {
  print('Hola, Mundo!')
                  =
                  =
                  =
                  =
                  0
                  0
                  0
                  0
                  0
                  
                  0
                  0;
                }
              ''',
            ),
          ),
        ),
      ),
    ),
  );
}

class CodeBox extends StatelessWidget {
  final String code;

  CodeBox({required this.code});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0, // Ajusta el ancho según lo necesites
      height: 200.0, // Ajusta la altura según lo necesites
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Código copiado al portapapeles')),
                );
              },
              child: Text('Copiar Código'),
            ),
          ],
        ),
      ),
    );
  }
}
