import 'package:flutter/material.dart';
import 'package:gardening_assistant/models/chat_message.dart';
import 'package:gardening_assistant/services/gemini_service.dart';
import 'package:gardening_assistant/services/speech_to_text_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final SpeechToTextService _speechService = SpeechToTextService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  String _recognizedSpeech = '';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isListening => _speechService.isListening; // Usar o estado do serviço
  String get recognizedSpeech => _recognizedSpeech;

  ChatProvider() {
    // Mensagem inicial de boas-vindas do bot
    _messages.add(
      ChatMessage(
        text: "Olá! Sou seu assistente de jardinagem. Como posso ajudar com suas plantas hoje?",
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ),
    );
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initialize();
    notifyListeners();
  }

  void startListeningToSpeech(TextEditingController textController) {
    _speechService.startListening(
      onResult: (text) {
        _recognizedSpeech = text;
        textController.text = _recognizedSpeech; // Atualiza o TextField em tempo real
        // Não precisa de notifyListeners() aqui se o TextField já está sendo atualizado
      },
      onListeningStatusChanged: () {
        _isListening = _speechService.isListening;
        notifyListeners();
      }
    );
     _isListening = _speechService.isListening; // Garante que o estado é atualizado imediatamente
    notifyListeners();
  }

  void stopListeningToSpeech() {
     _speechService.stopListening(onListeningStatusChanged: () {
        _isListening = _speechService.isListening;
        notifyListeners();
      });
      _isListening = _speechService.isListening;
      notifyListeners();
  }


  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Adiciona mensagem do usuário
    _addMessage(text, MessageSender.user);
    _isLoading = true;
    notifyListeners();

    // Limpa o texto reconhecido por voz se houver
    _recognizedSpeech = '';

    try {
      final botResponse = await _geminiService.getGardeningTip(text);
      _addMessage(botResponse, MessageSender.bot);
    } catch (e) {
      _addMessage("Erro ao contatar o assistente: ${e.toString()}", MessageSender.bot);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addMessage(String text, MessageSender sender) {
    final message = ChatMessage(
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
    );
    _messages.insert(0, message); // Adiciona no início para novas mensagens aparecerem no topo
  }
}