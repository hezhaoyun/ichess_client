import 'package:flutter/material.dart';

class OpeningExplorerPage extends StatefulWidget {
  const OpeningExplorerPage({super.key});

  @override
  State<OpeningExplorerPage> createState() => _OpeningExplorerPageState();
}

class _OpeningExplorerPageState extends State<OpeningExplorerPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Opening Explorer')),
    );
  }
}
