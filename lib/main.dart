
import 'package:flutter/material.dart';

import 'ui/screens/catalog_screen.dart';

void main() {
  runApp(const Hw3App());
}

class Hw3App extends StatelessWidget {
  const Hw3App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CatalogScreen(),
    );
  }
}
