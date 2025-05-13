import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gardening_assistant/core/env.dart';

class GeminiService {
  final String _apiKey = Env.geminiApiKey;
  final String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${Env.geminiApiKey}";

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception("API Key do Gemini não está configurada!");
    }
  }

  Future<String> getGardeningTip(String plantQuery) async {
    try {
      final prompt = """
      Você é um assistente de jardinagem especializado.
      Um usuário precisa de ajuda com a seguinte planta ou problema: "$plantQuery".
      Forneça dicas claras, concisas e úteis sobre cuidados, problemas comuns,
      ou qualquer informação relevante para ajudar o usuário.
      Se a pergunta for muito vaga, peça mais detalhes.
      Se a pergunta não for sobre jardinagem, responda educadamente que você só pode ajudar com jardinagem.
      Formate sua resposta de forma amigável e fácil de ler.
      """;

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String tip = data['candidates'][0]['content']['parts'][0]['text'];
        return tip;
      } else {
        print('Erro na resposta da API: ${response.statusCode} - ${response.body}');
        return "Erro ao buscar dicas. Tente novamente mais tarde.";
      }
    } catch (e) {
      print('Erro ao chamar Gemini API: $e');
      if (e.toString().contains('API_KEY_INVALID')) {
        return "Erro: A chave da API do Gemini é inválida ou não foi configurada corretamente. Verifique o arquivo .env.";
      }
      return "Ocorreu um erro ao buscar dicas. Tente novamente mais tarde.";
    }
  }
}
