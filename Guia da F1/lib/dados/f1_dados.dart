import 'package:flutter/material.dart';

String traduzirNacionalidade(String nacionalidade) {
  final mapa = {
    'Dutch': 'Holandês',
    'British': 'Britânico',
    'Monegasque': 'Monegasco',
    'Spanish': 'Espanhol',
    'French': 'Francês',
    'Australian': 'Australiano',
    'Thai': 'Tailandês',
    'Japanese': 'Japonês',
    'Chinese': 'Chinês',
    'Mexican': 'Mexicano',
    'Canadian': 'Canadense',
    'Finnish': 'Finlandês',
    'Danish': 'Dinamarquês',
    'German': 'Alemão',
    'Italian': 'Italiano',
    'Brazilian': 'Brasileiro',
    'Argentine': 'Argentino',
    'New Zealander': 'Neozelandês',
    'American': 'Americano',
  };
  return mapa[nacionalidade] ?? nacionalidade;
}

String obterBandeira(String chave) {
  final mapaBandeiras = {
    'Dutch': '🇳🇱',
    'Netherlands': '🇳🇱',
    'British': '🇬🇧',
    'UK': '🇬🇧',
    'Great Britain': '🇬🇧',
    'Monegasque': '🇲🇨',
    'Monaco': '🇲🇨',
    'Spanish': '🇪🇸',
    'Spain': '🇪🇸',
    'French': '🇫🇷',
    'France': '🇫🇷',
    'Australian': '🇦🇺',
    'Australia': '🇦🇺',
    'Thai': '🇹🇭',
    'Thailand': '🇹🇭',
    'Japanese': '🇯🇵',
    'Japan': '🇯🇵',
    'Chinese': '🇨🇳',
    'China': '🇨🇳',
    'Mexican': '🇲🇽',
    'Mexico': '🇲🇽',
    'Canadian': '🇨🇦',
    'Canada': '🇨🇦',
    'Finnish': '🇫🇮',
    'Finland': '🇫🇮',
    'Danish': '🇩🇰',
    'Denmark': '🇩🇰',
    'German': '🇩🇪',
    'Germany': '🇩🇪',
    'Italian': '🇮🇹',
    'Italy': '🇮🇹',
    'Brazilian': '🇧🇷',
    'Brazil': '🇧🇷',
    'Argentine': '🇦🇷',
    'Argentina': '🇦🇷',
    'New Zealander': '🇳🇿',
    'New Zealand': '🇳🇿',
    'American': '🇺🇸',
    'USA': '🇺🇸',
    'United States': '🇺🇸',
    'Austrian': '🇦🇹',
    'Austria': '🇦🇹',
    'Belgian': '🇧🇪',
    'Belgium': '🇧🇪',
    'Bahrain': '🇧🇭',
    'Saudi Arabia': '🇸🇦',
    'Hungary': '🇭🇺',
    'Azerbaijan': '🇦🇿',
    'Singapore': '🇸🇬',
    'Qatar': '🇶🇦',
    'UAE': '🇦🇪',
    'Switzerland': '🇨🇭',
  };
  return mapaBandeiras[chave] ?? '🏁';
}

Color obterCorPiloto(String driverId) {
  final mapaCores = {
    'verstappen': const Color(0xFF001A30),
    'perez': const Color(0xFF001A30),
    'hamilton': const Color(0xFFDC0000),
    'leclerc': const Color(0xFFDC0000),
    'norris': const Color(0xFFE65C00),
    'piastri': const Color(0xFFE65C00),
    'russell': const Color(0xFF00A19B),
    'antonelli': const Color(0xFF00A19B),
    'alonso': const Color(0xFF006F62),
    'stroll': const Color(0xFF006F62),
    'albon': const Color(0xFF00A0DE),
    'sainz': const Color(0xFF00A0DE),
    'colapinto': const Color(0xFF00A0DE),
    'gasly': const Color(0xFFE83E8C),
    'ocon': const Color(0xFFB71C1C),
    'bearman': const Color(0xFFB71C1C),
    'hulkenberg': const Color(0xFF00A000),
    'bortoleto': const Color(0xFF00A000),
    'lawson': const Color(0xFF1534F0),
    'hadjar': const Color(0xFF1534F0),
    'lindblad': const Color(0xFF1534F0),
  };
  return mapaCores[driverId.toLowerCase()] ?? const Color(0xFFB71C1C);
}

