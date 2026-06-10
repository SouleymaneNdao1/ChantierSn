// main.dart — ChantierSN | Pape Souleymane Ndao — ESMT DAR26
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════
//  PALETTE — inspirée du Sénégal et du BTP
// ══════════════════════════════════════════════════════════
const _kVert       = Color(0xFF0A3D1F); // vert sombre (forêt)
const _kVertClair  = Color(0xFF1B5E20); // vert standard
const _kOr         = Color(0xFFFFD600); // jaune or
const _kSable      = Color(0xFFF4F0E8); // fond sable chaud
const _kTexte      = Color(0xFF1A1A1A); // texte principal
const _kGris       = Color(0xFF8A8A8A); // texte secondaire

// ══════════════════════════════════════════════════════════
//  MODÈLE
// ══════════════════════════════════════════════════════════

// Les 3 types de chantier possibles — enum pour éviter les typos
enum TypeChantier { route, pont, batiment }

// Classe immuable représentant un chantier d'infrastructure
class Chantier {
  final String id;
  final String nom;
  final TypeChantier type;
  final int avancement; // 0-100
  final int budget;     // en FCFA
  final DateTime dateFinPrevue;

  const Chantier({
    required this.id,
    required this.nom,
    required this.type,
    required this.avancement,
    required this.budget,
    required this.dateFinPrevue,
  });

  // true si avancement < 50 ET moins de 30 jours restants
  bool estEnRetard() => avancement < 50 && joursRestants() < 30;

  // difference().inDays calcule les jours entre aujourd'hui et la date limite
  int joursRestants() => dateFinPrevue.difference(DateTime.now()).inDays;

  // Crée une copie avec certains champs modifiés (pattern copyWith)
  Chantier copyWith({
    String? id, String? nom, TypeChantier? type,
    int? avancement, int? budget, DateTime? dateFinPrevue,
  }) => Chantier(
    id: id ?? this.id, nom: nom ?? this.nom, type: type ?? this.type,
    avancement: avancement ?? this.avancement, budget: budget ?? this.budget,
    dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
  );
}

// ══════════════════════════════════════════════════════════
//  DONNÉES INITIALES — sources : CETUD, APIX, AGEROUTE
// ══════════════════════════════════════════════════════════

final List<Chantier> chantiersInitiaux = [
  Chantier(id:'c1', nom:'BRT Dakar', type:TypeChantier.route,
      avancement:65, budget:394000000000, dateFinPrevue:DateTime(2025,12,31)),
  Chantier(id:'c2', nom:'TER Dakar-Diamniadio', type:TypeChantier.pont,
      avancement:82, budget:568000000000, dateFinPrevue:DateTime(2024,6,30)),
  Chantier(id:'c3', nom:'Autoroute Ila Touba', type:TypeChantier.route,
      avancement:90, budget:260000000000, dateFinPrevue:DateTime(2024,3,1)),
];

// ══════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════

// Formate 394000000000 → "394 000 000 000 FCFA"
String formatBudget(int montant) {
  final s = montant.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} FCFA';
}

// Formate DateTime(2025,12,31) → "31 décembre 2025"
String formatDate(DateTime d) {
  const mois = {1:'janvier',2:'février',3:'mars',4:'avril',5:'mai',
    6:'juin',7:'juillet',8:'août',9:'septembre',10:'octobre',
    11:'novembre',12:'décembre'};
  return '${d.day} ${mois[d.month]} ${d.year}';
}

// Couleur de type : route=vert, pont=bleu, batiment=orange
Color couleurType(TypeChantier t) {
  switch (t) {
    case TypeChantier.route:    return const Color(0xFF1B5E20);
    case TypeChantier.pont:     return const Color(0xFF1565C0);
    case TypeChantier.batiment: return const Color(0xFFE65100);
  }
}

// Libellé français du type
String libelleType(TypeChantier t) {
  switch (t) {
    case TypeChantier.route:    return 'ROUTE';
    case TypeChantier.pont:     return 'PONT';
    case TypeChantier.batiment: return 'BÂTIMENT';
  }
}

