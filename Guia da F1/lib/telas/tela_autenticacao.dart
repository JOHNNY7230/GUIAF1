import 'package:flutter/material.dart';
import 'tela_principal.dart';

class TelaAutenticacao extends StatefulWidget {
  final Function(bool) aoAlternarTema;
  const TelaAutenticacao({super.key, required this.aoAlternarTema});

  @override
  State<TelaAutenticacao> createState() => _TelaAutenticacaoState();
}

class _TelaAutenticacaoState extends State<TelaAutenticacao>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: const AssetImage('assets/WPPF1.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(Icons.sports_motorsports, size: 80, color: Colors.red[600]),
              const SizedBox(height: 10),
              const Text(
                "GUIA DA F1",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const Text(
                "Acelere seus conhecimentos",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.red[600],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: "ENTRAR"),
                  Tab(text: "CADASTRAR"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _Formulario(
                      isLogin: true,
                      aoEntrar: () => _navegarParaPrincipal(context),
                    ),
                    _Formulario(
                      isLogin: false,
                      aoEntrar: () => _navegarParaPrincipal(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navegarParaPrincipal(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TelaPrincipal(aoAlternarTema: widget.aoAlternarTema),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _Formulario extends StatelessWidget {
  final bool isLogin;
  final VoidCallback aoEntrar;
  const _Formulario({required this.isLogin, required this.aoEntrar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLogin) ...[
              _campoTexto("Nome Completo", Icons.person),
              const SizedBox(height: 16),
            ],
            _campoTexto("E-mail", Icons.email),
            const SizedBox(height: 16),
            _campoTexto("Senha", Icons.lock, obscuro: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: aoEntrar,
                child: Text(
                  isLogin ? "ENTRAR" : "CRIAR CONTA",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLogin)
              TextButton(
                onPressed: aoEntrar,
                child: const Text(
                  "Acessar como Visitante",
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(String rotulo, IconData icone, {bool obscuro = false}) {
    return TextField(
      obscureText: obscuro,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: rotulo,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icone, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
