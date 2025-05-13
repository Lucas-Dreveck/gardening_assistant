import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String? _geminiApiKey;

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
      if (_geminiApiKey == null) {
        print('ERRO: GEMINI_API_KEY não encontrada no .env');
        // Poderia lançar uma exceção aqui se preferir
      }
    } catch (e) {
      print('ERRO ao carregar .env: $e');
      // Tratar erro, talvez definir um valor padrão ou lançar exceção
    }
  }

  static String get geminiApiKey {
    if (_geminiApiKey == null) {
      // Isso não deveria acontecer se load() for chamado corretamente no main.dart
      print('ALERTA: GEMINI_API_KEY não carregada. Tentando carregar .env novamente.');
      // Poderia tentar chamar load() novamente, ou retornar uma string vazia/erro.
      // Por simplicidade, vamos apenas logar e retornar uma string vazia,
      // mas em um app real, isso precisaria de tratamento mais robusto.
      return '';
    }
    return _geminiApiKey!;
  }
}