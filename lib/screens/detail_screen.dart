// screens/detail_screen.dart — ChantierSN
// Écran 2 : détail d'un chantier avec grille d'indicateurs

import 'package:flutter/material.dart';
import '../models/chantier.dart';
import '../utils/constants.dart';
import '../widgets/ann_painter.dart';

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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            border: Border(bottom: BorderSide(
                color: kOr.withValues(alpha: 0.60), width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    SizedBox(width: 90, height: 90,
                      child: Stack(alignment: Alignment.center, children: [
                        CustomPaint(
                          size: const Size(90, 90),
                          painter: AnnPainter(prog, kOr),
                        ),
                        Text('${chantier.avancement}%',
                          style: const TextStyle(color: kOr, fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          color: couleur,
                          child: Text(libelleType(chantier.type),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 10, fontWeight: FontWeight.w800,
                                letterSpacing: 1.2)),
                        ),
                        const SizedBox(height: 8),
                        Text(chantier.nom,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.w900)),
                      ],
                    )),
                  ]),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _InfoTile(icone: Icons.account_balance_wallet_outlined,
                    label: 'BUDGET',
                    valeur: formatBudget(chantier.budget),
                    couleur: kVertClair),
                  _InfoTile(icone: Icons.calendar_today_outlined,
                    label: 'DATE FIN',
                    valeur: formatDate(chantier.dateFinPrevue),
                    couleur: const Color(0xFF1565C0)),
                  _InfoTile(icone: Icons.timer_outlined,
                    label: 'DÉLAI',
                    valeur: jours < 0 ? '${jours.abs()} j dépassé' : 'J-$jours jours',
                    couleur: jours < 0 ? Colors.red.shade700 : Colors.orange.shade700),
                  _InfoTile(icone: Icons.trending_up,
                    label: 'STATUT',
                    valeur: chantier.avancement >= 80 ? 'En bonne voie'
                        : chantier.estEnRetard() ? 'En retard' : 'En cours',
                    couleur: chantier.estEnRetard()
                        ? Colors.red.shade700 : Colors.green.shade700),
                ],
              ),

              if (chantier.estEnRetard()) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border(left: BorderSide(
                        color: Colors.red.shade700, width: 4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade700, size: 22),
                    const SizedBox(width: 10),
                    Text('Ce chantier est EN RETARD !',
                      style: TextStyle(color: Colors.red.shade700,
                          fontWeight: FontWeight.bold)),
                  ]),
                ),
              ],

              const SizedBox(height: 28),
              Row(children: [
                Expanded(child: _BtnAction(
                  label: 'MODIFIER',
                  icone: Icons.edit_outlined,
                  fond: kVertClair,
                  onTap: () => Navigator.pushNamed(context, '/formulaire',
                    arguments: {'onAjouter': (_) {},
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
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuler')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white),
                          onPressed: () {
                            onSupprimer(chantier.id);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
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
      color: Colors.white.withValues(alpha: 0.88),
      border: Border(top: BorderSide(color: couleur, width: 3)),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 9, color: couleur,
              fontWeight: FontWeight.w800, letterSpacing: 1)),
        ]),
        Text(valeur, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w700, color: kTexte),
            maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
  );
}

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
        Text(label, style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.w800, letterSpacing: 1)),
      ]),
    ),
  );
}