AssetImage obterFotoPiloto(String driverId) {
  if (driverId.isEmpty) return const AssetImage('assets/WPPF1.jpg');
  final mapaNomes = {
    'verstappen': 'Verstappen.jpg',
    'max_verstappen': 'Verstappen.jpg',
    'lindblad': 'Lindblad.jpg',
    'arvid_lindblad': 'Lindblad.jpg',
    'hamilton': 'Hamilton.jpg',
    'leclerc': 'Leclerc.jpg',
    'russell': 'Russell.jpg',
    'antonelli': 'Antonelli.jpg',
    'norris': 'Norris.jpg',
    'piastri': 'Piastri.jpg',
    'ocon': 'Ocon.jpg',
    'bearman': 'Bearman.jpg',
    'gasly': 'Gasly.jpg',
    'colapinto': 'Colapinto.jpg',
    'bottas': 'Bottas.jpg',
    'perez': 'Perez.jpg',
    'albon': 'Albon.jpg',
    'sainz': 'Sainz.jpg',
    'bortoleto': 'Bortoleto.jpg',
    'hulkenberg': 'Hulkenberg.jpg',
    'lawson': 'Lawson.jpg',
    'alonso': 'Alonso.jpg',
    'stroll': 'Stroll.jpg',
    'hadjar': 'Hadjar.jpg',
    'isack_hadjar': 'Hadjar.jpg',
  };
  String nomeFicheiro =
      mapaNomes[driverId.toLowerCase()] ??
      '${driverId[0].toUpperCase()}${driverId.substring(1)}.jpg';
  return AssetImage('assets/pilotos/$nomeFicheiro');
}

