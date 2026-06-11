// screens/liste_screen.dart — ChantierSN
// Écran 1 : liste des chantiers avec filtre et stats en header

import 'package:flutter/material.dart';
import '../models/chantier.dart';
import '../utils/constants.dart';
import '../widgets/chantier_card.dart';

class ListeScreen extends StatefulWidget {
  final List<Chantier> chantiers;
  final Function onAjouter, onModifier, onSupprimer;
  const ListeScreen({super.key, required this.chantiers,
    required this.onAjouter, required this.onModifier, required this.onSupprimer});
  @override State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  bool _filtreActif = false;

  List<Chantier> get _affiches => _filtreActif
      ? widget.chantiers.where((c) => c.avancement > 80).toList()
      : widget.chantiers;

  int get _budgetTotal    => widget.chantiers.fold(0, (s, c) => s + c.budget);
  int get _avgAvancement  => widget.chantiers.isEmpty ? 0 :
      widget.chantiers.fold(0, (s, c) => s + c.avancement) ~/ widget.chantiers.length;

  String _formatMilliards(int v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(0)} Mds';
    if (v >= 1000000)    return '${(v / 1000000).toStringAsFixed(0)} M';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.black.withValues(alpha: 0.60),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
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
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ChantierSN 🇸🇳',
                                  style: TextStyle(color: kOr, fontSize: 22,
                                      fontWeight: FontWeight.w900, letterSpacing: 1)),
                                const Text('Suivi d\'infrastructure',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ]),
                            Row(children: [
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
                          ]),
                        const SizedBox(height: 16),
                        Row(children: [
                          _StatBox(label: 'CHANTIERS',
                              valeur: '${widget.chantiers.length}'),
                          const SizedBox(width: 10),
                          _StatBox(label: 'AVG AVANCEMENT',
                              valeur: '$_avgAvancement%'),
                          const SizedBox(width: 10),
                          _StatBox(label: 'BUDGET TOTAL',
                              valeur: _formatMilliards(_budgetTotal)),
                        ]),
                      ]),
                  ),
                ),
              ]),
              title: _filtreActif
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      color: kOr,
                      child: const Text('Filtre : > 80%',
                        style: TextStyle(color: Colors.black,
                            fontSize: 13, fontWeight: FontWeight.bold)))
                  : null,
            ),
          ),

          _affiches.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.construction, size: 56, color: Colors.white38),
                        const SizedBox(height: 12),
                        Text(_filtreActif ? 'Aucun chantier > 80%' : 'Aucun chantier',
                          style: const TextStyle(color: Colors.white54)),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kOr,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.pushNamed(context, '/formulaire',
          arguments: {'onAjouter': widget.onAjouter,
            'onModifier': widget.onModifier, 'chantier': null}),
      ),
    );
  }
}

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
        color: actif ? kOr : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: actif ? Colors.black : Colors.white, size: 20),
    ),
  );
}

class _StatBox extends StatelessWidget {
  final String label, valeur;
  const _StatBox({required this.label, required this.valeur});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        border: Border.all(color: kOr.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(valeur, style: const TextStyle(
            color: kOr, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(
            color: Colors.white70, fontSize: 9, letterSpacing: 0.9)),
      ]),
    ),
  );
}
