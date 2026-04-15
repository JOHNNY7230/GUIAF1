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
  String _pilotoFavorito = 'Nenhum';

  // O SEGREDO PARA NÃO MISTURAR PERFIS: Pega o ID único do usuário logado ou usa 'guest'
  String get _userPrefix => _auth.currentUser?.uid ?? 'guest';

  // Nomes Oficiais Atualizados (Era 2026)
  final List<String> _equipesF1 = [
    'Nenhuma',
    'Scuderia Ferrari HP',
    'McLaren Formula 1 Team',
    'Oracle Red Bull Racing',
    'Mercedes-AMG PETRONAS',
    'Aston Martin Aramco',
    'BWT Alpine F1 Team',
    'MoneyGram Haas F1 Team',
    'Williams Racing',
    'Visa Cash App RB',
    'Audi F1 Team', // Substituiu a Stake/Sauber!
    'Cadillac F1 Team', // A nova 11ª equipe do grid!
  ];

  // A TUA LISTA ORIGINAL MANTIDA AQUI (Expandido para 22 vagas)
  final List<String> _pilotosF1 = [
    'Nenhum',
    'Gabriel Bortoleto', // Agora oficial da Audi
    'Lewis Hamilton', // De vermelho
    'Charles Leclerc',
    'Max Verstappen',
    'Lando Norris',
    'Oscar Piastri',
    'George Russell',
    'Fernando Alonso',
    'Carlos Sainz',
    'Nico Hülkenberg',
    'Alexander Albon',
    'Liam Lawson',
    'Esteban Ocon',
    'Pierre Gasly',
    'Oliver Bearman',
    'Kimi Antonelli',
    'Franco Colapinto',
    'Isack Hadjar',
    'Arvid Lindblab',
    'Sergio Pérez',
    'Lance Stroll',
    'Valtteri Bottas',
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
        // Se for visitante, mostra os textos genéricos que definiste
        _nomeUsuario = user?.displayName ?? 'Piloto Sem Nome';
        _emailUsuario = user?.email ?? 'visitante@f1.com';
      });
    }

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Busca os dados usando o prefixo único do utilizador
        _bioController.text = prefs.getString('${_userPrefix}_bio') ?? '';

        // Carrega a equipe, se não existir na lista atualizada, volta para 'Nenhuma'
        String equipeSalva =
            prefs.getString('${_userPrefix}_equipe') ?? 'Nenhuma';
        _equipeFavorita = _equipesF1.contains(equipeSalva)
            ? equipeSalva
            : 'Nenhuma';

        String pilotoSalvo =
            prefs.getString('${_userPrefix}_piloto') ?? 'Nenhum';
        _pilotoFavorito = _pilotosF1.contains(pilotoSalvo)
            ? pilotoSalvo
            : 'Nenhum';
      });
    }
  }

  Future<void> _salvarDadosPerfil() async {
    final prefs = await SharedPreferences.getInstance();

    // Salva os dados na "caixa" exclusiva do utilizador atual
    await prefs.setString('${_userPrefix}_bio', _bioController.text);
    await prefs.setString('${_userPrefix}_equipe', _equipeFavorita);
    await prefs.setString('${_userPrefix}_piloto', _pilotoFavorito);

    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Credencial atualizada com sucesso!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Paddock Pass",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.redAccent),
            onPressed: _salvarDadosPerfil,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade900.withValues(alpha: 0.4),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 60),

                      // CARTÃO DE CREDENCIAL VIP
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white54,
                                ),
                                Text(
                                  "FIA SUPER LICENSE",
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.redAccent,
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.sports_motorsports,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _nomeUsuario?.toUpperCase() ?? 'CARREGANDO...',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _emailUsuario ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // FORMULÁRIOS DE PREFERÊNCIA
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _construirTituloSecao(
                                Icons.business,
                                "Equipe Oficial",
                              ),
                              _construirDropdown(
                                valorAtual: _equipeFavorita,
                                itens: _equipesF1,
                                aoMudar: (novo) =>
                                    setState(() => _equipeFavorita = novo!),
                              ),
                              const SizedBox(height: 20),

                              _construirTituloSecao(
                                Icons.sports_score,
                                "Piloto Favorito",
                              ),
                              _construirDropdown(
                                valorAtual: _pilotoFavorito,
                                itens: _pilotosF1,
                                aoMudar: (novo) =>
                                    setState(() => _pilotoFavorito = novo!),
                              ),
                              const SizedBox(height: 20),

                              _construirTituloSecao(
                                Icons.history_edu,
                                "Histórico / Biografia",
                              ),
                              TextField(
                                controller: _bioController,
                                maxLines: 3,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Sua trajetória como fã de F1...",
                                  hintStyle: const TextStyle(
                                    color: Colors.white30,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.05,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // BOTÃO FIXO NO RODAPÉ
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          bottom: 30.0,
                          top: 10.0,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            onPressed: _salvarDadosPerfil,
                            child: const Text(
                              "SALVAR CREDENCIAL",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
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
      ),
    );
  }

  // Widgets auxiliares para manter o código limpo
  Widget _construirTituloSecao(IconData icone, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icone, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirDropdown({
    required String valorAtual,
    required List<String> itens,
    required Function(String?) aoMudar,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Colors.grey.shade900,
          icon: const Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.redAccent,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          value: valorAtual,
          items: itens.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: aoMudar,
        ),
      ),
    );
  }
}
