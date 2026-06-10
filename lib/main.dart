// ─────────────────────────────────────────────────────────────────────────────
// FICHIER   : main.dart
// PROJET    : ChantierSN — Suivi de chantiers d'infrastructure au Sénégal
// AUTEUR    : Pape Souleymane Ndao — ESMT Licence 3 DAR26
// ODD       : ODD 9 — Industrie, innovation et infrastructure
// DATE      : juin 2026
//
// DESCRIPTION GÉNÉRALE :
// Application mobile Flutter permettant aux agents de collectivités locales
// sénégalaises de suivre l'avancement des grands chantiers d'infrastructure.
// Architecture : état global dans le StatefulWidget racine, navigation nommée,
// callbacks passés par arguments pour éviter tout package externe (Provider, etc.)
//
// CONTRAINTES RESPECTÉES :
//   - Un seul fichier main.dart
//   - Zéro package externe (flutter/material.dart uniquement)
//   - Null safety correcte
//   - StatelessWidget ET StatefulWidget justifiés par des commentaires
// ─────────────────────────────────────────────────────────────────────────────

// On importe uniquement le SDK Flutter Material — aucun package externe
import 'package:flutter/material.dart';

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "init: création projet Flutter ChantierSN"
// Pourquoi ce commit : structure initiale du projet Flutter avec main.dart vide
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 1 — MODÈLE DE DONNÉES
//  Enum et classe qui représentent un chantier dans l'application
// ══════════════════════════════════════════════════════════════════════════════

// Enum TypeChantier : représente les 3 catégories possibles d'un chantier
// On utilise un enum car les valeurs sont fixes et connues à la compilation
// Cela évite les erreurs de saisie (typo) par rapport à de simples chaînes
enum TypeChantier { route, pont, batiment }

// Classe principale de l'application
// Représente un chantier d'infrastructure au Sénégal
// C'est un objet "valeur" (value object) : immuable après création
// On utilise une classe simple (pas de ChangeNotifier) car l'état est géré
// dans le widget racine via setState()
class Chantier {
  // Identifiant unique du chantier (ex : "c1", "c2"...)
  final String id;

  // Nom officiel du chantier tel que connu publiquement
  final String nom;

  // Catégorie du chantier parmi les 3 types définis dans l'enum
  final TypeChantier type;

  // Pourcentage d'avancement : entier de 0 à 100
  final int avancement;

  // Budget alloué au chantier en Francs CFA (FCFA)
  final int budget;

  // Date prévisionnelle de fin des travaux
  final DateTime dateFinPrevue;

  // Constructeur avec paramètres nommés obligatoires (required)
  // Les paramètres nommés rendent l'instanciation plus lisible
  const Chantier({
    required this.id,
    required this.nom,
    required this.type,
    required this.avancement,
    required this.budget,
    required this.dateFinPrevue,
  });

  // Retourne true si le chantier risque de ne pas finir à temps
  // Condition double : avancement insuffisant ET délai court
  // Un chantier "en retard" est à la fois peu avancé (<50%)
  // ET proche de sa date limite (moins de 30 jours restants)
  bool estEnRetard() {
    // joursRestants() peut être négatif si la date est déjà dépassée
    // Dans ce cas, le chantier est forcément en retard
    return avancement < 50 && joursRestants() < 30;
  }

  // Calcule le nombre de jours restants avant la date de fin prévue
  // Utilise DateTime.difference() pour comparer deux dates
  // difference().inDays extrait le nombre entier de jours entre les deux dates
  // Si la date est dépassée, la valeur retournée sera négative (ex : -5)
  int joursRestants() {
    // DateTime.now() retourne la date et l'heure actuelles
    // On soustrait "aujourd'hui" de la date de fin pour obtenir la durée restante
    return dateFinPrevue.difference(DateTime.now()).inDays;
  }

