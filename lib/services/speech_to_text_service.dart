import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  final stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  SpeechToTextService() : _speech = stt.SpeechToText();

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<bool> initialize() async {
    // Solicitar permissão de microfone
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print("Permissão de microfone negada.");
        return false;
      }
    }

    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      print("Speech to text inicializado com sucesso.");
    } else {
      print("O usuário negou o uso do reconhecimento de fala.");
    }
    return available;
  }

  void startListening({required Function(String) onResult, required Function onListeningStatusChanged}) {
    if (!_isListening && _speech.isAvailable) {
      _isListening = true;
      onListeningStatusChanged();
      _speech.listen(
        onResult: (val) {
          _lastWords = val.recognizedWords;
          onResult(_lastWords); // Atualiza o texto enquanto fala
          if (val.finalResult) { // Se for o resultado final da fala
            _isListening = false;
            onListeningStatusChanged();
          }
        },
        listenFor: const Duration(seconds: 30), // Tempo máximo de escuta
        pauseFor: const Duration(seconds: 5),  // Pausa após não detectar fala
        localeId: 'pt_BR', // Definir para português
      );
    }
  }

  void stopListening({required Function onListeningStatusChanged}) {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      onListeningStatusChanged();
    }
  }

  void cancelListening({required Function onListeningStatusChanged}) {
    if (_isListening) {
      _speech.cancel();
      _isListening = false;
      onListeningStatusChanged();
    }
  }
}