String obterBiografiaPiloto(String driverId) {
  final Map<String, String> bios = {
    'max_verstappen':
        'Filho do ex-piloto de F1 Jos Verstappen, Max foi preparado desde a infância para ser uma máquina de vitórias. Estreou na F1 com apenas 17 anos. Famoso pelo seu estilo de pilotagem extremamente agressivo e implacável, conquistou o seu primeiro título mundial em 2021 numa disputa histórica na última volta contra Hamilton. Desde então, estabeleceu uma dinastia de dominância absoluta, batendo recordes sucessivos.',
    'hamilton':
        'Um dos maiores nomes da história do desporto. Lewis foi apadrinhado pela McLaren ainda no kart, estreando-se na F1 em 2007. Conquistou o seu primeiro título em 2008 na última curva no Brasil. A sua mudança ousada para a Mercedes levou-o a igualar o lendário recorde de 7 títulos mundiais de Michael Schumacher. Conhecido pela sua precisão na chuva e agora pela sua chocante transferência para a Ferrari.',
    'leclerc':
        'O "Príncipe de Mônaco". Charles Leclerc é considerado um dos maiores talentos brutos da sua geração, especialmente em voltas de qualificação. Vindo da academia da Ferrari, teve a difícil tarefa de liderar a equipa italiana após um período sombrio. Marcou o seu nome no coração dos Tifosi ao vencer de forma heroica em Monza.',
    'norris':
        'Lando iniciou a sua carreira na F1 com a McLaren como um jovem prodígio focado e, ao mesmo tempo, brincalhão. Demorou algumas temporadas para conseguir um carro competitivo, mas quando a McLaren acertou na engenharia, Lando provou ser capaz de bater de frente com Max Verstappen em ritmo puro de corrida.',
    'piastri':
        'Oscar Piastri chegou à F1 com um dos currículos mais impressionantes das categorias de base, vencendo a F3 e a F2 em anos consecutivos. Frio, calculista e extremamente maduro para a sua idade, não se deixou intimidar pelo estatuto de Lando Norris na McLaren, demonstrando um talento natural para vitórias.',
    'russell':
        'George Russell construiu a sua reputação tirando o máximo de carros pouco competitivos na Williams, ganhando a alcunha de "Sr. Sábado" pelas suas qualificações. Promovido à Mercedes, mostrou rapidamente que tem a velocidade e a inteligência tática necessárias para ser o futuro líder da equipa após a saída de Hamilton.',
    'sainz':
        'Carlos Sainz é conhecido pela sua enorme inteligência tática e capacidade de adaptação, frequentemente superando os estrategas da própria equipa. Depois de uma passagem vitoriosa pela Ferrari, onde conquistou vitórias marcantes, assumiu o desafio de liderar a reconstrução da Williams no projeto a longo prazo.',
    'alonso':
        'Uma verdadeira lenda viva. Fernando Alonso, bicampeão do mundo (2005 e 2006), é famoso por extrair 110% de qualquer carro que pilota. Com uma longevidade inédita na F1, continua a demonstrar aos quarenta e poucos anos reflexos de um novato e uma agressividade nas defesas e ultrapassagens que assusta os rivais mais jovens.',
    'albon':
        'Alexander Albon teve uma ascensão meteórica e uma queda igualmente rápida na Red Bull, mas encontrou a sua redenção na Williams. Tornou-se o pilar da equipa britânica, conquistando pontos improváveis com defesas de posição geniais e uma gestão de pneus que se tornou a sua marca registada.',
    'perez':
        'Sergio "Checo" Pérez é o orgulho do México e um mestre reconhecido na preservação de pneus. O seu auge foi a memorável defesa contra Hamilton em Abu Dhabi 2021, que o coroou como "Ministro da Defesa". Apesar de altos e baixos, a sua experiência torna-o num trunfo valioso no exigente ambiente da Red Bull.',
    'stroll':
        'Lance Stroll tem frequentemente de lidar com o rótulo de "filho do dono", mas já provou o seu talento com pódios e uma pole position em condições de chuva extremas. A sua capacidade em arranques e nas primeiras voltas é notável, procurando sempre consolidar a sua posição na ambiciosa Aston Martin.',
    'gasly':
        'Pierre Gasly é um piloto de enorme resiliência emocional. Depois de uma passagem difícil pela Red Bull, reergueu-se de forma espetacular na Toro Rosso/AlphaTauri, vencendo o dramático GP de Itália de 2020. Agora lidera o projeto da Alpine, tentando elevar o orgulho francês na categoria.',
    'ocon':
        'Esteban Ocon é famoso por não facilitar a vida a ninguém em pista, seja adversário ou companheiro de equipa. A sua jornada rumo à F1 foi marcada por dificuldades financeiras, o que moldou o seu caráter de lutador implacável. Venceu um caótico GP da Hungria e abraçou o projeto da Haas para 2025.',
    'bottas':
        'Valtteri Bottas foi uma peça fundamental na dinastia de construtores da Mercedes, conquistando várias vitórias. Mais relaxado e focado após sair da equipa alemã, assumiu um papel de liderança na Sauber, ajudando a preparar o terreno para a transição massiva que a Audi fará na estrutura da equipa.',
    'hulkenberg':
        'Nico Hülkenberg, o veterano alemão, detém o recorde indesejado de mais corridas sem um pódio, mas é inegavelmente um dos pilotos mais rápidos e fiáveis do pelotão em ritmo de qualificação. A sua consistência incrível na Haas valeu-lhe um convite de ouro para ser o rosto do futuro projeto de fábrica da Audi.',
    'antonelli':
        'Andrea Kimi Antonelli é considerado um talento geracional. Pulou diretamente da Fórmula Regional para a Fórmula 2 e, impressionando nos testes privados da Mercedes, foi escolhido para substituir o lendário Lewis Hamilton. A pressão é imensa, mas a sua velocidade pura é vista como o futuro da F1.',
    'bearman':
        'O jovem britânico Oliver "Ollie" Bearman chocou o mundo ao substituir Carlos Sainz de emergência no GP da Arábia Saudita de 2024 e pontuar com a Ferrari. Este feito carimbou o seu passaporte para uma vaga a tempo inteiro na Haas em 2025, sendo uma das maiores promessas vindas da F2.',
    'bortoleto':
        'Gabriel Bortoleto recolocou a bandeira do Brasil na grelha da F1! Com um talento cerebral e uma capacidade ímpar de gerir campeonatos (venceu a F3 no ano de estreia), foi recrutado pelo projeto Sauber/Audi para trazer sangue novo e estabilidade. A esperança de toda uma nação recai sobre a sua destreza ao volante.',
    'colapinto':
        'Franco Colapinto incendiou o fanatismo sul-americano. O argentino aproveitou ao máximo as suas oportunidades no meio da temporada de 2024, demonstrando uma agressividade controlada e uma velocidade impressionante que garantiram a sua presença no circo da Fórmula 1 para alegria da incansável "La Doce".',
    'lawson':
        'Liam Lawson provou ser o super-reserva definitivo da Red Bull antes de conquistar o seu merecido lugar na Racing Bulls (RB). Frio sob pressão e muito agressivo em combate roda a roda, o neozelandês é a grande aposta de Helmut Marko para o futuro a curto prazo da estrutura austríaca.',
    'hadjar':
        'Isack Hadjar é um produto bruto da academia da Red Bull, conhecido pelas suas explosões de raiva no rádio e por um pé direito pesado que destrói cronómetros. O seu sucesso na F2 convenceu os responsáveis de que ele está pronto para o maior desafio de todos na garagem da RB F1 Team.',
    'lindblad':
        'Arvid Lindblad é mais uma joia da academia da Red Bull que saltou etapas devido ao seu ritmo absurdo na Fórmula 3. Apesar de extremamente jovem, o britânico mostrou uma maturidade invejável em batalhas em pista, o que o catapultou rapidamente para as altas esferas do automobilismo.',
  };

  return bios[driverId.toLowerCase()] ??
      'A trajetória deste piloto nas categorias de base do desporto automóvel até chegar à elite da Fórmula 1 é marcada por talento, resistência física e inteligência tática, fundamentais para sobreviver no ambiente mais competitivo do mundo a mais de 300 km/h.';
}