  // Crée une copie du chantier en remplaçant certains champs
  // Utile pour le mode édition : on part de l'objet existant et on modifie
  // Ce pattern "copyWith" est standard en Dart pour les classes immuables
  Chantier copyWith({
    String? id,
    String? nom,
    TypeChantier? type,
    int? avancement,
    int? budget,
    DateTime? dateFinPrevue,
  }) {
    // L'opérateur ?? (null-coalescing) retourne la nouvelle valeur si fournie,
    // sinon conserve la valeur actuelle de l'objet
    return Chantier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      avancement: avancement ?? this.avancement,
      budget: budget ?? this.budget,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
    );
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: modèle Chantier, enum TypeChantier, méthodes"
// Pourquoi ce commit : ajout de la classe Chantier avec estEnRetard() et joursRestants()
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 2 — DONNÉES INITIALES (3 chantiers réels du Sénégal)
//  Sources : CETUD, APIX, AGEROUTE Sénégal
// ══════════════════════════════════════════════════════════════════════════════

// Données réelles collectées sur les grands chantiers du Sénégal
// Sources : CETUD, APIX, AGEROUTE Sénégal
// On utilise une List<Chantier> (et non un Set ou Map) car l'ordre d'affichage
// et les doublons potentiels sont gérés manuellement
final List<Chantier> chantiersInitiaux = [
  // Chantier 1 : Bus Rapid Transit de Dakar
  // Source : CETUD / Dakar Dem Dikk
  Chantier(
    id: 'c1',
    nom: 'BRT Dakar',
    type: TypeChantier.route,
    avancement: 65,
    budget: 394000000000, // 394 milliards FCFA
    dateFinPrevue: DateTime(2025, 12, 31),
  ),

  // Chantier 2 : Train Express Régional Dakar-Diamniadio
  // Source : APIX / Ministère des Transports du Sénégal
  Chantier(
    id: 'c2',
    nom: 'TER Dakar-Diamniadio',
    type: TypeChantier.pont,
    avancement: 82,
    budget: 568000000000, // 568 milliards FCFA
    dateFinPrevue: DateTime(2024, 6, 30),
  ),

  // Chantier 3 : Autoroute Ila Touba (Tivaouane Peul - Touba)
  // Source : AGEROUTE Sénégal
  Chantier(
    id: 'c3',
    nom: 'Autoroute Ila Touba',
    type: TypeChantier.route,
    avancement: 90,
    budget: 260000000000, // 260 milliards FCFA
    dateFinPrevue: DateTime(2024, 3, 1),
  ),
];

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: données initiales 3 chantiers réels Sénégal"
// Pourquoi ce commit : ajout des données BRT, TER et Autoroute Ila Touba
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 11 — HELPER DART : formatBudget
//  Formate un entier en chaîne lisible avec espaces tous les 3 chiffres
// ══════════════════════════════════════════════════════════════════════════════

// Formate un entier en chaîne lisible avec espaces
// Exemple : 394000000000 → "394 000 000 000 FCFA"
// Parcourt les chiffres de droite à gauche et insère des espaces
// tous les 3 chiffres pour améliorer la lisibilité
String formatBudget(int montant) {
  // On convertit le montant en chaîne pour pouvoir le parcourir caractère par caractère
  final String chaine = montant.toString();

  // StringBuffer est plus efficace que la concaténation String classique
  // car il évite de créer de nouveaux objets String à chaque itération
  final StringBuffer resultat = StringBuffer();

  // On calcule la position de départ pour les groupes de 3 chiffres
  // Exemple : pour "394000000000" (12 chiffres), on commence à l'index 0
  // et le premier groupe contient les chiffres jusqu'au prochain multiple de 3
  int compteur = 0;

  // On parcourt les chiffres de gauche à droite
  // La variable 'i' est l'index dans la chaîne originale
  for (int i = 0; i < chaine.length; i++) {
    // On calcule la distance depuis la fin pour savoir quand insérer un espace
    // Formule : (longueur - i) donne le nombre de chiffres restants
    // Si ce nombre est divisible par 3 ET qu'on n'est pas au début, on ajoute un espace
    if (compteur > 0 && (chaine.length - i) % 3 == 0) {
      resultat.write(' ');
    }
    resultat.write(chaine[i]);
    compteur++;
  }

  // On ajoute l'unité monétaire à la fin de la chaîne formatée
  return '${resultat.toString()} FCFA';
}

// Formate une date DateTime en chaîne lisible en français
// Exemple : DateTime(2025, 12, 31) → "31 décembre 2025"
// On utilise un Map<int, String> pour associer chaque numéro de mois à son nom
String formatDate(DateTime date) {
  // Map qui associe chaque numéro de mois (1-12) à son nom en français
  // On utilise un Map car la recherche par clé est O(1) (accès direct)
  final Map<int, String> mois = {
    1: 'janvier',
    2: 'février',
    3: 'mars',
    4: 'avril',
    5: 'mai',
    6: 'juin',
    7: 'juillet',
    8: 'août',
    9: 'septembre',
    10: 'octobre',
    11: 'novembre',
    12: 'décembre',
  };
  // On concatène le jour, le mois textuel et l'année
  return '${date.day} ${mois[date.month]} ${date.year}';
}

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 3 & 4 — ÉTAT GLOBAL + NAVIGATION NOMMÉE
//  Widget racine qui détient la liste et configure les routes
// ══════════════════════════════════════════════════════════════════════════════

// Point d'entrée de l'application Flutter
// runApp() monte le widget racine dans l'arbre de widgets Flutter
void main() => runApp(const ChantierApp());

// StatefulWidget racine car il détient la liste partagée
// entre tous les écrans via les callbacks de navigation
// Il est StatefulWidget (et non StatelessWidget) parce que la liste de chantiers
// peut changer : ajout, modification, suppression déclenchent setState()
class ChantierApp extends StatefulWidget {
  const ChantierApp({super.key});

  // createState() crée et lie l'objet State à ce widget
  @override
  State<ChantierApp> createState() => _ChantierAppState();
}

// Classe State associée à ChantierApp
// Elle gère l'état mutable de l'application : la liste des chantiers
// Toute modification de la liste passe par cette classe pour déclencher une
// reconstruction de l'interface utilisateur (setState)
class _ChantierAppState extends State<ChantierApp> {
  // La liste mutable de chantiers : c'est LE state central de l'application
  // On initialise avec une copie de la liste initiale pour pouvoir la modifier
  // List.from() crée une copie indépendante (pas une référence à chantiersInitiaux)
  List<Chantier> _chantiers = List.from(chantiersInitiaux);

  // Ajoute un nouveau chantier à la liste
  // setState() est appelé pour reconstruire tous les écrans qui dépendent de _chantiers
  void _ajouterChantier(Chantier c) {
    // setState() informe Flutter que l'état a changé et qu'il doit reconstruire l'UI
    setState(() {
      // On ajoute le nouveau chantier à la fin de la liste
      _chantiers.add(c);
    });
  }

  // Modifie un chantier existant en le remplaçant par la version mise à jour
  // On utilise l'id pour identifier l'élément à remplacer dans la liste
  // setState() ici pour rafraîchir l'affichage après modification
  void _modifierChantier(Chantier c) {
    setState(() {
      // indexWhere() parcourt la liste et retourne l'index du premier élément
      // dont l'id correspond à celui du chantier modifié
      final int index = _chantiers.indexWhere((el) => el.id == c.id);
      // Si trouvé (index != -1), on remplace l'ancien par le nouveau
      if (index != -1) {
        _chantiers[index] = c;
      }
    });
  }

  // Supprime le chantier dont l'identifiant correspond à l'id passé en argument
  // setState() ici pour rafraîchir la liste après suppression
  void _supprimerChantier(String id) {
    setState(() {
      // removeWhere() supprime tous les éléments qui vérifient la condition
      // On compare les id (String) avec l'opérateur ==
      _chantiers.removeWhere((c) => c.id == id);
    });
  }

