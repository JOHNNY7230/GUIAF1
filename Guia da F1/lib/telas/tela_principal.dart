import 'package:flutter/material.dart';
import 'abas_principais.dart';
import 'telas_secundarias.dart';
import 'tela_autenticacao.dart';
import 'tela_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  final Function(bool) aoAlternarTema;
  const TelaPrincipal({super.key, required this.aoAlternarTema});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceAtual = 0;
  bool _isDarkMode = false;

  final List<Widget> _telas = const [
    TelaPainel(),
    TelaGridPesquisa(),
    TelaClassificacaoCompleta(),
    TelaEquipes(), // <-- Rádio substituído por Equipes na barra inferior
    TelaFavoritosAvancada(),
  ];

  Widget _menuItem(
    BuildContext context,
    IconData icone,
    String titulo,
    VoidCallback acao, {
    Color? corIcone,
    Color? corTexto,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icone, color: corIcone ?? Colors.red.shade700, size: 26),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: corTexto,
        ),
      ),
      onTap: acao,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: InkWell(
          onTap: () {
            setState(() {
              _indiceAtual = 0;
            });
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.speed, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Pit Wall",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
              widget.aoAlternarTema(_isDarkMode);
            },
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.black87],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_motorsports,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Garagem F1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Acesso restrito à equipe",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _menuItem(context, Icons.person, "Meu Perfil", () {
                    Navigator.pop(context); // Fecha o menu lateral
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaPerfil()),
                    );
                  }),
                  const Divider(indent: 20, endIndent: 20),
                  _menuItem(
                    context,
                    Icons.newspaper,
                    "Notícias do Paddock",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TelaNoticias()),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    Icons.calendar_month,
                    "Calendário da Temporada",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaCalendario(),
                        ),
                      );
                    },
                  ),
                  _menuItem(context, Icons.menu_book, "Regras Básicas", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TelaRegrasBasicas(),
                      ),
                    );
                  }),
                  _menuItem(context, Icons.build, "Engenharia Avançada", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaSetup()),
                    );
                  }),
                  _menuItem(context, Icons.library_books, "Dicionário F1", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaDicionario()),
                    );
                  }),

                  // <-- RÁDIO ADICIONADO AQUI NO MENU HAMBÚRGUER -->
                  _menuItem(
                    context,
                    Icons.headset_mic,
                    "Rádio das Equipes",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: const Text("Interceptação de Rádio"),
                            ),
                            body: const TelaRadioList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _menuItem(
                context,
                Icons.exit_to_app,
                "Encerrar Sessão",
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaAutenticacao(
                        aoAlternarTema: widget.aoAlternarTema,
                      ),
                    ),
                  );
                },
                corIcone: Colors.red,
                corTexto: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: _telas[_indiceAtual],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: (index) {
          setState(() {
            _indiceAtual = index;
          });
        },
        backgroundColor: Theme.of(context).cardColor,
        indicatorColor: Colors.red.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.red),
            label: "Início",
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Colors.red),
            label: "Pilotos",
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Colors.red),
            label: "Tabela",
          ),
          // <-- EQUIPES SUBSTITUINDO O RÁDIO NA BARRA INFERIOR -->
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car, color: Colors.red),
            label: "Equipes",
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star, color: Colors.red),
            label: "Favoritos",
          ),
        ],
      ),
    );
  }
}