// Couleur de progression : rouge < 40, orange < 70, vert ≥ 70
Color couleurProg(int v) {
  if (v < 40) return Colors.red.shade700;
  if (v < 70) return Colors.orange.shade700;
  return Colors.green.shade700;
}

// ══════════════════════════════════════════════════════════
//  CUSTOM PAINTER — anneau de progression circulaire
//  CustomPainter pour dessiner un arc sans package externe
// ══════════════════════════════════════════════════════════
class _AnnPainter extends CustomPainter {
  final double valeur; // 0.0 à 1.0
  final Color couleur;
  const _AnnPainter(this.valeur, this.couleur);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r  = size.width / 2 - 6;
    // Fond gris de l'anneau
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.grey.shade200
                ..style = PaintingStyle.stroke
                ..strokeWidth = 7);
    // Arc coloré représentant l'avancement
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -3.14159 / 2,          // départ en haut (12h)
      2 * 3.14159 * valeur,  // angle proportionnel à la valeur
      false,
      Paint()..color = couleur
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..strokeCap = StrokeCap.round,
    );
  }
  @override
  bool shouldRepaint(_AnnPainter old) => old.valeur != valeur;
}

// ══════════════════════════════════════════════════════════
//  MAIN + WIDGET RACINE
// ══════════════════════════════════════════════════════════

void main() => runApp(const ChantierApp());

// StatefulWidget racine : détient la List<Chantier> centrale
// setState() propagé à tous les écrans via callbacks
class ChantierApp extends StatefulWidget {
  const ChantierApp({super.key});
  @override State<ChantierApp> createState() => _ChantierAppState();
}

class _ChantierAppState extends State<ChantierApp> {
  List<Chantier> _chantiers = List.from(chantiersInitiaux);

