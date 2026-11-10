import 'package:flutter/material.dart';
import "map_page.dart";

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们'), elevation: 1),
      body: const AddMapPage(),
    );
  }
}