  // build() est appelé à chaque setState() pour reconstruire l'interface
  @override
  Widget build(BuildContext context) {
    // MaterialApp est le widget racine qui configure le thème, les routes
    // et le titre de l'application
    return MaterialApp(
      title: 'ChantierSN',

      // Désactive le bandeau "DEBUG" en haut à droite de l'écran
      debugShowCheckedModeBanner: false,

      // ─── SECTION 10 — STYLE VISUEL ────────────────────────────────────
      // ThemeData configure l'apparence globale de toute l'application
      theme: ThemeData(
        // Couleur primaire : vert Sénégal (inspiré du drapeau national)
        primaryColor: const Color(0xFF1B5E20),

        // colorScheme remplace primarySwatch depuis Flutter 3
        // Il définit la palette de couleurs cohérente de l'application
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          // secondary est le jaune or, utilisé pour les éléments d'accentuation
          secondary: const Color(0xFFFFD600),
        ),

        // AppBarTheme : fond vert Sénégal, texte et icônes en blanc
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // FloatingActionButtonTheme : fond vert pour le bouton "+"
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),

        // CardTheme : coins arrondis à 12px, ombre légère (elevation 3)
        // elevation crée une ombre portée qui donne de la profondeur aux cartes
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),

        useMaterial3: true,
      ),

      // Route initiale : l'écran de liste est le premier affiché au démarrage
      initialRoute: '/liste',

      // ─── SECTION 4 — NAVIGATION NOMMÉE ───────────────────────────────
      // Routes nommées : plus lisible et maintenable que Navigator.push direct
      // Chaque route correspond à un écran précis de l'application
      // onGenerateRoute est utilisé car on passe des arguments aux routes
      onGenerateRoute: (RouteSettings settings) {
        // settings.name contient le nom de la route demandée (ex : '/detail')
        // settings.arguments contient les données passées à cette route
        switch (settings.name) {
          case '/liste':
            // On passe les callbacks à ListeScreen via le constructeur
            // Ainsi, ListeScreen peut déclencher des modifications d'état
            // sans avoir accès direct à _ChantierAppState
            return MaterialPageRoute(
              builder: (_) => ListeScreen(
                chantiers: _chantiers,
                onAjouter: _ajouterChantier,
                onModifier: _modifierChantier,
                onSupprimer: _supprimerChantier,
              ),
            );

          case '/detail':
            // On cast les arguments en Map<String, dynamic> pour accéder
            // aux valeurs par leur clé (ex : args['chantier'])
            final Map<String, dynamic> args =
                settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DetailScreen(
                chantier: args['chantier'] as Chantier,
                onSupprimer: args['onSupprimer'] as Function,
                onModifier: args['onModifier'] as Function,
              ),
            );

          case '/formulaire':
            // On passe le chantier en argument pour le mode édition
            // null = mode création, non null = mode édition (champs pré-remplis)
            final Map<String, dynamic> args =
                settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => FormulaireScreen(
                onAjouter: args['onAjouter'] as Function,
                onModifier: args['onModifier'] as Function,
                // L'opérateur as Chantier? permet le cast nullable
                chantier: args['chantier'] as Chantier?,
              ),
            );

          case '/apropos':
            return MaterialPageRoute(
              builder: (_) => const AProposScreen(),
            );

          default:
            // Route inconnue : on affiche un écran d'erreur minimal
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Route inconnue')),
              ),
            );
        }
      },
    );
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: navigation nommée 4 écrans et état global"
// Pourquoi ce commit : MaterialApp avec onGenerateRoute, callbacks état global
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 5 — WIDGET RÉUTILISABLE : ChantierCard
//  StatelessWidget car la carte affiche seulement les données
//  Elle ne modifie aucun état : tout est reçu en paramètre (données + callback)
// ══════════════════════════════════════════════════════════════════════════════

// StatelessWidget car la carte affiche seulement les données
// Elle ne modifie aucun état, elle reçoit tout en paramètre
// Avantage : Flutter peut la reconstruire très efficacement car elle est pure
// (même entrée → même sortie, sans effets de bord)
class ChantierCard extends StatelessWidget {
  // Le chantier à afficher : required car sans données, la carte n'a pas de sens
  final Chantier chantier;

  // Callback déclenché quand l'utilisateur tape sur la carte
  // On utilise VoidCallback car le tap ne retourne pas de valeur
  final VoidCallback onTap;

  const ChantierCard({
    super.key,
    required this.chantier,
    required this.onTap,
  });

  // Retourne la couleur de fond du badge selon le type de chantier
  // On utilise une méthode privée (underscore) pour factoriser cette logique
  // plutôt que de répéter le switch dans le build()
  Color _couleurBadge() {
    // switch sur l'enum TypeChantier pour couvrir tous les cas possibles
    switch (chantier.type) {
      case TypeChantier.route:
        return const Color(0xFF1B5E20); // vert foncé
      case TypeChantier.pont:
        return const Color(0xFF1565C0); // bleu foncé
      case TypeChantier.batiment:
        return const Color(0xFFE65100); // orange foncé
    }
  }

  // Retourne le libellé textuel du type de chantier en français
  String _libelleType() {
    switch (chantier.type) {
      case TypeChantier.route:
        return 'Route';
      case TypeChantier.pont:
        return 'Pont';
      case TypeChantier.batiment:
        return 'Bâtiment';
    }
  }

