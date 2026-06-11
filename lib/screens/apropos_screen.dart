// screens/apropos_screen.dart — ChantierSN
// Écran 4 : informations sur le projet et l'étudiant

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        foregroundColor: Colors.white,
        title: const Text('À propos',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: kOr.withValues(alpha: 0.40)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: kOr, borderRadius: BorderRadius.circular(4)),
                child: const Center(
                  child: Text('9',
                    style: TextStyle(fontSize: 36,
                        fontWeight: FontWeight.w900, color: kVert)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('ODD 9',
                style: TextStyle(
                    color: kOr, fontSize: 22, fontWeight: FontWeight.w900)),
              const Text('Industrie, innovation et infrastructure',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 20),

          _SectionApropos(titre: 'ÉTUDIANT', lignes: const [
            ['Nom',           'Pape Souleymane Ndao'],
            ['Établissement', 'ESMT'],
            ['Formation',     'Licence 3 DAR26'],
            ['Date collecte', 'Juin 2026'],
          ]),
          const SizedBox(height: 12),

          _SectionApropos(titre: 'PROJET', lignes: const [
            ['Sujet',        'Suivi de chantiers d\'infrastructure'],
            ['Pays',         '🇸🇳 Sénégal'],
            ['Utilisateurs', 'Agents de collectivités locales'],
            ['Stack',        'Flutter — zéro package externe'],
          ]),
          const SizedBox(height: 12),

          _SectionApropos(titre: 'SOURCES DES DONNÉES', lignes: const [
            ['BRT Dakar',           'CETUD / Dakar Dem Dikk'],
            ['TER Dakar-Diamniadio','APIX / Min. Transports'],
            ['Autoroute Ila Touba', 'AGEROUTE Sénégal'],
          ]),
        ]),
      ),
    );
  }
}

class _SectionApropos extends StatelessWidget {
  final String titre;
  final List<List<String>> lignes;
  const _SectionApropos({required this.titre, required this.lignes});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.88),
      border: const Border(left: BorderSide(color: kOr, width: 4)),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)],
    ),
    child: Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.black.withValues(alpha: 0.55),
        child: Text(titre, style: const TextStyle(
            color: kOr, fontSize: 10,
            fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      ),
      ...lignes.map((l) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          SizedBox(width: 130, child: Text(l[0],
            style: const TextStyle(color: kGris, fontSize: 12))),
          Expanded(child: Text(l[1],
            style: const TextStyle(color: kTexte,
                fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
      )),
    ]),
  );
}
