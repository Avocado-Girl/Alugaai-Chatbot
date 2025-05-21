import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchBotReply(String message) async {
  const url = 'http://localhost:5000/chat'; // Altere se for para produção

  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"message": message}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['reply'] ?? "Desculpe, não entendi.";
  } else {
    return "Erro na comunicação com o servidor.";
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool _isChatOpen = false;
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _initializeBotMessage() {
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(_ChatMessage(text: "Olá! Sou o assistente virtual do Alugaai. Como posso ajudar você hoje?", isUser: false));
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
    });

    _scrollToBottom();

    final botReply = await fetchBotReply(text);

    setState(() {
      _messages.add(_ChatMessage(text: botReply, isUser: false));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botão do chat
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isChatOpen = !_isChatOpen;
              });

              if (_isChatOpen) {
                _initializeBotMessage(); 
              }
            },
            child: Icon(_isChatOpen ? Icons.close : Icons.chat),
          ),
        ),

        // Janela do chat
        if (_isChatOpen)
          Positioned(
            bottom: 80,
            right: 20,
            child: _buildChatWindow(),
          ),
      ],
    );
  }

  Widget _buildChatWindow() {
    return Container(
      width: 300,
      height: 400,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Column(
        children: [
          // Header com botão de fechar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Chat Bot", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isChatOpen = false;
                  });
                },
              )
            ],
          ),
          const Divider(),

          // Lista de mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),

          // Input de texto
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Escreva uma mensagem...",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}

// Classe de mensagens internas
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
