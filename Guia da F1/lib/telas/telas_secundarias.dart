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

// --- 3. EQUIPES COM HISTÓRIA E EVOLUÇÃO ---
class TelaEquipes extends StatelessWidget {
  const TelaEquipes({super.key});

  final List<Map<String, dynamic>> _equipesDados = const [
    {
      "nome": "Scuderia Ferrari",
      "base": "Maranello, Itália",
      "cor": Color(0xFFDC0000),
      "icone": Icons.shield,
      "historia":
          "A única equipe que esteve presente em todas as temporadas da história da Fórmula 1, desde 1950. Fundada pelo comendador Enzo Ferrari, a equipe construiu o maior império do automobilismo. Passou por secas severas de títulos, mas viveu a sua era de ouro no início dos anos 2000 com a hegemonia de Michael Schumacher. É considerada o coração emocional do desporto.",
    },
    {
      "nome": "McLaren Racing",
      "base": "Woking, Reino Unido",
      "cor": Color(0xFFE65C00),
      "icone": Icons.sports_motorsports,
      "historia":
          "Fundada em 1966 pelo piloto e engenheiro neozelandês Bruce McLaren. A equipe é eternamente lembrada pelas cores branco e vermelho da era de Ayrton Senna e Alain Prost, onde dominou o desporto. Nos últimos anos, regressou à sua cor original de fundação, o histórico Laranja Papaya, e ressurgiu na grelha através de reestruturações técnicas profundas.",
    },
    {
      "nome": "Red Bull Racing",
      "base": "Milton Keynes, Reino Unido",
      "cor": Color(0xFF001A30),
      "icone": Icons.bolt,
      "historia":
          "A equipe nasceu após a fabricante de energéticos comprar a fracassada operação da Jaguar em 2005. Liderada pelo gênio da aerodinâmica Adrian Newey, a Red Bull quebrou a tradição de construtoras tradicionais, dominando o desporto com Sebastian Vettel (4 títulos) e posteriormente criando um novo império avassalador com Max Verstappen.",
    },
    {
      "nome": "Mercedes-AMG F1",
      "base": "Brackley, Reino Unido",
      "cor": Color(0xFF00A19B),
      "icone": Icons.adjust,
      "historia":
          "Embora a Mercedes tenha dominado nos anos 50 com Juan Manuel Fangio, a equipe moderna nasceu da compra da Brawn GP em 2010. Com o início da Era Híbrida (motores V6) em 2014, a Mercedes construiu a maior e mais implacável dinastia da história da F1, conquistando 8 campeonatos consecutivos de construtores, a maioria pelas mãos de Lewis Hamilton.",
    },
    {
      "nome": "Aston Martin Aramco",
      "base": "Silverstone, Reino Unido",
      "cor": Color(0xFF006F62),
      "icone": Icons.security,
      "historia":
          "A lendária marca britânica retornou à F1 em 2021. Liderada pelo bilionário Lawrence Stroll e com investimentos massivos em uma nova fábrica, a equipe busca se estabelecer como uma força dominante nas próximas temporadas, misturando veteranos de peso com infraestrutura de ponta.",
    },
    {
      "nome": "Alpine F1 Team",
      "base": "Enstone, Reino Unido / Viry, França",
      "cor": Color(0xFFE83E8C),
      "icone": Icons.terrain,
      "historia":
          "Representante do grupo Renault, a Alpine carrega o orgulho francês na F1. A equipe tem uma história rica (antiga Benetton e Renault), mas passa por um longo processo de reestruturação para tentar voltar aos dias de glória das vitórias de Fernando Alonso nos anos 2000.",
    },
    {
      "nome": "Williams Racing",
      "base": "Grove, Reino Unido",
      "cor": Color(0xFF00A0DE),
      "icone": Icons.speed,
      "historia":
          "Uma das equipes mais icônicas e tradicionais do grid, ostentando 9 títulos de construtores. Após anos de extremas dificuldades financeiras e de andar no fundo do pelotão, foi comprada por um grupo de investimentos e iniciou um sério projeto de reconstrução a longo prazo.",
    },
    {
      "nome": "Visa Cash App RB",
      "base": "Faenza, Itália",
      "cor": Color(0xFF1534F0),
      "icone": Icons.animation,
      "historia":
          "Anteriormente conhecida como Toro Rosso e AlphaTauri, é a equipe coirmã da Red Bull. Tradicionalmente usada como um laboratório para revelar jovens talentos das categorias de base, hoje busca ter uma identidade própria e maior competitividade no meio do pelotão.",
    },
    {
      "nome": "Haas F1 Team",
      "base": "Kannapolis, EUA",
      "cor": Color(0xFFB71C1C),
      "icone": Icons.flag,
      "historia":
          "A única equipe americana no grid. Fundada por Gene Haas, adota um modelo de negócios único, comprando o máximo de peças permitidas diretamente da Ferrari para reduzir custos. Conhecida por sua resiliência e por fazer muito com um dos menores orçamentos da F1.",
    },
    {
      "nome": "Stake F1 Team Kick Sauber",
      "base": "Hinwil, Suíça",
      "cor": Color(0xFF00E701),
      "icone": Icons.casino,
      "historia":
          "A histórica equipe independente Sauber está em um profundo período de transição. Após correr alguns anos sob o nome Alfa Romeo, a estrutura suíça prepara o terreno para ser assumida integralmente pela Audi em 2026, transformando-se em uma equipe de fábrica alemã.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Garagem das Equipes")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _equipesDados.length,
        itemBuilder: (context, index) {
          final eq = _equipesDados[index];
          return _equipeCard(context, eq);
        },
      ),
    );
  }

  Widget _equipeCard(BuildContext context, Map<String, dynamic> eq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TelaPerfilEquipe(equipe: eq)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: eq['cor'],
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6),
                  ],
                ),
                child: Icon(eq['icone'], color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eq['nome'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          eq['base'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: eq['cor'], size: 16),
            ],
          ),
        ),
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
