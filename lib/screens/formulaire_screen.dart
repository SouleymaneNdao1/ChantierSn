// screens/formulaire_screen.dart — ChantierSN
// Écran 3 : fiche de saisie / modification d'un chantier

import 'package:flutter/material.dart';
import '../models/chantier.dart';
import '../utils/constants.dart';

class FormulaireScreen extends StatefulWidget {
  final Function onAjouter, onModifier;
  final Chantier? chantier;
  const FormulaireScreen({super.key, required this.onAjouter,
    required this.onModifier, this.chantier});
  @override State<FormulaireScreen> createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomCtrl, _budgetCtrl, _dateCtrl;
  late TypeChantier _type;
  late double _avancement;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final c  = widget.chantier;
    _nomCtrl    = TextEditingController(text: c?.nom ?? '');
    _budgetCtrl = TextEditingController(text: c?.budget.toString() ?? '');
    _type       = c?.type ?? TypeChantier.route;
    _avancement = c?.avancement.toDouble() ?? 0;
    _date       = c?.dateFinPrevue;
    _dateCtrl   = TextEditingController(
        text: c != null ? formatDate(c.dateFinPrevue) : '');
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
    if (d != null) {
      setState(() {
        _date = d;
        _dateCtrl.text = formatDate(d);
      });
    }
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final modeEdition = widget.chantier != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        SafeArea(
          bottom: false,
          child: Container(
            color: Colors.black.withValues(alpha: 0.68),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: kOr.withValues(alpha: 0.7)),
                  ),
                  child: const Icon(Icons.arrow_back, color: kOr, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modeEdition ? 'MODIFIER LE CHANTIER' : 'NOUVEAU CHANTIER',
                      style: const TextStyle(color: kOr, fontSize: 13,
                          fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                    Text(
                      modeEdition
                          ? widget.chantier!.nom
                          : 'Renseigner les 5 rubriques',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: modeEdition ? Colors.orange.shade800 : kVertClair,
                child: Text(modeEdition ? 'ÉDITION' : 'CRÉATION',
                  style: const TextStyle(color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
            ]),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 30),
            child: Form(
              key: _formKey,
              child: Column(children: [
                _BlocChamp(
                  numero: '01', titre: 'DÉSIGNATION',
                  child: TextFormField(
                    controller: _nomCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    decoration: _decoChamp(
                        hint: 'Ex : BRT Dakar, TER Dakar…',
                        icone: Icons.construction_outlined),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Minimum 3 caractères' : null,
                  ),
                ),
                const SizedBox(height: 10),

                _BlocChamp(
                  numero: '02', titre: 'CATÉGORIE',
                  child: _TypeSelector(
                    value: _type,
                    onChanged: (t) => setState(() => _type = t),
                  ),
                ),
                const SizedBox(height: 10),

                _BlocChamp(
                  numero: '03', titre: 'AVANCEMENT',
                  child: _AvancementPicker(
                    value: _avancement,
                    onChanged: (v) => setState(() => _avancement = v),
                  ),
                ),
                const SizedBox(height: 10),

                _BlocChamp(
                  numero: '04', titre: 'BUDGET',
                  child: TextFormField(
                    controller: _budgetCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    decoration: _decoChamp(
                      hint: '394000000000',
                      icone: Icons.receipt_long_outlined,
                    ).copyWith(
                      suffixText: 'FCFA',
                      suffixStyle: const TextStyle(
                          color: kOr, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Budget obligatoire';
                      final b = int.tryParse(v.trim());
                      if (b == null || b <= 0) return 'Entier positif requis';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                _BlocChamp(
                  numero: '05', titre: 'DÉLAI',
                  child: GestureDetector(
                    onTap: _choisirDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 15),
                      color: Colors.white.withValues(alpha: 0.88),
                      child: Row(children: [
                        const Icon(Icons.event_outlined, size: 18, color: kGris),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _date != null
                                ? formatDate(_date!)
                                : 'Date de livraison prévue',
                            style: TextStyle(
                              color: _date != null ? kTexte : kGris,
                              fontWeight: _date != null
                                  ? FontWeight.w700 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          color: kOr,
                          child: const Text('CHOISIR',
                            style: TextStyle(fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8, color: Colors.black)),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _sauvegarder,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kVert,
                      border: Border(top: BorderSide(color: kOr, width: 3)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(modeEdition
                            ? Icons.check_circle_outline : Icons.add_task,
                            color: kOr, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          modeEdition
                              ? 'VALIDER LES MODIFICATIONS'
                              : 'ENREGISTRER LA FICHE',
                          style: const TextStyle(color: kOr,
                              fontWeight: FontWeight.w900,
                              fontSize: 13, letterSpacing: 1.5),
                        ),
                      ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  InputDecoration _decoChamp({required String hint, required IconData icone}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kGris, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.88),
        prefixIcon: Icon(icone, size: 18, color: kGris),
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFCCCCCC))),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFCCCCCC))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kOr, width: 2)),
        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      );
}

// ── Rubrique numérotée ──────────────────────────────────────
class _BlocChamp extends StatelessWidget {
  final String numero, titre;
  final Widget child;
  const _BlocChamp({required this.numero, required this.titre, required this.child});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        width: 44,
        color: Colors.black.withValues(alpha: 0.58),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(numero, style: const TextStyle(
              color: kOr, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Container(width: 18, height: 1, color: kOr.withValues(alpha: 0.5)),
          const SizedBox(height: 5),
          RotatedBox(
            quarterTurns: 3,
            child: Text(titre, style: const TextStyle(
              color: Colors.white38, fontSize: 7,
              fontWeight: FontWeight.w700, letterSpacing: 0.7),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
      const SizedBox(width: 2),
      Expanded(child: child),
    ]),
  );
}

// ── Sélecteur de type : 3 cartes visuelles ─────────────────
class _TypeSelector extends StatelessWidget {
  final TypeChantier value;
  final ValueChanged<TypeChantier> onChanged;
  const _TypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    _carte(TypeChantier.route,    Icons.add_road,  'ROUTE'),
    const SizedBox(width: 4),
    _carte(TypeChantier.pont,     Icons.foundation,'PONT'),
    const SizedBox(width: 4),
    _carte(TypeChantier.batiment, Icons.domain,    'BÂTIMENT'),
  ]);

  Widget _carte(TypeChantier t, IconData icone, String label) {
    final selected = value == t;
    final couleur  = couleurType(t);
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(t),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? couleur : Colors.white.withValues(alpha: 0.80),
            border: selected
                ? const Border(bottom: BorderSide(color: kOr, width: 3))
                : null,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icone, size: 24, color: selected ? Colors.white : couleur),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: selected ? Colors.white : kGris)),
          ]),
        ),
      ),
    );
  }
}

// ── Sélecteur d'avancement : barre + slider + graduations ──
class _AvancementPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _AvancementPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final pct = value.round();
    return Container(
      color: Colors.white.withValues(alpha: 0.88),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Stack(children: [
              Container(height: 12, color: Colors.grey.shade200),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(height: 12, color: couleurProg(pct)),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56, padding: const EdgeInsets.symmetric(vertical: 5),
            color: couleurProg(pct),
            child: Text('$pct%', textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ]),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: couleurProg(pct),
            thumbColor: couleurProg(pct),
            inactiveTrackColor: Colors.grey.shade300,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value, min: 0, max: 100, divisions: 100,
            onChanged: onChanged,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['0%', '25%', '50%', '75%', '100%'].map((s) =>
              Text(s, style: const TextStyle(fontSize: 9, color: kGris)),
          ).toList(),
        ),
      ]),
    );
  }
}
