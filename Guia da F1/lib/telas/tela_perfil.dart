import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _bioController = TextEditingController();

  String? _nomeUsuario;
  String? _emailUsuario;
  String _equipeFavorita = 'Nenhuma';

  final List<String> _equipesF1 = [
    'Nenhuma',
    'Ferrari',
    'McLaren',
    'Red Bull Racing',
    'Mercedes',
    'Aston Martin',
    'Alpine',
    'Haas',
    'Williams',
    'RB (Racing Bulls)',
    'Sauber',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  Future<void> _carregarDadosPerfil() async {
    final user = _auth.currentUser;
    if (mounted) {
      setState(() {
        _nomeUsuario = user?.displayName ?? 'Piloto Anônimo';
        _emailUsuario = user?.email ?? 'Visitante';
      });
    }

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _bioController.text = prefs.getString('bio_usuario') ?? '';
        _equipeFavorita = prefs.getString('equipe_favorita') ?? 'Nenhuma';
      });
    }
  }

  Future<void> _salvarDadosPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bio_usuario', _bioController.text);
    await prefs.setString('equipe_favorita', _equipeFavorita);

    if (mounted) {
      FocusScope.of(context).unfocus(); // Recolhe o teclado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvarDadosPerfil,
            tooltip: 'Salvar Perfil',
          ),
        ],
      ),
      // LayoutBuilder + IntrinsicHeight cria um layout que se adapta ao teclado sem quebrar
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // CONTEÚDO PRINCIPAL
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              _nomeUsuario ?? 'Carregando...',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _emailUsuario ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 40),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Equipe do Coração",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _equipesF1.contains(_equipeFavorita)
                                      ? _equipeFavorita
                                      : 'Nenhuma',
                                  items: _equipesF1.map((String equipe) {
                                    return DropdownMenuItem<String>(
                                      value: equipe,
                                      child: Text(equipe),
                                    );
                                  }).toList(),
                                  onChanged: (String? novaEquipe) {
                                    if (novaEquipe != null) {
                                      setState(() {
                                        _equipeFavorita = novaEquipe;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Sua Biografia",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _bioController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    "Escreva um pouco sobre a sua paixão pela F1...",
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade700,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // BOTÃO FIXO NO RODAPÉ
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 24.0,
                        top: 10.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text(
                            "SALVAR ALTERAÇÕES",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          onPressed: _salvarDadosPerfil,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
