import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchChatGPTReply(String message) async {
  // TODO: Não deixar a API hardcoded aqui
  const apiKey = 'API-HERE'; // Replace with your key
  const endpoint = 'https://api.openai.com/v1/chat/completions';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'model': 'gpt-3.5-turbo',
    'messages': [
      {'role': 'system', 'content': 'You are a helpful assistant.'},
      {'role': 'user', 'content': message},
    ],
  });

  final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];
    return content.trim();
  } else {
    print('Failed to fetch ChatGPT reply: ${response.body}');
    return "Sorry, I couldn't get a response.";
  }
}
