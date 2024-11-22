import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xffFFF5F5),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Verifica si la ruta actual es la home
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'PREV-OUT',
              style: TextStyle(
                fontSize: 28,
                color: Color(0xff002D72),
              ),
            ),
          ),
          Container(
            width: 400, // Ajusta el ancho según tus necesidades
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Inserta una matrícula para buscar',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Color.fromARGB(255, 80, 74, 74),
              size: 40,
            ),
            onSelected: (String result) async {
              if (result == 'logout') {
                // Cerrar sesión de Firebase Auth
                await FirebaseAuth.instance.signOut();

                // Redirigir al login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
                );
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Color(0xffBA0C2F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