  // setState() ici → rebuild de tout l'arbre au-dessous
  void _ajouter(Chantier c)     => setState(() => _chantiers.add(c));
  void _modifier(Chantier c)    => setState(() {
    final i = _chantiers.indexWhere((e) => e.id == c.id);
    if (i != -1) _chantiers[i] = c;
  });
  void _supprimer(String id)    => setState(() =>
      _chantiers.removeWhere((c) => c.id == id));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChantierSN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: _kVertClair),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // ── Fond global commun à tous les écrans ─────────────────────────
      builder: (context, child) => Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/infrastructure.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.58)),
          ),
          child!,
        ],
      ),
      initialRoute: '/liste',
      onGenerateRoute: (s) {
        switch (s.name) {
          case '/liste':
            return MaterialPageRoute(builder: (_) => ListeScreen(
              chantiers: _chantiers, onAjouter: _ajouter,
              onModifier: _modifier, onSupprimer: _supprimer,
            ));
          case '/detail':
            final a = s.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => DetailScreen(
              chantier: a['chantier'] as Chantier,
              onSupprimer: a['onSupprimer'] as Function,
              onModifier: a['onModifier'] as Function,
            ));
          case '/formulaire':
            final a = s.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => FormulaireScreen(
              onAjouter: a['onAjouter'] as Function,
              onModifier: a['onModifier'] as Function,
              chantier: a['chantier'] as Chantier?,
            ));
          case '/apropos':
            return MaterialPageRoute(builder: (_) => const AProposScreen());
          default:
            return MaterialPageRoute(builder: (_) =>
                const Scaffold(body: Center(child: Text('Route inconnue'))));
        }
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WIDGET : ChantierCard
//  StatelessWidget — affichage pur, reçoit tout en paramètre
//  Design : bordure gauche épaisse (type) + anneau de progression
// ══════════════════════════════════════════════════════════
class ChantierCard extends StatelessWidget {
  final Chantier chantier;
  final VoidCallback onTap;
  const ChantierCard({super.key, required this.chantier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final couleur = couleurType(chantier.type);
    final prog    = chantier.avancement / 100;
    final jours   = chantier.joursRestants();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          // Bordure gauche épaisse colorée = identité du type de chantier
          border: Border(left: BorderSide(color: couleur, width: 5)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(2, 4),
          )],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            children: [
              // ── Colonne gauche : infos texte ────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge type : rectangle sans arrondi = style industriel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal:7, vertical:3),
                      color: couleur,
                      child: Text(libelleType(chantier.type),
                        style: const TextStyle(
                          color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: 1.2,
                        )),
                    ),
                    const SizedBox(height: 8),
                    // Nom du chantier en gras
                    Text(chantier.nom,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: _kTexte,
                      )),
                    const SizedBox(height: 6),
                    // Budget formaté
                    Text(formatBudget(chantier.budget),
                      style: const TextStyle(fontSize: 11, color: _kGris)),
                    const SizedBox(height: 4),
                    // Délai : rouge si dépassé
                    Row(children: [
                      Icon(
                        jours < 0 ? Icons.warning_rounded : Icons.schedule,
                        size: 13,
                        color: jours < 0 ? Colors.red.shade700 : _kGris,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        jours < 0 ? '${jours.abs()} j dépassé' : 'J-$jours jours',
                        style: TextStyle(
                          fontSize: 11,
                          color: jours < 0 ? Colors.red.shade700 : _kGris,
                          fontWeight: jours < 0 ? FontWeight.bold : FontWeight.normal,
                        )),
                    ]),
                    // Badge EN RETARD si condition remplie
                    if (chantier.estEnRetard()) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal:6, vertical:2),
                        color: Colors.red.shade700,
                        child: const Text('⚠ EN RETARD',
                          style: TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.bold, letterSpacing: 1,
                          )),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Anneau de progression circulaire (CustomPaint) ──
              SizedBox(
                width: 68, height: 68,
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(
                    size: const Size(68, 68),
                    painter: _AnnPainter(prog, couleurProg(chantier.avancement)),
                  ),
                  Text('${chantier.avancement}%',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900,
                      color: couleurProg(chantier.avancement),
                    )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ÉCRAN 1 : ListeScreen (/liste) — StatefulWidget
//  StatefulWidget car _filtreActif (bool local) change l'affichage
// ══════════════════════════════════════════════════════════
class ListeScreen extends StatefulWidget {
  final List<Chantier> chantiers;
  final Function onAjouter, onModifier, onSupprimer;
  const ListeScreen({super.key, required this.chantiers,
    required this.onAjouter, required this.onModifier, required this.onSupprimer});
  @override State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  // Filtre local : setState() bascule entre tous / avancement > 80%
  bool _filtreActif = false;

  List<Chantier> get _affiches => _filtreActif
      ? widget.chantiers.where((c) => c.avancement > 80).toList()
      : widget.chantiers;

  // Stats calculées depuis la liste pour le header dashboard
  int get _budgetTotal  => widget.chantiers.fold(0, (s, c) => s + c.budget);
  int get _avgAvancement => widget.chantiers.isEmpty ? 0 :
      widget.chantiers.fold(0, (s, c) => s + c.avancement) ~/ widget.chantiers.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ── AppBar custom avec header stats ─────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.black.withValues(alpha: 0.55),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                  // Overlay additionnel sur la zone du header pour accentuer la lisibilité
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.50),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Contenu texte par-dessus l'overlay
                  SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre + actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ChantierSN 🇸🇳',
                                  style: TextStyle(color: _kOr, fontSize: 22,
                                      fontWeight: FontWeight.w900, letterSpacing: 1)),
                                const Text('Suivi d\'infrastructure',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ]),
                            Row(children: [
                              // Bouton filtre — setState() bascule _filtreActif
                              _IconBtn(
                                icon: Icons.filter_list,
                                actif: _filtreActif,
                                onTap: () => setState(() => _filtreActif = !_filtreActif),
                              ),
                              const SizedBox(width: 8),
                              _IconBtn(
                                icon: Icons.info_outline,
                                onTap: () => Navigator.pushNamed(context, '/apropos'),
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ── 3 stats en ligne ─────────────────────
                        Row(children: [
                          _StatBox(
                            label: 'CHANTIERS',
                            valeur: '${widget.chantiers.length}',
                          ),
                          const SizedBox(width: 10),
                          _StatBox(
                            label: 'AVG AVANCEMENT',
                            valeur: '$_avgAvancement%',
                          ),
                          const SizedBox(width: 10),
                          _StatBox(
                            label: 'BUDGET TOTAL',
                            valeur: _formatMilliards(_budgetTotal),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),       // ferme SafeArea
                ]),      // ferme children: [ du Stack + Stack
            ),           // ferme FlexibleSpaceBar
            // Barre du filtre actif → fond or pour signaler le mode filtré
            title: _filtreActif
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: _kOr,
                    child: const Text('Filtre : > 80%',
                      style: TextStyle(color: Colors.black,
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  )
                : null,
          ),

          // ── Liste des chantiers ──────────────────────────
          _affiches.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.construction, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(_filtreActif ? 'Aucun chantier > 80%' : 'Aucun chantier',
                          style: TextStyle(color: Colors.grey[500])),
                      ]),
                  ))
              : SliverPadding(
                  padding: const EdgeInsets.only(top: 12, bottom: 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final c = _affiches[i];
                        return ChantierCard(
                          chantier: c,
                          onTap: () => Navigator.pushNamed(ctx, '/detail',
                            // On passe le chantier + callbacks en arguments
                            arguments: {'chantier': c,
                              'onSupprimer': widget.onSupprimer,
                              'onModifier': widget.onModifier}),
                        );
                      },
                      childCount: _affiches.length,
                    ),
                  ),
                ),
        ],
      ),
      // FAB → formulaire de création (chantier: null = mode création)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kOr,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.pushNamed(context, '/formulaire',
          arguments: {'onAjouter': widget.onAjouter,
            'onModifier': widget.onModifier, 'chantier': null}),
      ),
    );
  }

  // Formate les milliards : 394000000000 → "394 Mds"
  String _formatMilliards(int v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(0)} Mds';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)} M';
    return v.toString();
  }
}

