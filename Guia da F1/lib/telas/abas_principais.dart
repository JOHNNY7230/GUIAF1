import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../dados/f1_dados.dart';
import 'telas_secundarias.dart';

class TelaPainel extends StatefulWidget {
  const TelaPainel({super.key});
  @override
  State<TelaPainel> createState() => _TelaPainelState();
}

class _TelaPainelState extends State<TelaPainel> {
  final List<String> _curiosidades = [
    "A primeira corrida oficial da história da F1 aconteceu no circuito de Silverstone, em 1950.",
    "Um carro de F1 moderno é construído a partir de aproximadamente 80.000 componentes.",
    "Os pneus de chuva extrema conseguem afastar até 85 litros de água por segundo a 300 km/h.",
    "O volante de um carro de F1 moderno custa mais de R\$ 300.000 e tem dezenas de botões.",
    "O recorde de parada nos boxes pertence à McLaren, que trocou 4 pneus em apenas 1.80 segundos.",
  ];

  late String _curiosidadeAtual;

  @override
  void initState() {
    super.initState();
    _curiosidadeAtual = _curiosidades[Random().nextInt(_curiosidades.length)];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[800]!, Colors.orange[800]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.flag, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Temporada Atual",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Navegue pelas abas para explorar as estatísticas reais.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade700, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[800], size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Curiosidade do Dia",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _curiosidadeAtual,
                        style: const TextStyle(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Módulos de Conhecimento",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _cartaoAtalho(
                context,
                "Notícias",
                Icons.newspaper,
                Colors.deepPurple,
                const TelaNoticias(),
              ),
              _cartaoAtalho(
                context,
                "Regras Básicas",
                Icons.menu_book,
                Colors.blue,
                const TelaRegrasBasicas(),
              ),
              _cartaoAtalho(
                context,
                "Engenharia",
                Icons.build,
                Colors.green,
                const TelaSetup(),
              ),
              _cartaoAtalho(
                context,
                "Calendário",
                Icons.calendar_month,
                Colors.purple,
                const TelaCalendario(),
              ),
              _cartaoAtalho(
                context,
                "Dicionário F1",
                Icons.library_books,
                Colors.orange,
                const TelaDicionario(),
              ),
              _cartaoAtalho(
                context,
                "Hall da Fama",
                Icons.emoji_events,
                Colors.amber,
                const TelaHallFama(),
              ),
              _cartaoAtalho(
                context,
                "Equipes",
                Icons.directions_car,
                Colors.red,
                const TelaEquipes(),
              ),
              _cartaoAtalho(
                context,
                "Circuitos",
                Icons.map,
                Colors.teal,
                const TelaCircuitos(),
              ),
              _cartaoAtalho(
                context,
                "Pneus",
                Icons.album,
                Colors.blueGrey,
                const TelaPneus(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cartaoAtalho(
    BuildContext context,
    String titulo,
    IconData icone,
    MaterialColor cor,
    Widget telaDestino,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => telaDestino),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: cor.shade100,
                radius: 28,
                child: Icon(icone, color: cor.shade800, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaGridPesquisa extends StatefulWidget {
  const TelaGridPesquisa({super.key});
  @override
  State<TelaGridPesquisa> createState() => _TelaGridPesquisaState();
}

class _TelaGridPesquisaState extends State<TelaGridPesquisa> {
  List<dynamic> _pilotosOriginais = [];
  List<dynamic> _pilotosFiltrados = [];
  List<String> _favoritos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritosSalvos = prefs.getStringList('favoritos_pilotos') ?? [];

    try {
      final url = Uri.parse(
        'https://api.jolpi.ca/ergast/f1/current/drivers.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            List<dynamic> rawDrivers = data['MRData']['DriverTable']['Drivers'];
            _pilotosOriginais = rawDrivers.where((p) {
              final id = p['driverId']?.toString().toLowerCase() ?? '';
              return !id.contains('crawford');
            }).toList();
            _pilotosFiltrados = _pilotosOriginais;
            _favoritos = favoritosSalvos;
            _carregando = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _carregando = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _filtrarPilotos(String query) {
    setState(() {
      if (query.isEmpty) {
        _pilotosFiltrados = _pilotosOriginais;
      } else {
        _pilotosFiltrados = _pilotosOriginais.where((p) {
          final nomeCompleto = '${p['givenName']} ${p['familyName']}'
              .toLowerCase();
          return nomeCompleto.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _alternarFavorito(String nomePiloto) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoritos.contains(nomePiloto)) {
        _favoritos.remove(nomePiloto);
      } else {
        _favoritos.add(nomePiloto);
      }
    });
    await prefs.setStringList('favoritos_pilotos', _favoritos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filtrarPilotos,
            decoration: InputDecoration(
              hintText: "Pesquisar piloto...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : _pilotosFiltrados.isEmpty
              ? const Center(child: Text('Nenhum piloto encontrado.'))
              : ListView.builder(
                  itemCount: _pilotosFiltrados.length,
                  itemBuilder: (context, index) {
                    final piloto = _pilotosFiltrados[index];
                    final nome =
                        '${piloto['givenName']} ${piloto['familyName']}';
                    final driverId = piloto['driverId'];
                    final nacionalidade =
                        piloto['nationality'] ?? 'Desconhecida';
                    final isFavorito = _favoritos.contains(nome);
                    final corPiloto = obterCorPiloto(driverId);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: corPiloto.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Hero(
                          tag: 'avatar_$driverId',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: corPiloto, width: 2),
                            ),
                            child: CircleAvatar(
                              backgroundColor: corPiloto.withValues(alpha: 0.1),
                              backgroundImage: obterFotoPiloto(driverId),
                            ),
                          ),
                        ),
                        title: Text(
                          nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Nº ${piloto['permanentNumber'] ?? '?'} | ${obterBandeira(nacionalidade)} ${traduzirNacionalidade(nacionalidade)}",
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFavorito ? Icons.star : Icons.star_border,
                            color: isFavorito ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => _alternarFavorito(nome),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TelaPerfilPiloto(piloto: piloto),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TelaClassificacaoCompleta extends StatelessWidget {
  const TelaClassificacaoCompleta({super.key});

  Future<List<dynamic>> buscarPilotos() async {
    final response = await http.get(
      Uri.parse('https://api.jolpi.ca/ergast/f1/current/driverStandings.json'),
    );
    List<dynamic> standings = json.decode(
      response.body,
    )['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings'];
    return standings.where((p) {
      final id = p['Driver']['driverId']?.toString().toLowerCase() ?? '';
      return !id.contains('crawford');
    }).toList();
  }

  Future<List<dynamic>> buscarConstrutores() async {
    final response = await http.get(
      Uri.parse(
        'https://api.jolpi.ca/ergast/f1/current/constructorStandings.json',
      ),
    );
    return json.decode(
      response.body,
    )['MRData']['StandingsTable']['StandingsLists'][0]['ConstructorStandings'];
  }

  Widget _gerarIconePodio(int posicao, Color corPiloto) {
    if (posicao == 1) {
      return const CircleAvatar(
        backgroundColor: Colors.amber,
        child: Icon(Icons.emoji_events, color: Colors.white, size: 20),
      );
    }
    if (posicao == 2) {
      return CircleAvatar(
        backgroundColor: Color(0xFFBDBDBD),
        child: Icon(Icons.emoji_events, color: Colors.white, size: 20),
      );
    }
    if (posicao == 3) {
      return CircleAvatar(
        backgroundColor: Color(0xFFA1887F),
        child: Icon(Icons.emoji_events, color: Colors.white, size: 20),
      );
    }
    return CircleAvatar(
      backgroundColor: corPiloto,
      child: Text(
        posicao.toString(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: "PILOTOS"),
              Tab(text: "CONSTRUTORES"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _construirListaPilotos(),
                _construirListaConstrutores(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirListaPilotos() {
    return FutureBuilder<List<dynamic>>(
      future: buscarPilotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Sem dados.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final p = snapshot.data![index];
            final driverId = p['Driver']['driverId'];
            final int pos = int.parse(p['position']);
            final corPiloto = obterCorPiloto(driverId);
            final corFundo = index.isEven
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[300])
                : Colors.transparent;

            return Container(
              color: corFundo,
              child: ListTile(
                leading: _gerarIconePodio(pos, corPiloto),
                title: Text(
                  '${p['Driver']['givenName']} ${p['Driver']['familyName']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: pos <= 3 ? Colors.amber[700] : null,
                  ),
                ),
                subtitle: Text(p['Constructors'][0]['name']),
                trailing: Text(
                  '${p['points']} pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _construirListaConstrutores() {
    return FutureBuilder<List<dynamic>>(
      future: buscarConstrutores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Sem dados.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final c = snapshot.data![index];
            final int pos = int.parse(c['position']);
            final corFundo = index.isEven
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[300])
                : Colors.transparent;

            return Container(
              color: corFundo,
              child: ListTile(
                leading: _gerarIconePodio(pos, Colors.black),
                title: Text(
                  c['Constructor']['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: pos <= 3 ? Colors.amber[700] : null,
                  ),
                ),
                subtitle: Text('Vitórias: ${c['wins']}'),
                trailing: Text(
                  '${c['points']} pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TelaRadioList extends StatefulWidget {
  const TelaRadioList({super.key});
  @override
  State<TelaRadioList> createState() => _TelaRadioListState();
}

class _TelaRadioListState extends State<TelaRadioList> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _urlTocando;
  List<dynamic> _radios = [];
  Map<int, Map<String, dynamic>> _pilotosInfo = {};
  List<dynamic> _sessoesDisponiveis = [];
  String? _sessaoAtual;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarSessoesRecentes();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _urlTocando = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _buscarSessoesRecentes() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openf1.org/v1/sessions?session_type=Race'),
      );
      if (response.statusCode == 200) {
        List<dynamic> sessoes = json.decode(response.body);
        final dataAtual = DateTime.now();
        sessoes = sessoes.where((s) {
          return DateTime.parse(s['date_start']).isBefore(dataAtual);
        }).toList();

        final Map<String, dynamic> sessoesUnicas = {};
        for (var s in sessoes) {
          sessoesUnicas['${s['country_name']}_${s['year']}'] = s;
        }
        sessoes = sessoesUnicas.values.toList().reversed.take(15).toList();
        sessoes.addAll([
          {'session_key': '9165', 'country_name': 'São Paulo', 'year': '2023'},
          {'session_key': '9158', 'country_name': 'Abu Dhabi', 'year': '2023'},
        ]);

        if (mounted) {
          setState(() {
            _sessoesDisponiveis = sessoes;
            if (sessoes.isNotEmpty) {
              _sessaoAtual = sessoes.first['session_key'].toString();
            }
          });
          if (_sessaoAtual != null) {
            _buscarRadio();
          } else {
            setState(() {
              _carregando = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _carregando = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _buscarRadio() async {
    if (_sessaoAtual == null) {
      return;
    }
    setState(() {
      _carregando = true;
      _radios = [];
    });
    try {
      final resR = await http.get(
        Uri.parse(
          'https://api.openf1.org/v1/team_radio?session_key=$_sessaoAtual',
        ),
      );
      final resD = await http.get(
        Uri.parse(
          'https://api.openf1.org/v1/drivers?session_key=$_sessaoAtual',
        ),
      );
      if (resR.statusCode == 200 && resD.statusCode == 200) {
        Map<int, Map<String, dynamic>> infoMap = {};
        for (var d in json.decode(resD.body)) {
          infoMap[d['driver_number']] = {
            'name': d['full_name'],
            'team': d['team_name'],
          };
        }
        if (mounted) {
          setState(() {
            _pilotosInfo = infoMap;
            _radios = List.from(json.decode(resR.body).reversed.take(40));
            _carregando = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _carregando = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _tocarRadio(String url) async {
    if (_urlTocando == url) {
      await _audioPlayer.pause();
      setState(() {
        _urlTocando = null;
      });
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _urlTocando = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).cardColor,
          width: double.infinity,
          child: _sessoesDisponiveis.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Buscando dados..."),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sessaoAtual,
                    isExpanded: true,
                    icon: Icon(Icons.speaker_phone, color: Colors.red[800]),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                    items: _sessoesDisponiveis.map((s) {
                      return DropdownMenuItem<String>(
                        value: s['session_key'].toString(),
                        child: Text("GP ${s['country_name']} (${s['year']})"),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _sessaoAtual = v;
                        });
                        _buscarRadio();
                      }
                    },
                  ),
                ),
        ),
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : _radios.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "A API ainda não enviou os rádios desta corrida recente. Escolha uma corrida mais antiga!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _radios.length,
                  itemBuilder: (context, index) {
                    final msg = _radios[index];
                    final url = msg['recording_url'];
                    final tocando = _urlTocando == url;
                    final info = _pilotosInfo[msg['driver_number']];

                    final nomePiloto = info?['name'] ?? 'Piloto Desconhecido';
                    final nomeEscuderia =
                        info?['team'] ?? 'Equipe Desconhecida';

                    String horaLegenda = "00:00:00";
                    try {
                      final dataHora = DateTime.parse(msg['date']).toLocal();
                      horaLegenda =
                          "${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}:${dataHora.second.toString().padLeft(2, '0')}";
                    } catch (_) {
                      // Ignora o erro silenciosamente caso a data venha nula ou em formato incorreto
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: tocando ? Colors.red.withValues(alpha: 0.1) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: tocando
                              ? Colors.red.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: tocando
                                ? Colors.red[800]
                                : Colors.grey[800],
                            child: const Icon(
                              Icons.headset_mic,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            "$nomePiloto (#${msg['driver_number']})",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tocando
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nomeEscuderia),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.closed_caption,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tocando
                                            ? "[ $horaLegenda ] Reproduzindo transmissão interceptada do veículo de $nomePiloto..."
                                            : "[ $horaLegenda ] Gravação de rádio criptografada. Clique para ouvir o áudio original.",
                                        style: TextStyle(
                                          color: tocando
                                              ? Colors.amber
                                              : Colors.white70,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              tocando
                                  ? Icons.stop_circle
                                  : Icons.play_circle_fill,
                              size: 40,
                              color: tocando ? Colors.red[800] : Colors.grey,
                            ),
                            onPressed: () {
                              _tocarRadio(url);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TelaFavoritosAvancada extends StatefulWidget {
  const TelaFavoritosAvancada({super.key});
  @override
  State<TelaFavoritosAvancada> createState() => _TelaFavoritosAvancadaState();
}

class _TelaFavoritosAvancadaState extends State<TelaFavoritosAvancada> {
  List<String> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritos = prefs.getStringList('favoritos_pilotos') ?? [];
    });
  }

  void _remover(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritos.remove(nome);
    });
    await prefs.setStringList('favoritos_pilotos', _favoritos);
  }

  @override
  Widget build(BuildContext context) {
    if (_favoritos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("Nenhum piloto favorito salvo."),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _favoritos.length,
      itemBuilder: (context, index) {
        final nome = _favoritos[index];
        return Dismissible(
          key: Key(nome),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            _remover(nome);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.star, color: Colors.white),
              ),
              title: Text(
                nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Deslize para a esquerda para apagar"),
            ),
          ),
        );
      },
    );
  }
}
