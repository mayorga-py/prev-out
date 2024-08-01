import 'package:flutter/material.dart';
import 'login/widgets/login_page.dart';
import 'home/home_page.dart';
import 'package:desktop_window/desktop_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Establecer el tamaño mínimo de la ventana
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
        '/login': (context) => const LoginView(),
      },
    );
  }
}
