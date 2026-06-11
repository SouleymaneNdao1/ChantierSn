// widgets/chantier_card.dart — ChantierSN
// Card affichant un chantier dans la liste

import 'package:flutter/material.dart';
import '../models/chantier.dart';
import '../utils/constants.dart';
import 'ann_painter.dart';

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
          color: Colors.white.withValues(alpha: 0.88),
          border: Border(left: BorderSide(color: couleur, width: 5)),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    color: couleur,
                    child: Text(libelleType(chantier.type),
                      style: const TextStyle(color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 8),
                  Text(chantier.nom,
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w800, color: kTexte)),
                  const SizedBox(height: 6),
                  Text(formatBudget(chantier.budget),
                    style: const TextStyle(fontSize: 11, color: kGris)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(
                      jours < 0 ? Icons.warning_rounded : Icons.schedule,
                      size: 13,
                      color: jours < 0 ? Colors.red.shade700 : kGris,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      jours < 0 ? '${jours.abs()} j dépassé' : 'J-$jours jours',
                      style: TextStyle(
                        fontSize: 11,
                        color: jours < 0 ? Colors.red.shade700 : kGris,
                        fontWeight: jours < 0 ? FontWeight.bold : FontWeight.normal,
                      )),
                  ]),
                  if (chantier.estEnRetard()) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.red.shade700,
                      child: const Text('⚠ EN RETARD',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 68, height: 68,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(
                  size: const Size(68, 68),
                  painter: AnnPainter(prog, couleurProg(chantier.avancement)),
                ),
                Text('${chantier.avancement}%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                      color: couleurProg(chantier.avancement))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