  // Retourne la couleur de la barre de progression selon l'avancement
  // On utilise des seuils (< 40%, < 70%, ≥ 70%) pour coder visuellement l'urgence
  Color _couleurProgression() {
    if (chantier.avancement < 40) {
      // Moins de 40% : situation critique, on affiche en rouge
      return Colors.red;
    } else if (chantier.avancement < 70) {
      // Entre 40% et 69% : situation moyenne, on affiche en orange
      return Colors.orange;
    } else {
      // 70% et plus : bonne progression, on affiche en vert
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Card est le widget Material Design qui crée une surface élevée avec ombre
    // Sa forme arrondie est définie dans le CardTheme global
    return Card(
      // InkWell ajoute un effet de ripple (vague) au tap sur la carte
      // C'est le comportement standard Material Design pour les éléments cliquables
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          // Espacement intérieur de 16px sur tous les côtés
          padding: const EdgeInsets.all(16),
          child: Column(
            // crossAxisAlignment.start aligne tout à gauche (axe horizontal)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ligne 1 : nom du chantier + badge type ──────────────
              Row(
                // spaceBetween pousse le nom à gauche et le badge à droite
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expanded empêche le nom de déborder si trop long
                  Expanded(
                    child: Text(
                      chantier.nom,
                      // fontWeight.bold pour mettre en évidence le nom du chantier
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Badge type : Container avec BorderRadius pour faire une "pill"
                  // La forme arrondie (pill) est un motif visuel reconnu pour les étiquettes
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _couleurBadge(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _libelleType(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Ligne 2 : barre de progression ──────────────────────
              // valeur entre 0.0 et 1.0 donc on divise avancement par 100
              // LinearProgressIndicator accepte une valeur double entre 0.0 et 1.0
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  // Division par 100 pour convertir le pourcentage en fraction
                  value: chantier.avancement / 100,
                  minHeight: 8,
                  // backgroundColor est la couleur de la partie non remplie
                  backgroundColor: Colors.grey[200],
                  // valueColor est la couleur de la partie remplie
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _couleurProgression(),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Texte de l'avancement en pourcentage
              Text(
                'Avancement : ${chantier.avancement}%',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),

              const SizedBox(height: 8),

              // ── Ligne 3 : budget + jours restants ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Helper formatBudget() pour espacer les chiffres lisiblement
                  Text(
                    formatBudget(chantier.budget),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // joursRestants() calcule la différence entre aujourd'hui et la date
                  // Si la valeur est négative, la date est dépassée
                  Text(
                    'J-${chantier.joursRestants()} jours',
                    style: TextStyle(
                      fontSize: 12,
                      color: chantier.joursRestants() < 0
                          ? Colors.red
                          : Colors.grey[600],
                      fontWeight: chantier.joursRestants() < 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              // ── Badge "EN RETARD" conditionnel ──────────────────────
              // estEnRetard() combine deux conditions pour détecter le retard
              // On n'affiche ce badge que si les deux conditions sont vraies
              if (chantier.estEnRetard()) ...[
                const SizedBox(height: 8),
                // Container rouge avec texte blanc pour alerter visuellement
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '⚠ EN RETARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: widget réutilisable ChantierCard StatelessWidget"
// Pourquoi ce commit : ChantierCard avec badge type, barre couleur, budget, retard
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 6 — ÉCRAN 1 : ListeScreen (/liste)
//  StatefulWidget car le filtre change l'état local de l'écran
//  setState() est appelé quand l'utilisateur active ou désactive le filtre
// ══════════════════════════════════════════════════════════════════════════════

// StatefulWidget car le filtre est un état local qui change à chaque tap
// Si on utilisait un StatelessWidget, le filtre ne pourrait pas être mémorisé
// entre les rebuilds du widget parent
class ListeScreen extends StatefulWidget {
  // La liste de chantiers vient de l'état global (_ChantierAppState)
  final List<Chantier> chantiers;

  // Callbacks pour les opérations CRUD sur la liste globale
  final Function onAjouter;
  final Function onModifier;
  final Function onSupprimer;

  const ListeScreen({
    super.key,
    required this.chantiers,
    required this.onAjouter,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

// État local de ListeScreen : uniquement le booléen de filtre
// L'état global (liste des chantiers) reste dans _ChantierAppState
class _ListeScreenState extends State<ListeScreen> {
  // Le filtre est un booléen local qui déclenche un setState
  // false = afficher tous les chantiers
  // true = afficher uniquement ceux avec avancement > 80%
  bool _filtreActif = false;

  // Retourne la liste filtrée selon l'état du filtre
  // Si filtre inactif, on retourne tous les chantiers
  // Si filtre actif, on retourne seulement ceux avancés à plus de 80%
  List<Chantier> get _chantiersAffiches {
    if (_filtreActif) {
      // where() filtre la liste et retourne un Iterable
      // toList() convertit l'Iterable en List concrète
      return widget.chantiers.where((c) => c.avancement > 80).toList();
    }
    // Pas de filtre : on retourne tous les chantiers
    return widget.chantiers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar change de couleur quand le filtre est actif (#FFD600 jaune)
      // Cela donne un retour visuel immédiat à l'utilisateur
      appBar: AppBar(
        backgroundColor: _filtreActif
            ? const Color(0xFFFFD600)
            : const Color(0xFF1B5E20),
        // Texte noir sur fond jaune pour respecter le contraste (accessibilité)
        foregroundColor: _filtreActif ? Colors.black : Colors.white,
        title: Text(
          'ChantierSN 🇸🇳',
          style: TextStyle(
            color: _filtreActif ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton filtre : setState() change _filtreActif (bool)
          // On bascule la valeur du booléen à chaque tap (toggle)
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _filtreActif ? Colors.black : Colors.white,
            ),
            tooltip: _filtreActif
                ? 'Afficher tous les chantiers'
                : 'Filtrer : avancement > 80%',
            onPressed: () {
              // setState() ici pour basculer le filtre et reconstruire l'UI
              // _filtreActif passe de false à true ou de true à false
              setState(() {
                _filtreActif = !_filtreActif;
              });
            },
          ),

          // IconButton info → navigation vers l'écran À propos
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: _filtreActif ? Colors.black : Colors.white,
            ),
            tooltip: 'À propos',
            onPressed: () {
              // Navigator.pushNamed('/apropos') : navigue vers l'écran À propos
              // Aucun argument nécessaire car c'est un écran purement informatif
              Navigator.pushNamed(context, '/apropos');
            },
          ),
        ],
      ),

      // Corps principal : ListView.builder est plus performant que ListView
      // Il crée les widgets à la demande (lazy loading), pas tous en même temps
      // Crucial pour les grandes listes : seuls les widgets visibles sont créés
      body: _chantiersAffiches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _filtreActif
                        ? 'Aucun chantier avec avancement > 80%'
                        : 'Aucun chantier enregistré',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              // Padding pour ne pas coller les cartes aux bords
              padding: const EdgeInsets.all(12),
              // itemCount : nombre d'éléments dans la liste filtrée
              itemCount: _chantiersAffiches.length,
              // itemBuilder est appelé à la demande pour chaque élément visible
              itemBuilder: (BuildContext ctx, int index) {
                // On récupère le chantier à l'index courant
                final Chantier chantier = _chantiersAffiches[index];

                // On utilise ChantierCard (StatelessWidget réutilisable)
                // et on lui passe le chantier + le callback de navigation
                return ChantierCard(
                  chantier: chantier,
                  onTap: () {
                    // Navigator.pushNamed('/detail') navigue vers l'écran de détail
                    // On passe le chantier + les callbacks dans une Map d'arguments
                    // Ainsi DetailScreen peut modifier ou supprimer ce chantier
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      // On passe le chantier en argument pour éviter de le rechercher
                      // dans DetailScreen. Les callbacks permettent les modifications.
                      arguments: {
                        'chantier': chantier,
                        'onSupprimer': widget.onSupprimer,
                        'onModifier': widget.onModifier,
                      },
                    );
                  },
                );
              },
            ),

      // FAB (+) vert → navigue vers le formulaire de création
      // FloatingActionButton est le widget Material standard pour l'action principale
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter un chantier',
        onPressed: () {
          // Navigator.pushNamed('/formulaire') ouvre le formulaire de création
          // chantier: null signifie mode création (champs vides)
          // On passe onAjouter ET onModifier car FormulaireScreen gère les deux modes
          Navigator.pushNamed(
            context,
            '/formulaire',
            arguments: {
              'onAjouter': widget.onAjouter,
              'onModifier': widget.onModifier,
              'chantier': null, // null = mode création, formulaire vide
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: écran liste filtre et StatefulWidget setState"
// Pourquoi ce commit : ListeScreen avec filtre booléen, AppBar jaune, FAB
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 7 — ÉCRAN 2 : DetailScreen (/detail)
//  StatelessWidget car cet écran affiche seulement les données
//  Il reçoit tout ce dont il a besoin via les arguments de navigation
// ══════════════════════════════════════════════════════════════════════════════

// StatelessWidget car cet écran affiche seulement les données
// Aucun état local à gérer : les données viennent du chantier passé en argument
// Les actions (modifier, supprimer) déclenchent des callbacks vers l'état global
class DetailScreen extends StatelessWidget {
  // Le chantier à afficher, reçu de la route de navigation
  final Chantier chantier;

  // Callbacks vers l'état global pour modifier ou supprimer
  final Function onSupprimer;
  final Function onModifier;

  const DetailScreen({
    super.key,
    required this.chantier,
    required this.onSupprimer,
    required this.onModifier,
  });

  // Retourne la couleur selon le pourcentage d'avancement
  // Même logique que dans ChantierCard pour la cohérence visuelle
  Color _couleurProgression() {
    if (chantier.avancement < 40) return Colors.red;
    if (chantier.avancement < 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chantier.nom),
      ),

      body: SingleChildScrollView(
        // Padding global de 16px pour aérer le contenu
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section avancement ──────────────────────────────────
            const Text(
              'Avancement des travaux',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // SizedBox + LinearProgressIndicator pour une grande barre visuelle
            // height: 20 donne une barre épaisse, plus visible que la taille par défaut
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 20,
                child: LinearProgressIndicator(
                  // valeur entre 0.0 et 1.0 donc on divise avancement par 100
                  value: chantier.avancement / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _couleurProgression(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Avancement : ${chantier.avancement}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            // ── Section informations générales ─────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Ligne Budget
                    _lignInfo(
                      Icons.account_balance_wallet,
                      'Budget',
                      // Helper formatBudget() pour espacer les chiffres lisiblement
                      formatBudget(chantier.budget),
                    ),
                    const Divider(),

                    // Ligne Date de fin prévue
                    _lignInfo(
                      Icons.calendar_today,
                      'Date de fin prévue',
                      // formatDate() convertit le DateTime en chaîne lisible en français
                      formatDate(chantier.dateFinPrevue),
                    ),
                    const Divider(),

                    // Ligne Jours restants
                    // joursRestants() peut être négatif si la date est dépassée
                    _lignInfo(
                      Icons.timer,
                      'Délai restant',
                      'J-${chantier.joursRestants()} jours',
                      couleur: chantier.joursRestants() < 0
                          ? Colors.red
                          : null,
                    ),
                    const Divider(),

                    // Ligne Type de chantier
                    _lignInfo(
                      Icons.category,
                      'Type',
                      chantier.type.name.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Badge "EN RETARD" conditionnel ──────────────────────
            // Card rouge visible pour alerter l'utilisateur immédiatement
            // On n'affiche cette alerte que si estEnRetard() retourne true
            if (chantier.estEnRetard())
              Card(
                color: Colors.red[700],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.warning, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '⚠ Ce chantier est EN RETARD !',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // ── Boutons d'actions ────────────────────────────────────
            Row(
              children: [
                // Bouton Modifier : ouvre le formulaire avec le chantier existant
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Navigator.pushNamed('/formulaire') ouvre le formulaire en mode édition
                      // On passe le chantier existant pour pré-remplir le formulaire
                      // chantier != null → mode édition dans FormulaireScreen
                      Navigator.pushNamed(
                        context,
                        '/formulaire',
                        arguments: {
                          'onAjouter': (_) {}, // non utilisé en mode édition
                          'onModifier': onModifier,
                          // On passe le chantier existant pour pré-remplir le formulaire
                          'chantier': chantier,
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Bouton Supprimer : affiche une boîte de dialogue de confirmation
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // showDialog bloque la navigation jusqu'à confirmation
                      // L'utilisateur doit explicitement confirmer avant la suppression
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text(
                              'Voulez-vous vraiment supprimer le chantier "${chantier.nom}" ?',
                            ),
                            actions: [
                              // "Annuler" ferme le dialog sans rien faire
                              TextButton(
                                onPressed: () {
                                  // Navigator.pop(dialogContext) ferme uniquement le dialog
                                  // Sans toucher à l'écran de détail en dessous
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Annuler'),
                              ),

                              // "Supprimer" : appelle onSupprimer puis ferme dialog ET écran détail
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // On appelle le callback de suppression avec l'id du chantier
                                  // Cela déclenche setState() dans _ChantierAppState
                                  onSupprimer(chantier.id);

                                  // pop() x2 : ferme le dialog ET revient à la liste
                                  // Premier pop() : ferme le AlertDialog
                                  Navigator.pop(dialogContext);
                                  // Deuxième pop() : revient à ListeScreen depuis DetailScreen
                                  Navigator.pop(context);
                                },
                                child: const Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper privé pour afficher une ligne d'information avec icône
  // Factoriser ce pattern évite de répéter le même Row/Icon/Text plusieurs fois
  Widget _lignInfo(IconData icone, String label, String valeur,
      {Color? couleur}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, color: const Color(0xFF1B5E20), size: 22),
          const SizedBox(width: 12),
          Text(
            '$label : ',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              valeur,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                // Si une couleur est spécifiée, on l'utilise (ex : rouge pour retard)
                color: couleur,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: écran détail StatelessWidget passage arguments"
// Pourquoi ce commit : DetailScreen avec barre avancement, infos, dialog suppression
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 8 — ÉCRAN 3 : FormulaireScreen (/formulaire)
//  StatefulWidget car le Slider et le DatePicker modifient l'état local
//  setState() est appelé à chaque mouvement du Slider et sélection de date
// ══════════════════════════════════════════════════════════════════════════════

// StatefulWidget car le Slider et le DatePicker modifient l'état
// setState() est appelé à chaque mouvement du Slider pour afficher la valeur
// Un StatelessWidget ne pourrait pas stocker la valeur courante du Slider
class FormulaireScreen extends StatefulWidget {
  // Callbacks vers l'état global : onAjouter (création) ou onModifier (édition)
  final Function onAjouter;
  final Function onModifier;

  // null = mode création (champs vides) / non null = mode édition (pré-rempli)
  final Chantier? chantier;

  const FormulaireScreen({
    super.key,
    required this.onAjouter,
    required this.onModifier,
    this.chantier, // nullable : absent = mode création
  });

  @override
  State<FormulaireScreen> createState() => _FormulaireScreenState();
}

// État local de FormulaireScreen : tous les champs du formulaire
class _FormulaireScreenState extends State<FormulaireScreen> {
  // GlobalKey permet d'appeler form.validate() sur le formulaire
  // La clé est unique et permet d'accéder à l'état du Form depuis n'importe où
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  // TextEditingController permet de lire et d'écrire la valeur d'un TextField
  late TextEditingController _nomController;
  late TextEditingController _budgetController;

  // Type sélectionné dans le DropdownButton
  // TypeChantier.route est la valeur par défaut pour une nouvelle entrée
  late TypeChantier _typeSelectionne;

  // Avancement : double car Slider travaille avec des doubles
  // On convertit en int au moment de la sauvegarde avec .round()
  late double _avancement;

  // Date de fin prévue : nullable car l'utilisateur peut ne pas encore l'avoir choisie
  DateTime? _dateFinPrevue;

  // Contrôleur pour le champ date (affichage de la date sélectionnée)
  late TextEditingController _dateController;

  // initState() est appelé une seule fois quand le widget est inséré dans l'arbre
  // C'est ici qu'on initialise les controllers avec les valeurs existantes (mode édition)
  @override
  void initState() {
    super.initState();

    // Mode détecté selon la présence ou non du chantier en argument
    // Si widget.chantier != null → mode édition → on pré-remplit les champs
    // Si widget.chantier == null → mode création → champs vides
    final bool modeEdition = widget.chantier != null;

    // Initialisation des controllers :
    // En mode édition, on utilise les valeurs existantes
    // En mode création, on utilise des valeurs par défaut vides
    _nomController = TextEditingController(
      text: modeEdition ? widget.chantier!.nom : '',
    );
    _budgetController = TextEditingController(
      text: modeEdition ? widget.chantier!.budget.toString() : '',
    );
    _typeSelectionne =
        modeEdition ? widget.chantier!.type : TypeChantier.route;
    _avancement =
        modeEdition ? widget.chantier!.avancement.toDouble() : 0.0;
    _dateFinPrevue =
        modeEdition ? widget.chantier!.dateFinPrevue : null;
    _dateController = TextEditingController(
      text: modeEdition ? formatDate(widget.chantier!.dateFinPrevue) : '',
    );
  }

  // dispose() est appelé quand le widget est retiré de l'arbre
  // Il faut impérativement libérer les controllers pour éviter les fuites mémoire
  @override
  void dispose() {
    _nomController.dispose();
    _budgetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Ouvre le sélecteur de date et met à jour l'état
  // showDatePicker est async : on attend le résultat avec await
  Future<void> _choisirDate() async {
    // showDatePicker retourne la date choisie, ou null si l'utilisateur annule
    final DateTime? dateChoisie = await showDatePicker(
      context: context,
      // initialDate : la date actuellement sélectionnée ou aujourd'hui
      initialDate: _dateFinPrevue ?? DateTime.now(),
      // firstDate et lastDate définissent la plage de dates autorisées
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Sélectionner la date de fin prévue',
    );

    // Si l'utilisateur a sélectionné une date (pas annulé), on met à jour l'état
    if (dateChoisie != null) {
      // setState() ici pour afficher la date sélectionnée dans le champ texte
      setState(() {
        _dateFinPrevue = dateChoisie;
        // On met à jour le texte affiché dans le champ date
        _dateController.text = formatDate(dateChoisie);
      });
    }
  }

  // Génère un identifiant unique basé sur l'horodatage
  // DateTime.now().millisecondsSinceEpoch garantit l'unicité
  String _genererNouvelId() {
    return 'c${DateTime.now().millisecondsSinceEpoch}';
  }

  // Valide et sauvegarde le formulaire
  // Selon le mode, on appelle onAjouter (création) ou onModifier (édition)
  void _sauvegarder() {
    // form.validate() appelle tous les validators des champs
    // Retourne true si tous les champs sont valides, false sinon
    if (_formKey.currentState!.validate()) {
      // Validation supplémentaire : la date doit être renseignée
      if (_dateFinPrevue == null) {
        // ScaffoldMessenger affiche un message temporaire en bas de l'écran
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date de fin')),
        );
        return;
      }

      // Détermine si on est en mode création ou édition
      final bool modeEdition = widget.chantier != null;

      if (modeEdition) {
        // Mode édition : on crée une copie modifiée du chantier existant
        // copyWith() conserve l'id et remplace les autres champs modifiés
        final Chantier chantierModifie = widget.chantier!.copyWith(
          nom: _nomController.text.trim(),
          type: _typeSelectionne,
          // Slider donne une valeur double → on convertit en int avec .round()
          avancement: _avancement.round(),
          budget: int.parse(_budgetController.text.trim()),
          dateFinPrevue: _dateFinPrevue,
        );
        // On appelle onModifier pour mettre à jour dans la liste globale
        widget.onModifier(chantierModifie);
      } else {
        // Mode création : on crée un nouveau chantier avec un id unique
        final Chantier nouveauChantier = Chantier(
          id: _genererNouvelId(),
          nom: _nomController.text.trim(),
          type: _typeSelectionne,
          // Slider donne une valeur double → on convertit en int avec .round()
          avancement: _avancement.round(),
          budget: int.parse(_budgetController.text.trim()),
          dateFinPrevue: _dateFinPrevue!,
        );
        // On appelle onAjouter pour ajouter à la liste globale
        widget.onAjouter(nouveauChantier);
      }

      // Navigator.pop() retourne à l'écran précédent (liste ou détail)
      // On n'a pas besoin de passer de résultat car l'état est mis à jour via callbacks
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le titre et le bouton changent selon le mode (création ou édition)
    final bool modeEdition = widget.chantier != null;
    final String titre =
        modeEdition ? 'Modifier le chantier' : 'Nouveau chantier';

    return Scaffold(
      appBar: AppBar(
        title: Text(titre),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Form est le widget qui gère la validation de tous ses champs enfants
        // _formKey permet d'appeler form.validate() depuis le bouton de sauvegarde
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Champ Nom ──────────────────────────────────────────
              // validator retourne null si OK, sinon le message d'erreur affiché
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du chantier *',
                  hintText: 'Ex: BRT Dakar',
                  prefixIcon: Icon(Icons.construction),
                  border: OutlineInputBorder(),
                ),
                // textCapitalization capitalise la première lettre de chaque mot
                textCapitalization: TextCapitalization.words,
                // validator : fonction appelée par form.validate()
                // retourne null si valide, un message String si invalide
                validator: (String? valeur) {
                  if (valeur == null || valeur.trim().isEmpty) {
                    return 'Le nom du chantier est obligatoire';
                  }
                  if (valeur.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  // null signifie "valide" pour le Form
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Champ Type (DropdownButton) ────────────────────────
              // DropdownButton car TypeChantier est un enum à 3 valeurs fixes
              // On ne peut pas utiliser un TextField libre car les valeurs sont contraintes
              DropdownButtonFormField<TypeChantier>(
                value: _typeSelectionne,
                decoration: const InputDecoration(
                  labelText: 'Type de chantier *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                // items : la liste des options disponibles dans le dropdown
                // On utilise TypeChantier.values pour obtenir tous les cas de l'enum
                items: TypeChantier.values.map((TypeChantier type) {
                  return DropdownMenuItem<TypeChantier>(
                    value: type,
                    child: Text(_libelleType(type)),
                  );
                }).toList(),
                onChanged: (TypeChantier? valeur) {
                  if (valeur != null) {
                    // setState() pour mettre à jour le type sélectionné dans l'UI
                    setState(() {
                      _typeSelectionne = valeur;
                    });
                  }
                },
                validator: (valeur) {
                  if (valeur == null) return 'Veuillez sélectionner un type';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Champ Avancement (Slider) ──────────────────────────
              // Slider donne une valeur double → on convertit en int avec .round()
              // setState() ici pour afficher la valeur en temps réel sous le slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Avancement des travaux *',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      // Affichage en temps réel de la valeur du Slider
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_avancement.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _avancement,
                    min: 0,
                    max: 100,
                    // divisions: 100 crée des paliers de 1% chacun
                    divisions: 100,
                    activeColor: const Color(0xFF1B5E20),
                    // onChanged est appelé à chaque mouvement du curseur
                    onChanged: (double nouvelleValeur) {
                      // setState() ici pour afficher la valeur en temps réel
                      // _avancement est mis à jour à chaque déplacement du curseur
                      setState(() {
                        _avancement = nouvelleValeur;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Champ Budget ───────────────────────────────────────
              // keyboardType.number pour n'afficher que le clavier numérique
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (en FCFA) *',
                  hintText: 'Ex: 394000000000',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(),
                ),
                // keyboardType.number affiche le clavier numérique sur mobile
                keyboardType: TextInputType.number,
                validator: (String? valeur) {
                  if (valeur == null || valeur.trim().isEmpty) {
                    return 'Le budget est obligatoire';
                  }
                  // int.tryParse retourne null si la chaîne n'est pas un entier valide
                  final int? budget = int.tryParse(valeur.trim());
                  if (budget == null) {
                    return 'Veuillez entrer un nombre entier valide';
                  }
                  if (budget <= 0) {
                    return 'Le budget doit être supérieur à 0';
                  }
                  // null signifie "valide"
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Champ Date de fin prévue ──────────────────────────
              // showDatePicker est async, on attend le résultat avec await
              // On utilise un TextField en lecture seule avec un GestureDetector
              // pour déclencher le DatePicker au tap
              TextFormField(
                controller: _dateController,
                // readOnly empêche l'édition manuelle : on force le DatePicker
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date de fin prévue *',
                  hintText: 'Appuyer pour choisir une date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                // onTap déclenche l'ouverture du DatePicker
                onTap: _choisirDate,
                validator: (String? valeur) {
                  if (valeur == null || valeur.trim().isEmpty) {
                    return 'La date de fin est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ── Bouton principal de sauvegarde ────────────────────
              SizedBox(
                // width: double.infinity pour que le bouton prenne toute la largeur
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(modeEdition ? Icons.save : Icons.add_circle),
                  label: Text(
                    modeEdition ? 'Enregistrer les modifications' : 'Enregistrer',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _sauvegarder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Retourne le libellé français d'un TypeChantier
  // Méthode locale au formulaire (non liée au modèle Chantier)
  String _libelleType(TypeChantier type) {
    switch (type) {
      case TypeChantier.route:
        return '🛣️  Route';
      case TypeChantier.pont:
        return '🌉  Pont';
      case TypeChantier.batiment:
        return '🏗️  Bâtiment';
    }
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: formulaire création et édition avec validation"
// Pourquoi ce commit : FormulaireScreen avec Slider, DatePicker, validators
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION 9 — ÉCRAN 4 : AProposScreen (/apropos)
//  StatelessWidget car cet écran est purement informatif
//  Aucune interaction, aucun état à gérer
// ══════════════════════════════════════════════════════════════════════════════

// StatelessWidget car cet écran est purement informatif
// Aucune interaction, aucun état à gérer
// Il affiche des données fixes (nom étudiant, sources, ODD) sans jamais changer
class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── En-tête avec logo ODD ──────────────────────────────
            // Card soignée avec toutes les infos du projet
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icône représentant l'infrastructure (ODD 9)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.construction,
                        size: 48,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'ChantierSN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const Text(
                      'Application de suivi de chantiers d\'infrastructure',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Section Étudiant ───────────────────────────────────
            _sectionCard(
              titre: '👤 Étudiant',
              // Liste des informations de l'étudiant
              // On utilise une List<Widget> pour les lignes d'information
              lignes: [
                _lignInfo('Nom', 'Pape Souleymane Ndao'),
                _lignInfo('Établissement', 'ESMT'),
                _lignInfo('Formation', 'Licence 3 DAR26'),
                _lignInfo('Date de collecte', 'Juin 2026'),
              ],
            ),

            const SizedBox(height: 12),

            // ── Section Projet ─────────────────────────────────────
            _sectionCard(
              titre: '📋 Projet',
              lignes: [
                _lignInfo(
                  'Sujet',
                  'Suivi de l\'avancement de chantiers d\'infrastructure',
                ),
                _lignInfo('ODD', 'ODD 9 — Industrie, innovation et infrastructure'),
                _lignInfo('Pays', '🇸🇳 Sénégal'),
                _lignInfo('Utilisateurs', 'Agents de collectivités locales'),
              ],
            ),

            const SizedBox(height: 12),

            // ── Section Sources ────────────────────────────────────
            _sectionCard(
              titre: '📚 Sources des données',
              lignes: [
                _lignInfo(
                  'BRT Dakar',
                  'CETUD / Dakar Dem Dikk',
                ),
                _lignInfo(
                  'TER Dakar-Diamniadio',
                  'APIX / Ministère des Transports',
                ),
                _lignInfo(
                  'Autoroute Ila Touba',
                  'AGEROUTE Sénégal',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Badge ODD 9 en bas de page
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Fond jaune or (couleur ODD 9)
                color: const Color(0xFFFFD600),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    '🏭',
                    style: TextStyle(fontSize: 32),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ODD 9 — Industrie, innovation et infrastructure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Objectifs de Développement Durable — Nations Unies',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget helper : crée une Card avec un titre et une liste de lignes d'info
  Widget _sectionCard({
    required String titre,
    required List<Widget> lignes,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const Divider(),
            // Spread operator (...) pour insérer toutes les lignes dans la Column
            ...lignes,
          ],
        ),
      ),
    );
  }

  // Widget helper : crée une ligne label + valeur
  Widget _lignInfo(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "feat: écran À propos infos étudiant et sources"
// Pourquoi ce commit : AProposScreen avec infos étudiant, ODD 9, sources
// ─── GIT ────────────────────────────────────────────────────────────────────
// git add . && git commit -m "style: thème vert Sénégal badges colorés UI finale"
// Pourquoi ce commit : ThemeData complet, badges colorés, UI finale peaufinée
// ─────────────────────────────────────────────────────────────────────────────
