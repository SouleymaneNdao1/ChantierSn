// main.dart — ChantierSN | Pape Souleymane Ndao — ESMT DAR26
// Point d'entrée : gestion de l'état global + routing uniquement
import 'package:flutter/material.dart';
import 'models/chantier.dart';
import 'utils/constants.dart';
import 'screens/liste_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/formulaire_screen.dart';
import 'screens/apropos_screen.dart';


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
        colorScheme: ColorScheme.fromSeed(seedColor: kVertClair),
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
            child: Container(color: Colors.black.withValues(alpha: 0.40)),
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
