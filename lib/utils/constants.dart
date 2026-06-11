// utils/constants.dart — ChantierSN
// Palette de couleurs et fonctions utilitaires partagées

import 'package:flutter/material.dart';
import '../models/chantier.dart';

// ── Palette inspirée du Sénégal et du BTP ──────────────────
const kVert      = Color(0xFF0A3D1F); // vert sombre (forêt)
const kVertClair = Color(0xFF1B5E20); // vert standard
const kOr        = Color(0xFFFFD600); // jaune or
const kSable     = Color(0xFFF4F0E8); // fond sable chaud
const kTexte     = Color(0xFF1A1A1A); // texte principal
const kGris      = Color(0xFF8A8A8A); // texte secondaire

// ── Helpers ────────────────────────────────────────────────

String formatBudget(int montant) {
  final s   = montant.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} FCFA';
}

String formatDate(DateTime d) {
  const mois = {
    1: 'janvier', 2: 'février',  3: 'mars',     4: 'avril',
    5: 'mai',     6: 'juin',     7: 'juillet',  8: 'août',
    9: 'septembre', 10: 'octobre', 11: 'novembre', 12: 'décembre',
  };
  return '${d.day} ${mois[d.month]} ${d.year}';
}

Color couleurType(TypeChantier t) {
  switch (t) {
    case TypeChantier.route:    return const Color(0xFF1B5E20);
    case TypeChantier.pont:     return const Color(0xFF1565C0);
    case TypeChantier.batiment: return const Color(0xFFE65100);
  }
}

String libelleType(TypeChantier t) {
  switch (t) {
    case TypeChantier.route:    return 'ROUTE';
    case TypeChantier.pont:     return 'PONT';
    case TypeChantier.batiment: return 'BÂTIMENT';
  }
}

Color couleurProg(int v) {
  if (v < 40) return Colors.red.shade700;
  if (v < 70) return Colors.orange.shade700;
  return Colors.green.shade700;
}
