import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../dados/f1_dados.dart';

// --- 1. NOTÍCIAS DINÂMICAS E PREMIUM ---
class TelaNoticias extends StatefulWidget {
  const TelaNoticias({super.key});
  @override
  State<TelaNoticias> createState() => _TelaNoticiasState();
}

class _TelaNoticiasState extends State<TelaNoticias> {
  List<dynamic> _noticias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarNoticias();
  }

  Future<void> _buscarNoticias() async {
    try {
      // Feed 1: Motorsport
      String urlRss = 'https%3A%2F%2Fbr.motorsport.com%2Frss%2Ff1%2Fnews%2F';

      final url = Uri.parse(
        'https://api.rss2json.com/v1/api.json?rss_url=$urlRss',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          if (mounted) {
            setState(() {
              _noticias = data['items'] ?? [];
              _carregando = false;
            });
          }
        } else {
          if (mounted) setState(() => _carregando = false);
        }
      } else {
        if (mounted) setState(() => _carregando = false);
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Últimas do Paddock")),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _noticias.isEmpty
          ? const Center(child: Text("Sem conexão com a torre de imprensa."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _noticias.length,
              itemBuilder: (context, index) {
                final noticia = _noticias[index];
                final hasImage =
                    noticia['thumbnail'] != null &&
                    noticia['thumbnail'].toString().isNotEmpty;
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // SE TEM IMAGEM, MOSTRA A IMAGEM. SE NÃO, MOSTRA UM FUNDO CINZA
                      if (hasImage)
                        Image.network(
                          noticia['thumbnail'],
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 140,
                          width: double.infinity,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[900]
                              : Colors.grey[300],
                        ),

                      // DEGRADÊ ESCURO POR CIMA
                      if (hasImage)
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),

                      // TEXTOS DA NOTÍCIA
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "NOTÍCIA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              noticia['title'] ?? '',
                              style: TextStyle(
                                color: hasImage
                                    ? Colors.white
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// --- 2. CALENDÁRIO COM CONTAGEM REGRESSIVA ---
class TelaCalendario extends StatefulWidget {
  const TelaCalendario({super.key});
  @override
  State<TelaCalendario> createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  List<dynamic> _corridas = [];
  bool _carregando = true;
  final List<GlobalKey> _chaves = [];

  Timer? _timer;
  Duration _tempoRestante = Duration.zero;
  dynamic _proximaCorrida;

  @override
  void initState() {
    super.initState();
    _buscarCalendario();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _buscarCalendario() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jolpi.ca/ergast/f1/current.json'),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _corridas = json.decode(
              response.body,
            )['MRData']['RaceTable']['Races'];
            _chaves.addAll(
              List.generate(_corridas.length, (index) => GlobalKey()),
            );
            _carregando = false;
            _calcularProximaCorrida();
          });
        }
      } else {
        if (mounted) setState(() => _carregando = false);
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _calcularProximaCorrida() {
    final agora = DateTime.now();
    for (var corrida in _corridas) {
      final dataStr = "${corrida['date']}T${corrida['time'] ?? '00:00:00Z'}";
      final dataCorrida = DateTime.parse(dataStr).toLocal();
      if (dataCorrida.isAfter(agora)) {
        _proximaCorrida = corrida;
        _iniciarCronometro(dataCorrida);
        break;
      }
    }
  }

  void _iniciarCronometro(DateTime dataAlvo) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final agora = DateTime.now();
      if (dataAlvo.isAfter(agora)) {
        setState(() {
          _tempoRestante = dataAlvo.difference(agora);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _rolarParaSessao(int index) {
    Scrollable.ensureVisible(
      _chaves[index].currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendário da Temporada")),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _corridas.isEmpty
          ? const Center(child: Text("Nenhuma corrida encontrada."))
          : Column(
              children: [
                if (_proximaCorrida != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.shade900),
                    child: Column(
                      children: [
                        Text(
                          "PRÓXIMA CORRIDA: ${_proximaCorrida['Circuit']['Location']['country'].toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${_tempoRestante.inDays}d ${_tempoRestante.inHours.remainder(24).toString().padLeft(2, '0')}:${_tempoRestante.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_tempoRestante.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _corridas.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: ActionChip(
                          backgroundColor: Colors.grey.shade800,
                          label: Text(
                            "Etapa ${_corridas[index]['round']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _rolarParaSessao(index),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(_corridas.length, (index) {
                        final corrida = _corridas[index];
                        final pais = corrida['Circuit']['Location']['country'];
                        return Card(
                          key: _chaves[index],
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[800],
                              child: Text(
                                corrida['round'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              corrida['raceName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${corrida['Circuit']['circuitName']}\n${obterBandeira(pais)} ${corrida['Circuit']['Location']['locality']}, $pais",
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  corrida['date'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class TelaEquipes extends StatelessWidget {
  const TelaEquipes({super.key});

  // DADOS TÉCNICOS E BIOGRAFIAS RICAS - ERA 2026 (11 EQUIPAS)
  final List<Map<String, dynamic>> _equipes = const [
    {
      "nome": "Scuderia Ferrari HP",
      "historia":
          "A equipa mais antiga e icónica da F1 entra na nova era de regulamentos com a dupla mais mediática da história: o heptacampeão Lewis Hamilton e o 'Príncipe de Mónaco', Charles Leclerc. O foco em Maranello está na integração perfeita da nova unidade de potência, visando acabar com o longo jejum de títulos sob o comando de Fred Vasseur.",
      "cor": Colors.red,
      "base": "Maranello, Itália",
      "motor": "Ferrari (2026 Spec)",
      "titulos": "16 Construtores",
    },
    {
      "nome": "Audi F1 Team",
      "historia":
          "A aguardada sucessora da histórica Sauber. Marca a entrada titânica do Grupo Volkswagen na Fórmula 1 como equipa de fábrica. Com a contratação do campeão da F2, o brasileiro Gabriel Bortoleto, e a experiência de Nico Hülkenberg, a Audi promete revolucionar a eficiência térmica e elétrica com o seu motor fabricado em Neuburg.",
      "cor": Colors.blueGrey,
      "base": "Neuburg, Alemanha / Hinwil, Suíça",
      "motor": "Audi Powertrains",
      "titulos": "Estreante",
    },
    {
      "nome": "Cadillac F1 Team",
      "historia":
          "A nova e explosiva 11ª equipa do paddock. Representa a entrada massiva da General Motors no Mundial. Liderada pela família Andretti, a Cadillac traz o poder americano para o grid, expandindo o campeonato para 22 carros e prometendo abalar as estruturas das equipas tradicionais desde a primeira corrida.",
      "cor": Colors.white,
      "base": "Warren, EUA / Silverstone, RU",
      "motor": "Cadillac (GM)",
      "titulos": "Estreante",
    },
    {
      "nome": "McLaren Formula 1 Team",
      "historia":
          "Mantendo a linhagem do laranja papaya, a McLaren é o símbolo da estabilidade. Lando Norris e Oscar Piastri formam uma das duplas mais letais do grid. Sob a direção de Andrea Stella, a equipa confia na sua excelência aerodinâmica e no fornecimento da nova geração de motores Mercedes para lutar pelo topo.",
      "cor": Colors.orange,
      "base": "Woking, Reino Unido",
      "motor": "Mercedes",
      "titulos": "8 Construtores",
    },
    {
      "nome": "Oracle Red Bull Racing",
      "historia":
          "Uma equipa em profunda transformação. A era pós-Adrian Newey começa com o maior desafio da sua história: fabricar a sua própria unidade de potência em parceria com a Ford (Red Bull Powertrains). Com Max Verstappen ao volante, a equipa tenta provar que consegue dominar o novo regulamento de 2026 e manter a hegemonia que conquistou na década anterior.",
      "cor": Colors.blue,
      "base": "Milton Keynes, Reino Unido",
      "motor": "Red Bull Ford",
      "titulos":
          "6 Construtores", // Títulos de 2010, 2011, 2012, 2013, 2022, 2023
    },
    {
      "nome": "Mercedes-AMG PETRONAS",
      "historia":
          "O início de um novo capítulo após a saída de Hamilton. George Russell assume o papel de líder, acompanhado pelo prodígio italiano Kimi Antonelli. A Mercedes aposta todas as fichas na sua vasta experiência em motores híbridos para criar a unidade de potência mais forte do novo regulamento de 2026.",
      "cor": Colors.teal,
      "base": "Brackley, Reino Unido",
      "motor": "Mercedes",
      "titulos": "8 Construtores",
    },
    {
      "nome": "Aston Martin Aramco",
      "historia":
          "O projeto bilionário de Lawrence Stroll atinge o seu clímax. Agora com o estatuto de equipa de fábrica da Honda (os mesmos motores que deram o título à Red Bull) e com Adrian Newey nos bastidores desenhando o carro, Fernando Alonso tem a derradeira arma para o seu tão sonhado terceiro título mundial.",
      "cor": Colors.green,
      "base": "Silverstone, Reino Unido",
      "motor": "Honda",
      "titulos": "Nenhum",
    },
    {
      "nome": "Williams Racing",
      "historia":
          "O ressurgimento de uma lenda. Com a liderança visionária de James Vowles, a equipa britânica garantiu uma dupla de peso: a agressividade de Alex Albon e a inteligência tática de Carlos Sainz. A Williams foca-se em maximizar a parceria técnica com a Mercedes para voltar aos pódios.",
      "cor": Colors.indigo,
      "base": "Grove, Reino Unido",
      "motor": "Mercedes",
      "titulos": "9 Construtores",
    },
    {
      "nome": "BWT Alpine F1 Team",
      "historia":
          "A equipa francesa passou por intensas reestruturações. Agora apoiada pela dupla Pierre Gasly e o jovem Jack Doohan, a Alpine procura encontrar a consistência que lhe tem faltado, focando-se em extrair o máximo do novo regulamento de chassis para compensar os desafios de desenvolvimento.",
      "cor": Colors.blueAccent,
      "base": "Enstone, Reino Unido / Viry, França",
      "motor": "Alpine",
      "titulos": "2 Construtores (como Renault)",
    },
    {
      "nome": "MoneyGram Haas F1 Team",
      "historia":
          "A equipa americana fortaleceu-se com a sua nova parceria técnica com a Toyota, além dos laços contínuos com a Ferrari. Com a experiência de Esteban Ocon e a rapidez do jovem britânico Oliver Bearman, a Haas tenta deixar definitivamente o fundo do grid.",
      "cor": Colors.grey,
      "base": "Kannapolis, EUA / Banbury, RU",
      "motor": "Ferrari",
      "titulos": "Nenhum",
    },
    {
      "nome": "Visa Cash App RB",
      "historia":
          "A equipa 'irmã' da Red Bull. Serve como o laboratório de excelência para os motores Red Bull-Ford e a plataforma de lançamento para jovens talentos como Yuki Tsunoda e Liam Lawson. O objetivo é competir consistentemente no topo do pelotão intermediário.",
      "cor": Colors.blueGrey,
      "base": "Faenza, Itália",
      "motor": "Red Bull Ford",
      "titulos": "Nenhum",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paddock 2026",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _equipes.length,
        itemBuilder: (context, index) {
          final eq = _equipes[index];
          return Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: eq['cor'],
                radius: 20,
                child: Text(
                  eq['nome'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                eq['nome'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                "Motor: ${eq['motor']}",
                style: TextStyle(color: Colors.red.shade400),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "História e Perspetiva 2026",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        eq['historia'],
                        style: const TextStyle(
                          height: 1.6,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                eq['titulos'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                eq['base'].toString().split(',')[0],
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TelaPerfilEquipe extends StatelessWidget {
  final Map<String, dynamic> equipe;
  const TelaPerfilEquipe({super.key, required this.equipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: equipe['cor'],
        title: Text(
          equipe['nome'],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: equipe['cor'],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Icon(
                equipe['icone'],
                size: 100,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sede de Operações",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipe['base'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "História e Evolução",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    equipe['historia'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. MAPAS INTERATIVOS ---
class TelaCircuitos extends StatelessWidget {
  const TelaCircuitos({super.key});
  @override
  Widget build(BuildContext context) {
    final corTexto = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: const Text("Circuitos Clássicos")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _circuitoCard(
            "Monza (Itália)",
            "O Templo da Velocidade",
            "As retas intermináveis onde os carros atingem as maiores velocidades do ano.",
            Icons.route,
            corTexto,
            "assets/Mapas/Monza.png",
          ),
          _circuitoCard(
            "Mônaco",
            "As Ruas do Principado",
            "A corrida mais glamorosa e imperdoável do calendário. Qualquer erro resulta em batida.",
            Icons.map,
            corTexto,
            "assets/Mapas/Mônaco.png",
          ),
          _circuitoCard(
            "Spa-Francorchamps (Bélgica)",
            "A Montanha-Russa",
            "A pista mais longa da F1, com a lendária subida cega da curva Eau Rouge.",
            Icons.timeline,
            corTexto,
            "assets/Mapas/Spa-Francorchamps.png",
          ),
          _circuitoCard(
            "Silverstone (Reino Unido)",
            "O Berço da F1",
            "Onde o primeiro GP da história foi realizado em 1950. Circuito de altíssima velocidade.",
            Icons.add_road,
            corTexto,
            "assets/Mapas/Silverstone.png",
          ),
          _circuitoCard(
            "Suzuka (Japão)",
            "O Formato em 8",
            "Uma pista lendária e técnica, a única do calendário que cruza sobre si mesma.",
            Icons.all_inclusive,
            corTexto,
            "assets/Mapas/Suzuka.png",
          ),
          _circuitoCard(
            "Interlagos (Brasil)",
            "O Templo do Automobilismo",
            "Circuito anti-horário em São Paulo. Famoso por um clima imprevisível e corridas dramáticas.",
            Icons.layers,
            corTexto,
            "assets/Mapas/Interlagos.png",
          ),
        ],
      ),
    );
  }

  Widget _circuitoCard(
    String nome,
    String subtitulo,
    String descricao,
    IconData iconeMapa,
    Color? corTexto,
    String urlMapa,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(iconeMapa, color: Colors.teal.shade800),
            ),
            title: Text(
              nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 14, height: 1.4, color: corTexto),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.white,
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(20),
              child: Image.asset(
                urlMapa,
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Center(
                  child: Text(
                    "Erro ao carregar mapa local",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Use os dois dedos para ampliar o traçado",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. GUIA DE PNEUS ---
class TelaPneus extends StatelessWidget {
  const TelaPneus({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guia de Pneus Pirelli")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "A estratégia de corrida é definida quase inteiramente pelos pneus. A Pirelli fornece borracha com características únicas.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _pneuCard(
            "Pneu Macio (Soft)",
            "Faixa Vermelha",
            "A borracha mais macia. É o pneu mais rápido, mas degrada muito rapidamente. Ideal para classificação.",
            Colors.red,
          ),
          _pneuCard(
            "Pneu Médio (Medium)",
            "Faixa Amarela",
            "O equilíbrio perfeito entre durabilidade e velocidade constante. O pneu mais utilizado nas corridas.",
            Colors.amber,
          ),
          _pneuCard(
            "Pneu Duro (Hard)",
            "Faixa Branca",
            "Borracha resistente. Demora a aquecer, mas dura quase uma corrida inteira sem perder desempenho.",
            Colors.grey[700]!,
          ),
          _pneuCard(
            "Intermediário (Inters)",
            "Faixa Verde",
            "Possui sulcos. Usado quando a pista está úmida, garoando ou secando.",
            Colors.green,
          ),
          _pneuCard(
            "Chuva Extrema (Wet)",
            "Faixa Azul",
            "Para chuva pesada. Sulcos muito profundos para escoar 85 litros de água por segundo e evitar aquaplanagem.",
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _pneuCard(
    String tipo,
    String corFaixa,
    String descricao,
    Color corPneu,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
                border: Border.all(color: corPneu, width: 4),
              ),
              child: const Center(
                child: Icon(Icons.album, color: Colors.white24, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    corFaixa,
                    style: TextStyle(
                      color: corPneu,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descricao,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. DICIONÁRIO ---
class TelaDicionario extends StatelessWidget {
  const TelaDicionario({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dicionário do Paddock")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Apex (Ápice)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "O ponto mais interior de uma curva, onde o carro fica o mais próximo possível da zebra antes de acelerar.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Blistering (Bolhas)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Quando o interior do pneu aquece demais, a borracha expande e estoura, criando bolhas que arruínam a aderência.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Box / Pit Stop"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Parada obrigatória ou estratégica onde os mecânicos trocam os quatro pneus, geralmente em menos de 3 segundos.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Chicane"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Sequência de curvas apertadas em forma de 'S', colocadas em retas para forçar os carros a reduzirem a velocidade.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Graining (Granulação)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Quando o carro desliza, pedaços de borracha se soltam, mas grudam novamente na superfície quente do pneu, tornando-o escorregadio.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Hairpin (Grampo)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Uma curva extremamente apertada, que tem um formato de 'U' e exige uma forte frenagem na entrada.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Overcut"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Tática onde o piloto permanece na pista para fazer voltas muito rápidas com o ar limpo após o adversário ir aos boxes.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Paddock"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "A área restrita atrás das garagens. Lá ficam os motorhomes, engenheiros, áreas VIP e caminhões das equipes.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Parc Fermé (Parque Fechado)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Uma área onde os carros entram após a classificação. Os mecânicos não podem mais alterar a configuração do carro.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Pit Wall (Muro dos Boxes)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Estrutura tecnológica coberta situada entre a pista e a faixa dos boxes onde os chefes monitoram telemetria e rádio.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Pole Position"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "A posição mais vantajosa da grelha de partida (1º lugar). Conquistada pelo piloto que faz a volta mais rápida na classificação.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Slipstream (Vácuo)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Seguir perto do carro da frente em uma reta. Isso cria um túnel de ar de baixa resistência que dá ganho de velocidade.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Telemetria"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Sistema eletrônico que envia milhares de canais de dados do carro para os engenheiros em tempo real.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text("Undercut"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Estratégia contrária ao Overcut. O piloto para nos boxes antes do rival para obter pneus novos e ser muito mais rápido.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 7. REGRAS BÁSICAS EXPANDIDAS ---
class TelaRegrasBasicas extends StatelessWidget {
  const TelaRegrasBasicas({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Livro de Regras F1")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            leading: Icon(Icons.timer),
            title: Text("Formato do Fim de Semana"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Sexta-feira: Treinos Livres 1 e 2 (TL1 e TL2), onde as equipes testam configurações.\nSábado: TL3 e a Qualificação, dividida em Q1 (elimina os 5 mais lentos), Q2 (elimina mais 5) e Q3 (top 10 disputam a pole position).\nDomingo: A corrida principal, com duração máxima de 2 horas ou 305 km.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.speed),
            title: Text("Corridas Sprint"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Em 6 finais de semana do ano, ocorre uma mini-corrida no sábado de 100km. A qualificação para ela acontece na sexta, e os 8 primeiros colocados marcam pontos extras (de 8 para o vencedor até 1 para o oitavo).",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.drag_indicator),
            title: Text("DRS (Asa Móvel)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "O Drag Reduction System é uma aleta na asa traseira que se abre para diminuir o atrito com o ar, dando até 15 km/h a mais de velocidade. Só pode ser ativado em zonas específicas se o piloto estiver a menos de 1 segundo do carro da frente.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.car_crash),
            title: Text("Safety Car e VSC"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Safety Car (SC): Carro real que entra na pista para agrupar o grid e limitar a velocidade durante perigos extremos.\nVirtual Safety Car (VSC): Não há carro físico, mas os pilotos devem reduzir a velocidade em 30% mantendo a distância exata entre eles.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.lock),
            title: Text("Parque Fechado (Parc Fermé)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Após o carro sair para a qualificação, ele entra em regime de 'Parque Fechado'. Os mecânicos são estritamente proibidos de trocar peças ou alterar a configuração principal da suspensão. Se quebrarem essa regra, o piloto larga do pit lane.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.pan_tool),
            title: Text("Obrigação de Pneus"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Durante uma corrida com pista seca, é obrigatório parar nos boxes pelo menos uma vez e usar dois tipos de pneus diferentes.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 8. ENGENHARIA EXPANDIDA ---
class TelaSetup extends StatelessWidget {
  const TelaSetup({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Engenharia de Pista")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "O acerto (Setup) separa um carro rápido de um carro campeão. Pequenos ângulos mudam tudo.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          SizedBox(height: 16),
          ExpansionTile(
            leading: Icon(Icons.air),
            title: Text("Aerodinâmica (Downforce)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Quanto mais inclinadas as asas, mais o vento empurra o carro contra o chão (Downforce). Isso permite curvas muito mais rápidas, mas gera 'Arrasto' (Drag), o que freia o carro nas retas. É o equilíbrio mais difícil de achar na F1.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.vertical_align_bottom),
            title: Text("Efeito Solo e Porpoising"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Canais gigantescos sob o assoalho aceleram o fluxo de ar, criando uma pressão negativa que suga o carro para o chão. Se for forte demais, o assoalho raspa no chão, perde o vácuo, o carro sobe, suga de novo e desce, criando o temido quique ('Porpoising').",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.settings_overscan),
            title: Text("Câmber e Toe (Suspensão)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Câmber Negativo: Pneus inclinados para dentro (/ \\). Aumenta brutalmente a aderência em curvas rápidas, mas desgasta a borda interna e perde contato nas retas.\nToe: Pneus apontando levemente para fora ou para dentro visto de cima, ajustando a agilidade nas entradas de curva.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.thermostat),
            title: Text("Janela Térmica de Pneus"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Pneus de F1 só aderem ao asfalto quando atingem temperaturas entre 90°C e 110°C. Se ficarem frios, deslizam no asfalto (Graining). Se aquecerem acima de 120°C, a borracha derrete de dentro para fora, criando bolhas estouradas (Blistering).",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.electrical_services),
            title: Text("Unidade de Potência (Motor)"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Não é só um motor V6 de 1.6L. É um sistema híbrido.\nMGU-K: Motor elétrico que recupera energia das frenagens.\nMGU-H: Motor elétrico acoplado ao escapamento que gera energia a partir do calor dos gases e acaba com o atraso do turbo (Turbolag). Juntos geram mais de 1000 cavalos.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 9. HALL DA FAMA ---
class TelaHallFama extends StatelessWidget {
  const TelaHallFama({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hall da Fama (Campeões)")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lendasF1.length,
        itemBuilder: (context, index) {
          final lenda = lendasF1[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Hero(
                tag: 'lenda_${lenda.nome}',
                child: CircleAvatar(
                  backgroundColor: lenda.corTema.withValues(alpha: 0.2),
                  backgroundImage: AssetImage(lenda.imagem),
                ),
              ),
              title: Text(
                lenda.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(lenda.anosTitulos),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: lenda.corTema,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaPerfilLenda(lenda: lenda),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TelaPerfilLenda extends StatelessWidget {
  final LendaF1 lenda;
  const TelaPerfilLenda({super.key, required this.lenda});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lenda.nome, style: const TextStyle(color: Colors.white)),
        backgroundColor: lenda.corTema,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: lenda.corTema,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'lenda_${lenda.nome}',
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: ClipOval(
                      child: Image(
                        image: AssetImage(lenda.imagem),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Legado",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lenda.bio,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Conquistas",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoEstatistica(
                          "Títulos",
                          lenda.anosTitulos.split(" ")[0],
                          Icons.emoji_events,
                          lenda.corTema,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _infoEstatistica(
                          "Vitórias",
                          lenda.vitorias.split(" ")[0],
                          Icons.emoji_events_outlined,
                          lenda.corTema,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoEstatistica(
                          "Poles",
                          lenda.poles.split(" ")[0],
                          Icons.timer,
                          lenda.corTema,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoEstatistica(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 36),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 10. GRÁFICO DE TELEMETRIA E PERFIL DO PILOTO ---
class TelaPerfilPiloto extends StatelessWidget {
  final dynamic piloto;
  const TelaPerfilPiloto({super.key, required this.piloto});

  Future<List<FlSpot>> _buscarHistoricoPosicoes(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.jolpi.ca/ergast/f1/current/drivers/$driverId/results.json',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> races = data['MRData']['RaceTable']['Races'];

        List<FlSpot> spots = [];
        for (var i = 0; i < races.length; i++) {
          final round = double.parse(races[i]['round']);
          final position = double.parse(races[i]['Results'][0]['position']);
          spots.add(FlSpot(round, position));
        }
        return spots;
      }
    } catch (e) {
      // Retorna lista vazia
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final nome = '${piloto['givenName']} ${piloto['familyName']}';
    final bio = obterBiografiaPiloto(piloto['driverId']);
    final nacionalidade = piloto['nationality'] ?? 'Desconhecida';
    final dataNascimento = piloto['dateOfBirth'] ?? 'Desconhecida';
    final idPiloto = piloto['driverId'] ?? 'Desconhecido';
    final numeroPermanente = piloto['permanentNumber'] ?? 'N/A';
    final corPiloto = obterCorPiloto(idPiloto);

    return Scaffold(
      appBar: AppBar(
        title: Text(nome, style: const TextStyle(color: Colors.white)),
        backgroundColor: corPiloto,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: corPiloto,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'avatar_$idPiloto',
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: ClipOval(
                      child: Image(
                        image: obterFotoPiloto(idPiloto),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resumo da Carreira",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Evolução na Temporada",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: FutureBuilder<List<FlSpot>>(
                      future: _buscarHistoricoPosicoes(idPiloto),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "Dados de corrida indisponíveis",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return LineChart(
                          LineChartData(
                            minY: 1,
                            maxY: 20,
                            clipData: FlClipData.all(),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      "Etapa ${spot.x.toInt()}\nPos: ${spot.y.toInt()}º",
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withValues(alpha: 0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      "P${value.toInt()}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: snapshot.data!,
                                isCurved: true,
                                color: corPiloto,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                            radius: 4,
                                            color: Colors.white,
                                            strokeWidth: 2,
                                            strokeColor: corPiloto,
                                          ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: corPiloto.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Dados Pessoais",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _painelDado(
                          "Número do Carro",
                          numeroPermanente,
                          Icons.confirmation_number,
                          corPiloto,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _painelDado(
                          "Nacionalidade",
                          traduzirNacionalidade(nacionalidade),
                          Icons.flag,
                          corPiloto,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _painelDado(
                          "Data de Nascimento",
                          dataNascimento,
                          Icons.cake,
                          corPiloto,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _painelDado(String titulo, String valor, IconData icone, Color cor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 30),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
