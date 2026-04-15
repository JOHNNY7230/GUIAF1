import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. CAMADA DE FUNDO (Fixa, não amassa com o teclado)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: const AssetImage('assets/WPPF1.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.75),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
        ),

        // 2. CAMADA DO APLICATIVO (Rola por cima da imagem)
        Scaffold(
          backgroundColor: Colors.transparent, // Deixa a imagem aparecer
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Cabeçalho
                Icon(
                  Icons.sports_motorsports,
                  size: 70,
                  color: Colors.red[600],
                ),
                const SizedBox(height: 5),
                const Text(
                  "GUIA DA F1",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "Acelere seus conhecimentos",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Abas (Guias)
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.red[600],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: "ENTRAR"),
                    Tab(text: "CADASTRAR"), // Padronizado em PT-BR
                  ],
                ),

                // Área dos Formulários
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _Formulario(
                        isLogin: true,
                        aoEntrarSucesso: () => _navegarParaPrincipal(context),
                      ),
                      _Formulario(
                        isLogin: false,
                        aoEntrarSucesso: () => _navegarParaPrincipal(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

class _Formulario extends StatefulWidget {
  final bool isLogin;
  final VoidCallback aoEntrarSucesso;

  const _Formulario({required this.isLogin, required this.aoEntrarSucesso});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();

  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _autenticarFirebase() async {
    // Validação de campos vazios
    if (_emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isLogin) {
        // Rotina de Login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      } else {
        // Rotina de Cadastro
        UserCredential credencial = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
        // Atualiza o nome do usuário sem usar banco de dados externo
        await credencial.user?.updateDisplayName(_nomeController.text.trim());
      }

      widget.aoEntrarSucesso();
    } on FirebaseAuthException catch (e) {
      // Mensagens de Erro Traduzidas (PT-BR)
      String mensagemErro = 'Ocorreu um erro de autenticação.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        mensagemErro = 'E-mail ou senha incorretos.';
      } else if (e.code == 'email-already-in-use') {
        mensagemErro = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'weak-password') {
        mensagemErro = 'A senha deve ter no mínimo 6 caracteres.';
      } else if (e.code == 'invalid-email') {
        mensagemErro = 'O formato do e-mail é inválido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!widget.isLogin) ...[
              _campoTexto(
                "Nome Completo",
                Icons.person,
                _nomeController,
                false,
              ),
              const SizedBox(height: 16),
            ],
            _campoTexto("E-mail", Icons.email, _emailController, false),
            const SizedBox(height: 16),
            _campoTexto("Senha", Icons.lock, _senhaController, true),
            const SizedBox(height: 30),

            _isLoading
                ? CircularProgressIndicator(color: Colors.red[700])
                : SizedBox(
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
                      onPressed: _autenticarFirebase,
                      child: Text(
                        widget.isLogin ? "ENTRAR" : "CADASTRAR",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),

            if (widget.isLogin && !_isLoading)
              TextButton(
                onPressed: widget.aoEntrarSucesso,
                child: const Text(
                  "Acessar como Visitante",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(
    String rotulo,
    IconData icone,
    TextEditingController controlador,
    bool obscuro,
  ) {
    return TextField(
      controller: controlador,
      obscureText: obscuro,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: rotulo,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icone, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
