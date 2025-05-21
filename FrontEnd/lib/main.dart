import 'package:flutter/material.dart';
import 'chat_widget.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Text('Hello World!'),
            ),
            ChatWidget(), // 👈 Componente do chat bot, para utilizar ele pode ser importado no projeto principal
          ],
        ),
      ),
    );
  }
}
