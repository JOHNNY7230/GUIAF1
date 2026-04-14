import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Mantido para o Auth
import 'firebase_options.dart'; // Certifique-se de que este arquivo existe (gerado pelo FlutterFire CLI)
import 'telas/tela_autenticacao.dart';

void main() async {
  // Garante que os bindings do Flutter estão inicializados antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa apenas o Firebase Core (necessário para o Firebase Auth)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Log silencioso caso falhe ao inicializar (evita quebrar o app inteiro se houver bloqueio extremo)
    debugPrint('Erro ao inicializar o Firebase: $e');
  }

  runApp(const GuiaF1App());
}

class GuiaF1App extends StatefulWidget {
  const GuiaF1App({super.key});

  @override
  State<GuiaF1App> createState() => _GuiaF1AppState();
}

class _GuiaF1AppState extends State<GuiaF1App> {
  ThemeMode _temaAtual = ThemeMode.dark;

  void _alternarTema(bool isDarkMode) {
    setState(() {
      _temaAtual = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guia F1',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
      ),
      themeMode: _temaAtual,
      home: TelaAutenticacao(aoAlternarTema: _alternarTema),
    );
  }
}
