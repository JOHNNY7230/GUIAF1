import 'package:flutter/material.dart';
import 'telas/tela_autenticacao.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GuiaF1App());
}

class GuiaF1App extends StatefulWidget {
  const GuiaF1App({super.key});
  @override
  State<GuiaF1App> createState() => _GuiaF1AppState();
}

class _GuiaF1AppState extends State<GuiaF1App> {
  ThemeMode _modoTema = ThemeMode.light;

  void alternarTema(bool isDark) {
    setState(() => _modoTema = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia da F1',
      debugShowCheckedModeBanner: false,
      themeMode: _modoTema,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red[800],
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
          primary: Colors.red[600],
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: TelaAutenticacao(aoAlternarTema: alternarTema),
    );
  }
}
