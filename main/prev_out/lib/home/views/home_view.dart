import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';
import 'package:prev_out/up_files/files_two.dart';
import 'package:prev_out/graphics/graphics_view.dart';
import 'package:prev_out/guide/guide_view.dart';
import 'package:prev_out/list/list_view.dart';

class CombinedWidget extends StatefulWidget {
  const CombinedWidget({super.key});

  @override
  _CombinedWidgetState createState() => _CombinedWidgetState();
}

class _CombinedWidgetState extends State<CombinedWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: ListView(
        children: [
          cuerpo(context),
        ],
      ),
    );
  }
}

Widget cuerpo(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Column(
        children: [
          dashboard(context),
        ],
      ),
    ),
  );
}

Widget dashboard(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(8),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: CardsD(
                  tipocard: 'LISTADO DE ALUMNOS',
                  ecolor: Color(0xffF5BCBA),
                  tboton: '',
                  imageUrl: null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListApp()),
                    );
                  },
                  height: 360,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: CardsD( 
                        tipocard: 'USUARIOS',
                        ecolor: Color(0xffF47E1C),
                        tboton: '',
                        imageUrl: null,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FilesUpload()),
                          );
                        },
                        height: 290,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: CardsD(
                        tipocard: 'MOSTRAR DATOS EN GRAFICAS',
                        ecolor: Color(0xff9DB0CE),
                        tboton: '',
                        imageUrl: null,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GraphicsApp()),
                          );
                        },
                        height: 290,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2, // Se ha cambiado flex de 1 a 2
                fit: FlexFit.loose,
                child: CardsD(
                  tipocard: 'MANUAL DE USO',
                  ecolor: Color.fromARGB(218, 135, 9, 9),
                  tboton: '',
                  imageUrl: null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuideApp()),
                    );
                  },
                  height: 670, // Ajuste de altura
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CardsD extends StatelessWidget {
  final String tipocard;
  final Color ecolor;
  final String tboton;
  final String? imageUrl;
  final double height;
  final double? imageHeight; // Altura de la imagen
  final double? imageWidth; // Ancho de la imagen
  final VoidCallback onPressed;

  const CardsD({
    Key? key,
    required this.tipocard,
    required this.ecolor,
    required this.tboton,
    this.imageUrl,
    required this.height,
    this.imageHeight,
    this.imageWidth,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: ecolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  tipocard,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (imageUrl != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: imageUrl!.startsWith('http')
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: imageWidth ?? double.infinity,
                            height: imageHeight ?? 150,
                          )
                        : Image.asset(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: imageWidth ?? double.infinity,
                            height: imageHeight ?? 150,
                          ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    tboton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
