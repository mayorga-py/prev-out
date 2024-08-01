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
          const Color(0xffFFE5E5), // Color de fondo de toda la página
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
          checklist(),
          lista(context),
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
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget lista(BuildContext context) {
  return Container(
    color: const Color(0xffFFE5E5), // Color de fondo de toda la página
    margin: const EdgeInsets.all(8),
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