// Widget bouton icône dans le header (petite capsule)
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool actif;
  const _IconBtn({required this.icon, required this.onTap, this.actif = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: actif ? _kOr : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: actif ? Colors.black : Colors.white, size: 20),
    ),
  );
}

// Widget stat dans le header (chiffre gros + label petit)
class _StatBox extends StatelessWidget {
  final String label, valeur;
  const _StatBox({required this.label, required this.valeur});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(valeur, style: const TextStyle(
            color: _kOr, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(
            color: Colors.white70, fontSize: 9, letterSpacing: 0.8)),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════
//  ÉCRAN 2 : DetailScreen (/detail) — StatelessWidget
//  Tout vient des arguments, aucun état local
// ══════════════════════════════════════════════════════════
class DetailScreen extends StatelessWidget {
  final Chantier chantier;
  final Function onSupprimer, onModifier;
  const DetailScreen({super.key, required this.chantier,
    required this.onSupprimer, required this.onModifier});

  @override
  Widget build(BuildContext context) {
    final couleur = couleurType(chantier.type);
    final prog    = chantier.avancement / 100;
    final jours   = chantier.joursRestants();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        // ── En-tête deux tons : fond vert sombre ────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF071F0F), Color(0xFF1B5E20)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Grand anneau circulaire de progression
                      SizedBox(width: 90, height: 90,
                        child: Stack(alignment: Alignment.center, children: [
                          CustomPaint(
                            size: const Size(90, 90),
                            painter: _AnnPainter(prog, _kOr),
                          ),
                          Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${chantier.avancement}%',
                                style: const TextStyle(
                                  color: _kOr, fontSize: 18,
                                  fontWeight: FontWeight.w900)),
                            ]),
                        ]),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge type angulaire
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            color: couleur,
                            child: Text(libelleType(chantier.type),
                              style: const TextStyle(
                                color: Colors.white, fontSize: 10,
                                fontWeight: FontWeight.w800, letterSpacing: 1.2,
                              )),
                          ),
                          const SizedBox(height: 8),
                          Text(chantier.nom,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.w900,
                            )),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Corps : grille d'infos ───────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Grille 2×2 des indicateurs clés
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _InfoTile(
                    icone: Icons.account_balance_wallet_outlined,
                    label: 'BUDGET',
                    valeur: formatBudget(chantier.budget),
                    couleur: _kVertClair,
                  ),
                  _InfoTile(
                    icone: Icons.calendar_today_outlined,
                    label: 'DATE FIN',
                    valeur: formatDate(chantier.dateFinPrevue),
                    couleur: const Color(0xFF1565C0),
                  ),
                  _InfoTile(
                    icone: Icons.timer_outlined,
                    label: 'DÉLAI',
                    valeur: jours < 0 ? '${jours.abs()} j dépassé' : 'J-$jours jours',
                    couleur: jours < 0 ? Colors.red.shade700 : Colors.orange.shade700,
                  ),
                  _InfoTile(
                    icone: Icons.trending_up,
                    label: 'STATUT',
                    valeur: chantier.avancement >= 80 ? 'En bonne voie'
                        : chantier.estEnRetard() ? 'En retard' : 'En cours',
                    couleur: chantier.estEnRetard()
                        ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ],
              ),

              // Alerte retard conditionnelle
              if (chantier.estEnRetard()) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border(
                        left: BorderSide(color: Colors.red.shade700, width: 4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade700, size: 22),
                    const SizedBox(width: 10),
                    Text('Ce chantier est EN RETARD !',
                      style: TextStyle(
                        color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ],

              const SizedBox(height: 28),

              // ── Boutons Modifier / Supprimer ─────────────
              Row(children: [
                Expanded(child: _BtnAction(
                  label: 'MODIFIER',
                  icone: Icons.edit_outlined,
                  fond: _kVertClair,
                  onTap: () => Navigator.pushNamed(context, '/formulaire',
                    // On passe le chantier existant → mode édition
                    arguments: {'onAjouter': (_){},
                      'onModifier': onModifier, 'chantier': chantier}),
                )),
                const SizedBox(width: 12),
                Expanded(child: _BtnAction(
                  label: 'SUPPRIMER',
                  icone: Icons.delete_outline,
                  fond: Colors.red.shade700,
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Supprimer ?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('Voulez-vous supprimer\n"${chantier.nom}" ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx), // ferme dialog
                          child: const Text('Annuler')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white),
                          onPressed: () {
                            onSupprimer(chantier.id);
                            Navigator.pop(ctx);     // ferme dialog
                            Navigator.pop(context); // revient à la liste
                          },
                          child: const Text('Supprimer')),
                      ],
                    ),
                  ),
                )),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

