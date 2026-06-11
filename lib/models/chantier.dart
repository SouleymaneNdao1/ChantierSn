// models/chantier.dart — ChantierSN
// Modèle de données : TypeChantier, Chantier, données initiales

enum TypeChantier { route, pont, batiment }

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

  bool estEnRetard() => avancement < 50 && joursRestants() < 30;
  int joursRestants() => dateFinPrevue.difference(DateTime.now()).inDays;

  Chantier copyWith({
    String? id, String? nom, TypeChantier? type,
    int? avancement, int? budget, DateTime? dateFinPrevue,
  }) => Chantier(
    id: id ?? this.id, nom: nom ?? this.nom, type: type ?? this.type,
    avancement: avancement ?? this.avancement, budget: budget ?? this.budget,
    dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
  );
}

// Données initiales — sources : CETUD, APIX, AGEROUTE
final List<Chantier> chantiersInitiaux = [
  Chantier(id: 'c1', nom: 'BRT Dakar', type: TypeChantier.route,
      avancement: 65, budget: 394000000000, dateFinPrevue: DateTime(2025, 12, 31)),
  Chantier(id: 'c2', nom: 'TER Dakar-Diamniadio', type: TypeChantier.pont,
      avancement: 82, budget: 568000000000, dateFinPrevue: DateTime(2024, 6, 30)),
  Chantier(id: 'c3', nom: 'Autoroute Ila Touba', type: TypeChantier.route,
      avancement: 90, budget: 260000000000, dateFinPrevue: DateTime(2024, 3, 1)),
];