class LendaF1 {
  final String nome, anosTitulos, vitorias, poles, bio, imagem;
  final Color corTema;
  LendaF1(
    this.nome,
    this.anosTitulos,
    this.vitorias,
    this.poles,
    this.bio,
    this.imagem,
    this.corTema,
  );
}

final List<LendaF1> lendasF1 = [
  LendaF1(
    "Michael Schumacher",
    "7 Títulos (1994, 1995, 2000-2004)",
    "91 Vitórias",
    "68 Poles",
    "O 'Kaiser' alemão redefiniu o que significava ser um piloto profissional liderando a era de ouro da Ferrari no início dos anos 2000.",
    "assets/hall/Schumacher.png",
    const Color(0xFFC62828),
  ),
  LendaF1(
    "Lewis Hamilton",
    "7 Títulos (2008, 2014, 2015, 2017-2020)",
    "105+ Vitórias",
    "104+ Poles",
    "Recordista absoluto de vitórias e pole positions na história da Fórmula 1. A lenda viva da era híbrida.",
    "assets/pilotos/Hamilton.jpg",
    const Color(0xFFDC0000),
  ),
  LendaF1(
    "Juan Manuel Fangio",
    "5 Títulos (1951, 1954-1957)",
    "24 Vitórias",
    "29 Poles",
    "O 'Maestro' argentino dominou a primeira década da F1 vencendo campeonatos por quatro montadoras diferentes.",
    "assets/hall/Fangio.jpg",
    const Color(0xFF795548),
  ),
  LendaF1(
    "Alain Prost",
    "4 Títulos (1985, 1986, 1989, 1993)",
    "51 Vitórias",
    "33 Poles",
    "Conhecido como 'O Professor', era um mestre da estratégia e o grande arquirrival de Ayrton Senna.",
    "assets/hall/Prost.jpg",
    const Color(0xFF37474F),
  ),
  LendaF1(
    "Sebastian Vettel",
    "4 Títulos (2010-2013)",
    "53 Vitórias",
    "57 Poles",
    "O menino prodígio que quebrou recordes de precocidade varrendo os campeonatos com o domínio da Red Bull.",
    "assets/hall/Vettel.jpg",
    const Color(0xFFC62828),
  ),
  LendaF1(
    "Max Verstappen",
    "4 Títulos (2021-2024)",
    "80+ Vitórias",
    "40+ Poles",
    "O talento geracional absoluto que reescreveu os recordes com uma pilotagem incrivelmente agressiva.",
    "assets/pilotos/Verstappen.jpg",
    const Color(0xFF001A30),
  ),
  LendaF1(
    "Ayrton Senna",
    "3 Títulos (1988, 1990, 1991)",
    "41 Vitórias",
    "65 Poles",
    "O herói brasileiro e ídolo global. Possuía uma velocidade transcendental e uma maestria incomparável na chuva.",
    "assets/hall/Senna.jpg",
    const Color(0xFFD32F2F),
  ),
  LendaF1(
    "Niki Lauda",
    "3 Títulos (1975, 1977, 1984)",
    "25 Vitórias",
    "24 Poles",
    "A personificação da resiliência e cálculo, sobrevivendo a um acidente brutal e voltando a ser campeão.",
    "assets/hall/Lauda.jpg",
    const Color(0xFF424242),
  ),
];
