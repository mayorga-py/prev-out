import 'package:flutter/material.dart';
import 'graphics_view.dart';


class GraphicsApp extends StatelessWidget {
  const GraphicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home',
      home: const CombinedWidget(),
    );
  }
}