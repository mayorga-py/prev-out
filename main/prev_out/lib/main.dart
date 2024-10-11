import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prev_out/firebase_options.dart';
import 'login/widgets/login_page.dart';
import 'home/home_page.dart';
import 'package:desktop_window/desktop_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Asegúrate de tener la configuración correcta en firebase_options.dart
  );

  // Establecer el tamaño mínimo de la ventana (solo relevante para aplicaciones de escritorio)
  await DesktopWindow.setMinWindowSize(const Size(1280, 720));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomeView(),
        '/login': (context) => LoginView(), // Elimina el const ya que LoginView tiene controladores de texto
      },
    );
  }
}
