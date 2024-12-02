
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
          const Color.fromARGB(255, 255, 255, 255), // Color de fondo de toda la página
      appBar: const CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
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
          bar(),
          lista(),
          dashboardSection(),
          studentsListSection(),
          filesSection(),
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










  
 Widget lista() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2, // El espacio que ocupa el texto
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 100, right: 100),
                child: homeScreen(), // Nuevo widget para el texto
              ),
            ),
            Expanded(
              flex: 1, // El espacio que ocupa la imagen
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 80),
                child: imageHomeScreen(), // Widget de la imagen separado
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nueva sección para el Dashboard
  Widget dashboardSection() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2, // El espacio que ocupa el texto
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 100, right: 100),
                child: dashboard(), // Nuevo widget para el texto del Dashboard
              ),
            ),
            Expanded(
              flex: 1, // El espacio que ocupa la imagen
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 80),
                child: imageDashboard(), // Reutilizamos el widget de la imagen
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget studentsListSection() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2, // El espacio que ocupa el texto
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 100, right: 100),
                child:
                    studentsList(), // Nuevo widget para el texto del Dashboard
              ),
            ),
            Expanded(
              flex: 1, // El espacio que ocupa la imagen
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 80),
                child:
                    imageStudentsList(), // Reutilizamos el widget de la imagen
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filesSection() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2, // El espacio que ocupa el texto
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 100, right: 100),
                child: files(), // Nuevo widget para el texto del Dashboard
              ),
            ),
            Expanded(
              flex: 1, // El espacio que ocupa la imagen
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 80),
                child: imageFiles(), // Reutilizamos el widget de la imagen
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        homeScreenTitle(), // Llamada al widget del título
        const SizedBox(height: 20), // Espacio entre título y descripción
        descriptionHomeScreen(), // Llamada al widget de la descripción
      ],
    );
  }

  Widget dashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dashboardTitle(), // Título del Dashboard
        const SizedBox(height: 20), // Espacio entre título y descripción
        descriptionDashboard(), // Descripción del Dashboard
      ],
    );
  }

  Widget studentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        studentsListTitle(), // Título del Dashboard
        const SizedBox(height: 20), // Espacio entre título y descripción
        descriptionStudentsList(), // Descripción del Dashboard
      ],
    );
  }

  Widget files() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filesTitle(), // Título del Dashboard
        const SizedBox(height: 20), // Espacio entre título y descripción
        descriptionFiles(), // Descripción del Dashboard
      ],
    );
  }

  Widget graphics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filesTitle(), // Título del Dashboard
        const SizedBox(height: 20), // Espacio entre título y descripción
        descriptionFiles(), // Descripción del Dashboard
      ],
    );
  }

  Widget homeScreenTitle() {
    return const Text(
      'Pantalla de inicio',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget dashboardTitle() {
    return const Text(
      'Dashboard',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget studentsListTitle() {
    return const Text(
      'Listado de alumnos',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget filesTitle() {
    return const Text(
      'Archivos',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget graphicsTitle() {
    return const Text(
      'Archivos',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget descriptionHomeScreen() {
    return const Text(
      'La aplicación nos recibe con un inicio de sesión. El perfil del Administrador tiene la función de que puede agregar un nuevo usuario o puede borrarlos. En el perfil de Usuario, por ahora, tiene todas las funcionalidades del Administrador, salvo que no puede agregar o eliminar usuarios.',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  // Nueva descripción para el Dashboard
  Widget descriptionDashboard() {
    return const Text(
      'El Dashboard proporciona una visión general de todas las cosas que puede hacer, por ejemplo: ver el listado de los alumnos; subir archivos excel; mostrar los datos en forma de gráficas; y por último, un manual de uso. En la parte superior se puede buscar un alumno directamente por su matrícula derecha; a lado de este hay un ícono de usuario que es para cerrar la sesión',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  Widget descriptionStudentsList() {
    return const Text(
      'En la sección de Listado de Alumnos, se muestra información detallada de cada estudiante, incluyendo su matrícula, carrera, cuatrimestre y su estado actual dentro de la institución, indicando si está activo o inactivo.',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  Widget descriptionFiles() {
    return const Text(
      'En esta sección, se podrán subir los archivos Excel previamente depurados para enviarlos a la API, la cual se encargará de procesarlos y generar predicciones sobre cuáles alumnos tienen mayor probabilidad de darse de baja en la institución. Además, se incluye una opción para agregar nuevos usuarios, asignándoles un rol, ya sea de Administrador o Usuario. Por último, se presenta un listado de los usuarios activos, donde el Administrador tendrá la capacidad de eliminar usuarios si es necesario.',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  Widget descriptionGraphics() {
    return const Text(
      'En esta sección, se podrán subir los archivos Excel previamente depurados para enviarlos a la API, la cual se encargará de procesarlos y generar predicciones sobre cuáles alumnos tienen mayor probabilidad de darse de baja en la institución. Además, se incluye una opción para agregar nuevos usuarios, asignándoles un rol, ya sea de Administrador o Usuario. Por último, se presenta un listado de los usuarios activos, donde el Administrador tendrá la capacidad de eliminar usuarios si es necesario.',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  Widget imageHomeScreen() {
    return Container(
      width: 400,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/foto_manual_1.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget imageDashboard() {
    return Container(
      width: 400,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/foto_manual_2.jpg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget imageStudentsList() {
    return Container(
      width: 400,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/foto_manual_3.jpg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget imageFiles() {
    return Container(
      width: 400,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/foto_manual_4.jpg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget imageGraphics() {
    return Container(
      width: 400,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/foto_manual_4.webp',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

