import 'package:flutter/material.dart';
import 'package:prev_out/appbar.dart';

void main() {
  runApp(const GuideApp());
}

class GuideApp extends StatelessWidget {
  const GuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home',
      home: CombinedWidget(),
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
                      fontWeight: FontWeight.bold),
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
        child: Container(
          width: double.infinity, // Ocupar todo el espacio horizontal
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
                offset: const Offset(0, 3), // Cambia la posición de la sombra
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas interdum, erat at pulvinar facilisis, mauris velit ullamcorper sem, eu commodo leo est ac ipsum. Mauris et justo condimentum urna iaculis tempor. Sed pretium porta sem id bibendum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi tincidunt purus porttitor, aliquam justo sed, vehicula turpis. Suspendisse vitae tincidunt diam, et iaculis velit. Nam at nisi odio. Quisque laoreet accumsan fringilla. Integer rutrum ipsum condimentum, elementum metus non, commodo libero. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas interdum, erat at pulvinar facilisis, mauris velit ullamcorper sem, eu commodo leo est ac ipsum. Mauris et justo condimentum urna iaculis tempor. Sed pretium porta sem id bibendum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi tincidunt purus porttitor, aliquam justo sed, vehicula turpis. Suspendisse vitae tincidunt diam, et iaculis velit. Nam at nisi odio. Quisque laoreet accumsan fringilla. Integer rutrum ipsum condimentum, elementum metus non, commodo libero. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas interdum, erat at pulvinar facilisis, mauris velit ullamcorper sem, eu commodo leo est ac ipsum. Mauris et justo condimentum urna iaculis tempor. Sed pretium porta sem id bibendum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi tincidunt purus porttitor, aliquam justo sed, vehicula turpis. Suspendisse vitae tincidunt diam, et iaculis velit. Nam at nisi odio. Quisque laoreet accumsan fringilla. Integer rutrum ipsum condimentum, elementum metus non, commodo libero.',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
