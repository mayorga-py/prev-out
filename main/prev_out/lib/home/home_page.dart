import 'package:flutter/material.dart';
import 'package:prev_out/home/views/home_view.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home',
      home: const CombinedWidget(),
    );
  }
}