// Tuile d'info pour la grille DetailScreen
class _InfoTile extends StatelessWidget {
  final IconData icone;
  final String label, valeur;
  final Color couleur;
  const _InfoTile({required this.icone, required this.label,
    required this.valeur, required this.couleur});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: couleur, width: 3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            fontSize: 9, color: couleur,
            fontWeight: FontWeight.w800, letterSpacing: 1,
          )),
        ]),
        Text(valeur, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: _kTexte,
        ), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
  );
}

// Bouton action (Modifier / Supprimer)
class _BtnAction extends StatelessWidget {
  final String label;
  final IconData icone;
  final Color fond;
  final VoidCallback onTap;
  const _BtnAction({required this.label, required this.icone,
    required this.fond, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: fond,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icone, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1,
        )),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════
//  ÉCRAN 3 : FormulaireScreen (/formulaire) — StatefulWidget
//  StatefulWidget car Slider et DatePicker modifient l'état
// ══════════════════════════════════════════════════════════
class FormulaireScreen extends StatefulWidget {
  final Function onAjouter, onModifier;
  final Chantier? chantier; // null = création, non-null = édition
  const FormulaireScreen({super.key, required this.onAjouter,
    required this.onModifier, this.chantier});
  @override State<FormulaireScreen> createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen> {
  // GlobalKey pour appeler validate() sur le Form
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomCtrl, _budgetCtrl, _dateCtrl;
  late TypeChantier _type;
  late double _avancement;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    // Mode édition : pré-remplissage depuis widget.chantier
    final c = widget.chantier;
    _nomCtrl    = TextEditingController(text: c?.nom ?? '');
    _budgetCtrl = TextEditingController(text: c?.budget.toString() ?? '');
    _type       = c?.type ?? TypeChantier.route;
    _avancement = c?.avancement.toDouble() ?? 0;
    _date       = c?.dateFinPrevue;
    _dateCtrl   = TextEditingController(text: c != null ? formatDate(c.dateFinPrevue) : '');
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _budgetCtrl.dispose(); _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2035),
    );
    if (d != null) setState(() { // setState pour afficher la date choisie
      _date = d;
      _dateCtrl.text = formatDate(d);
    });
  }

  void _sauvegarder() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une date de fin')));
      return;
    }
    final modeEdition = widget.chantier != null;
    if (modeEdition) {
      widget.onModifier(widget.chantier!.copyWith(
        nom: _nomCtrl.text.trim(), type: _type,
        avancement: _avancement.round(),
        budget: int.parse(_budgetCtrl.text.trim()),
        dateFinPrevue: _date,
      ));
    } else {
      widget.onAjouter(Chantier(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        nom: _nomCtrl.text.trim(), type: _type,
        avancement: _avancement.round(),
        budget: int.parse(_budgetCtrl.text.trim()),
        dateFinPrevue: _date!,
      ));
    }
    Navigator.pop(context); // retour à l'écran précédent
  }

  @override
  Widget build(BuildContext context) {
    final modeEdition = widget.chantier != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        foregroundColor: Colors.white,
        title: Text(modeEdition ? 'Modifier le chantier' : 'Nouveau chantier',
          style: const TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Nom ────────────────────────────────────────
            _labelChamp('NOM DU CHANTIER'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nomCtrl,
              decoration: _deco(hint: 'Ex: BRT Dakar', icone: Icons.construction),
              textCapitalization: TextCapitalization.words,
              // validator retourne null si valide, sinon le message d'erreur
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Minimum 3 caractères' : null,
            ),
            const SizedBox(height: 20),

            // ── Type : DropdownButton car 3 valeurs fixes (enum) ──
            _labelChamp('TYPE DE CHANTIER'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: couleurType(_type), width: 4)),
              ),
              child: DropdownButtonFormField<TypeChantier>(
                value: _type,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                ),
                items: TypeChantier.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Row(children: [
                    Container(width: 12, height: 12, color: couleurType(t)),
                    const SizedBox(width: 10),
                    Text(libelleType(t),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                )).toList(),
                onChanged: (v) => v != null
                    ? setState(() => _type = v) // setState pour border couleur
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // ── Avancement : Slider → double converti en int par .round() ──
            _labelChamp('AVANCEMENT'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              color: Colors.white,
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progression des travaux',
                      style: const TextStyle(color: _kGris, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      color: couleurProg(_avancement.round()),
                      child: Text('${_avancement.round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900, fontSize: 16,
                        )),
                    ),
                  ]),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: couleurProg(_avancement.round()),
                    thumbColor: couleurProg(_avancement.round()),
                    inactiveTrackColor: Colors.grey.shade200,
                    trackHeight: 6,
                  ),
                  // setState à chaque mouvement → valeur affichée en temps réel
                  child: Slider(
                    value: _avancement, min: 0, max: 100, divisions: 100,
                    onChanged: (v) => setState(() => _avancement = v),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Budget : keyboardType number → clavier numérique ──
            _labelChamp('BUDGET (FCFA)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _budgetCtrl,
              decoration: _deco(hint: 'Ex: 394000000000',
                  icone: Icons.account_balance_wallet_outlined),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Budget obligatoire';
                final b = int.tryParse(v.trim());
                if (b == null || b <= 0) return 'Entier positif requis';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Date : showDatePicker async ─────────────────
            _labelChamp('DATE DE FIN PRÉVUE'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _dateCtrl,
              readOnly: true, // lecture seule → oblige à utiliser le DatePicker
              onTap: _choisirDate,
              decoration: _deco(hint: 'Appuyer pour choisir',
                  icone: Icons.calendar_today_outlined),
              validator: (v) => (v == null || v.isEmpty) ? 'Date obligatoire' : null,
            ),
            const SizedBox(height: 32),

            // ── Bouton principal ─────────────────────────────
            GestureDetector(
              onTap: _sauvegarder,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: _kVert,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(modeEdition ? Icons.save_outlined : Icons.add_circle_outline,
                    color: _kOr, size: 20),
                  const SizedBox(width: 10),
                  Text(modeEdition ? 'ENREGISTRER LES MODIFICATIONS' : 'ENREGISTRER',
                    style: const TextStyle(
                      color: _kOr, fontWeight: FontWeight.w900, letterSpacing: 1.2,
                    )),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _labelChamp(String t) => Text(t, style: const TextStyle(
    fontSize: 10, fontWeight: FontWeight.w800,
    color: _kGris, letterSpacing: 1.2,
  ));

  InputDecoration _deco({required String hint, required IconData icone}) =>
      InputDecoration(
        hintText: hint,
        filled: true, fillColor: Colors.white,
        prefixIcon: Icon(icone, size: 18, color: _kGris),
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: _kVertClair, width: 2)),
        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

// ══════════════════════════════════════════════════════════
//  ÉCRAN 4 : AProposScreen (/apropos) — StatelessWidget
//  Purement informatif, aucun état à gérer
// ══════════════════════════════════════════════════════════
class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        foregroundColor: Colors.white,
        title: const Text('À propos', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── Bannière ODD 9 ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF071F0F), Color(0xFF1B5E20)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: _kOr, borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(child: Text('9',
                  style: TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w900, color: _kVert,
                  ))),
              ),
              const SizedBox(height: 12),
              const Text('ODD 9',
                style: TextStyle(
                    color: _kOr, fontSize: 22, fontWeight: FontWeight.w900)),
              const Text('Industrie, innovation et infrastructure',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Infos étudiant (style timeline) ─────────────
          _SectionApropos(titre: 'ÉTUDIANT', lignes: const [
            ['Nom',          'Pape Souleymane Ndao'],
            ['Établissement','ESMT'],
            ['Formation',    'Licence 3 DAR26'],
            ['Date collecte','Juin 2026'],
          ]),
          const SizedBox(height: 12),

          _SectionApropos(titre: 'PROJET', lignes: const [
            ['Sujet',      'Suivi de chantiers d\'infrastructure'],
            ['Pays',       '🇸🇳 Sénégal'],
            ['Utilisateurs','Agents de collectivités locales'],
            ['Stack',      'Flutter — zéro package externe'],
          ]),
          const SizedBox(height: 12),

          _SectionApropos(titre: 'SOURCES DES DONNÉES', lignes: const [
            ['BRT Dakar',          'CETUD / Dakar Dem Dikk'],
            ['TER Dakar-Diamniadio','APIX / Min. Transports'],
            ['Autoroute Ila Touba', 'AGEROUTE Sénégal'],
          ]),
        ]),
      ),
    );
  }
}

// Widget section À propos : titre + lignes label/valeur
class _SectionApropos extends StatelessWidget {
  final String titre;
  final List<List<String>> lignes;
  const _SectionApropos({required this.titre, required this.lignes});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: const Border(left: BorderSide(color: _kOr, width: 4)),
    ),
    child: Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: _kVert,
        child: Text(titre, style: const TextStyle(
          color: _kOr, fontSize: 10,
          fontWeight: FontWeight.w800, letterSpacing: 1.5,
        )),
      ),
      ...lignes.map((l) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          SizedBox(width: 130, child: Text(l[0],
            style: const TextStyle(color: _kGris, fontSize: 12))),
          Expanded(child: Text(l[1],
            style: const TextStyle(
              color: _kTexte, fontSize: 12, fontWeight: FontWeight.w600,
            ))),
        ]),
      )),
    ]),
  );
}
