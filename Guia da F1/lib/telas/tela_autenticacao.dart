import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Controladores para capturar o que for digitado (com dados de teste já preenchidos)
  final _emailController = TextEditingController(text: 'lucasmoura@gmail.com');
  final _senhaController = TextEditingController(text: '7230');
  final _nomeController = TextEditingController();

  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lógica principal de comunicação com o Firebase
  Future<void> _autenticarFirebase() async {
    setState(() => _isLoading = true);

    try {
      if (widget.isLogin) {
        // Tenta fazer o Login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      } else {
        // Tenta criar uma conta nova
        UserCredential credencial = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );

        // GRAVA OS DADOS NO BANCO AUTOMATICAMENTE
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(credencial.user!.uid)
            .set({
              'nome': _nomeController.text.trim(),
              'email': _emailController.text.trim(),
              'equipe_favorita': '', // O usuário pode escolher isso depois
              'criado_em': FieldValue.serverTimestamp(),
            });
      }

      // Se chegou aqui, a senha estava certa ou a conta foi criada!
      widget.aoEntrarSucesso();
    } on FirebaseAuthException catch (e) {
      // Se deu erro (senha errada, usuário não existe, etc), mostra aviso vermelho
      String mensagemErro = 'Erro de autenticação';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        mensagemErro = 'E-mail ou senha incorretos.';
      } else if (e.code == 'email-already-in-use') {
        mensagemErro = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'weak-password') {
        mensagemErro = 'A senha deve ter pelo menos 6 caracteres.';
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
        padding: const EdgeInsets.all(30.0),
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

            // Se estiver carregando, mostra o círculo de progresso. Se não, mostra o botão.
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
                      onPressed:
                          _autenticarFirebase, // Agora chama a função do Firebase
                      child: Text(
                        widget.isLogin ? "ENTRAR" : "CRIAR CONTA",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            if (widget.isLogin && !_isLoading)
              TextButton(
                onPressed: widget.aoEntrarSucesso, // Visitante passa direto
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

  Widget _campoTexto(
    String rotulo,
    IconData icone,
    TextEditingController controlador,
    bool obscuro,
  ) {
    return TextField(
      controller: controlador, // Agora o campo guarda o que foi digitado
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
