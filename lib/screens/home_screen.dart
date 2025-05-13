import 'package:flutter/material.dart';
import 'package:gardening_assistant/providers/chat_provider.dart';
import 'package:gardening_assistant/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatProvider chatProvider) {
    if (_textController.text.isNotEmpty) {
      chatProvider.sendMessage(_textController.text);
      _textController.clear();
      FocusScope.of(context).unfocus(); // Esconde o teclado
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Pequeno delay para garantir que a lista foi atualizada antes de rolar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent, // para lista invertida
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente de Jardinagem'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Atualiza o texto do controller se houver fala reconhecida e não estiver ouvindo
          // Isso é útil se o usuário parar de falar e o texto for finalizado
          if (chatProvider.recognizedSpeech.isNotEmpty && !chatProvider.isListening) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_textController.text != chatProvider.recognizedSpeech) {
                   _textController.text = chatProvider.recognizedSpeech;
                   _textController.selection = TextSelection.fromPosition(
                       TextPosition(offset: _textController.text.length));
                }
             });
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Para o chat começar de baixo
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return MessageBubble(message: message);
                  },
                ),
              ),
              if (chatProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              _buildMessageInputField(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInputField(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: chatProvider.isListening ? 'Ouvindo...' : 'Digite sua dúvida sobre plantas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              onSubmitted: (_) => _sendMessage(chatProvider),
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              chatProvider.isListening ? Icons.mic_off : Icons.mic,
              color: chatProvider.isListening ? Colors.red : Theme.of(context).primaryColor,
            ),
            onPressed: chatProvider.isLoading
                ? null // Desabilita enquanto carrega resposta do bot
                : () {
                    if (chatProvider.isListening) {
                      chatProvider.stopListeningToSpeech();
                    } else {
                      _textController.clear(); // Limpa o campo antes de começar a ouvir
                      chatProvider.startListeningToSpeech(_textController);
                    }
                  },
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: chatProvider.isLoading || _textController.text.trim().isEmpty
                ? null // Desabilita se estiver carregando ou campo vazio
                : () => _sendMessage(chatProvider),
          ),
        ],
      ),
    );
  }
}