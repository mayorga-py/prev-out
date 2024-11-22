import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
                    botonOlvideContrasena(context), // Modificado
                    const SizedBox(height: 130),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: botonEntrar(context),
                      ),
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
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

  Widget botonOlvideContrasena(BuildContext context) {
    return TextButton(
      style: const ButtonStyle(alignment: Alignment.bottomCenter),
      onPressed: () async {
        String email = _emailController.text;

        if (email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Por favor ingresa tu correo electrónico"),
            ),
          );
          return;
        }

        try {
          await _auth.sendPasswordResetEmail(email: email);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Correo de restablecimiento de contraseña enviado"),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al enviar el correo: ${e.toString()}"),
            ),
          );
        }
      },
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
        backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff002D72)),
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15.0)),
        alignment: Alignment.bottomRight,
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
      onPressed: () async {
        String email = _emailController.text;
        String password = _passwordController.text;

        try {
          // ignore: unused_local_variable
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          Navigator.pushNamed(context, '/home');
        } catch (e) {
          // Manejar errores de inicio de sesión aquí
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al iniciar sesión: ${e.toString()}"),
            ),
          );
        }
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
