import 'package:flutter/material.dart';
import 'package:gardening_assistant/core/env.dart';
import 'package:gardening_assistant/providers/chat_provider.dart';
import 'package:gardening_assistant/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Essencial para plugins
  await Env.load(); // Carrega as variáveis de ambiente
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: 'Assistente de Jardinagem',
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            secondary: Colors.lightGreenAccent,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}