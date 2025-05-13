import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Importe o pacote
import 'package:gardening_assistant/models/chat_message.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir links

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  // Função para tentar abrir URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Poderia mostrar um snackbar ou logar o erro
      print('Não foi possível abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.sender == MessageSender.user;
    final ThemeData theme = Theme.of(context);

    Widget messageContent;

    if (isUserMessage) {
      // Mensagens do usuário são apenas texto simples
      messageContent = Text(
        message.text,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
        ),
      );
    } else {
      // Mensagens do bot são processadas como Markdown
      messageContent = MarkdownBody(
        data: message.text,
        selectable: true, // Permite selecionar e copiar o texto
        onTapLink: (text, href, title) { // Lida com cliques em links
          if (href != null) {
            _launchUrl(href);
          }
        },
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          // Personalize os estilos do Markdown aqui se necessário
          p: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer),
          h1: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
          h2: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
          // ... outros estilos para a, code, blockquote, etc.
          listBullet: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer),
          code: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace', // Use uma fonte monoespaçada para código
            backgroundColor: theme.colorScheme.surfaceVariant,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          codeblockDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.dividerColor),
          ),
        ),
        // Se você precisar carregar imagens da rede referenciadas no Markdown:
        // imageBuilder: (Uri uri, String? title, String? alt) {
        //   return Image.network(uri.toString());
        // },
      );
    }

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUserMessage
              ? theme.colorScheme.primary
              : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUserMessage ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isUserMessage ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: messageContent,
      ),
    );
  }
}