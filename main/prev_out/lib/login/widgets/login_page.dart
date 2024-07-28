import 'dart:ui';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          fondo(),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 450,
                height: 650,
                color: const Color.fromARGB(186, 241, 228, 232),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    nombre(),
                    const SizedBox(height: 90),
                    login(),
                    campoUsuario(),
                    campoContrasena(),
                    botonOlvideContrasena(),
                    const SizedBox(height: 130),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: botonEntrar(context),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nombre() {
    return const Text(
      "PREV-OUT",
      style: TextStyle(
        color: Color(0xff002D72),
        fontSize: 55.0,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget login() {
    return const Text(
      "LOGIN",
      style: TextStyle(
        color: Color(0xffBA0C2F),
        fontSize: 25.0,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget campoUsuario() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Usuario",
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget campoContrasena() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Contraseña",
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget botonOlvideContrasena() {
    return TextButton(
      style: const ButtonStyle(alignment: Alignment.bottomCenter),
      onPressed: () {},
      child: const Text(
        'Olvidé mi contraseña',
        style: TextStyle(
            fontSize: 15,
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blueAccent),
      ),
    );
  }

  Widget botonEntrar(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>(const Color(0xff002D72)),
        padding:
            WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(15.0)),
        alignment: Alignment.bottomRight,
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/home');
      },
      child: const Text(
        'Continuar',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget fondo() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login-img.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
