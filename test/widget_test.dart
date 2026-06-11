// test/widget_test.dart
// Tests unitaires et widget pour l'application ChantierSN
// Couvre le modèle Chantier et les helpers formatBudget / formatDate
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chantiersn/models/chantier.dart';
import 'package:chantiersn/utils/constants.dart';
import 'package:chantiersn/widgets/chantier_card.dart';

void main() {
  // ── Tests unitaires : classe Chantier ──────────────────────────────────────

  group('Chantier — estEnRetard()', () {
    test('retourne true si avancement < 50 ET date dans moins de 30 jours', () {
      final Chantier c = Chantier(
        id: 't1',
        nom: 'Test retard',
        type: TypeChantier.route,
        avancement: 30, // < 50
        budget: 1000000,
        dateFinPrevue: DateTime.now().add(const Duration(days: 10)), // < 30j
      );
      expect(c.estEnRetard(), true);
    });

    test('retourne false si avancement >= 50', () {
      final Chantier c = Chantier(
        id: 't2',
        nom: 'Test avancé',
        type: TypeChantier.pont,
        avancement: 65, // >= 50
        budget: 1000000,
        dateFinPrevue: DateTime.now().add(const Duration(days: 10)),
      );
      expect(c.estEnRetard(), false);
    });

    test('retourne false si date dans plus de 30 jours', () {
      final Chantier c = Chantier(
        id: 't3',
        nom: 'Test délai ok',
        type: TypeChantier.batiment,
        avancement: 20, // < 50 mais date loin
        budget: 1000000,
        dateFinPrevue: DateTime.now().add(const Duration(days: 60)), // > 30j
      );
      expect(c.estEnRetard(), false);
    });
  });

  group('Chantier — joursRestants()', () {
    test('retourne une valeur positive si la date est dans le futur', () {
      final Chantier c = Chantier(
        id: 't4',
        nom: 'Futur',
        type: TypeChantier.route,
        avancement: 50,
        budget: 1000000,
        dateFinPrevue: DateTime.now().add(const Duration(days: 45)),
      );
      expect(c.joursRestants(), greaterThan(0));
    });

    test('retourne une valeur négative si la date est dépassée', () {
      final Chantier c = Chantier(
        id: 't5',
        nom: 'Dépassé',
        type: TypeChantier.pont,
        avancement: 80,
        budget: 1000000,
        dateFinPrevue: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(c.joursRestants(), lessThan(0));
    });
  });

  group('Chantier — copyWith()', () {
    test('modifie seulement les champs spécifiés', () {
      final Chantier original = Chantier(
        id: 'c1',
        nom: 'Original',
        type: TypeChantier.route,
        avancement: 50,
        budget: 100000,
        dateFinPrevue: DateTime(2025, 12, 31),
      );
      final Chantier copie = original.copyWith(nom: 'Modifié', avancement: 75);

      // Les champs modifiés changent
      expect(copie.nom, 'Modifié');
      expect(copie.avancement, 75);

      // Les champs non modifiés restent identiques
      expect(copie.id, 'c1');
      expect(copie.type, TypeChantier.route);
      expect(copie.budget, 100000);
    });
  });

  // ── Tests helpers ──────────────────────────────────────────────────────────

  group('formatBudget()', () {
    test('formate 394000000000 en "394 000 000 000 FCFA"', () {
      expect(formatBudget(394000000000), '394 000 000 000 FCFA');
    });

    test('formate 1000 en "1 000 FCFA"', () {
      expect(formatBudget(1000), '1 000 FCFA');
    });

    test('formate un montant sans séparateur si < 1000', () {
      expect(formatBudget(500), '500 FCFA');
    });
  });

  group('formatDate()', () {
    test('formate DateTime(2025, 12, 31) en "31 décembre 2025"', () {
      expect(formatDate(DateTime(2025, 12, 31)), '31 décembre 2025');
    });

    test('formate DateTime(2024, 6, 30) en "30 juin 2024"', () {
      expect(formatDate(DateTime(2024, 6, 30)), '30 juin 2024');
    });

    test('formate DateTime(2024, 3, 1) en "1 mars 2024"', () {
      expect(formatDate(DateTime(2024, 3, 1)), '1 mars 2024');
    });
  });

  // ── Test widget : ChantierCard s'affiche correctement ─────────────────────

  group('ChantierCard — widget test', () {
    testWidgets('affiche le nom et le badge type', (WidgetTester tester) async {
      final Chantier chantier = Chantier(
        id: 'w1',
        nom: 'BRT Dakar',
        type: TypeChantier.route,
        avancement: 65,
        budget: 394000000000,
        dateFinPrevue: DateTime(2025, 12, 31),
      );

      // On enveloppe ChantierCard dans MaterialApp + Scaffold pour le contexte
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChantierCard(
              chantier: chantier,
              onTap: () {},
            ),
          ),
        ),
      );

      // Vérifie que le nom s'affiche
      expect(find.text('BRT Dakar'), findsOneWidget);

      // Vérifie que le badge "Route" s'affiche
      expect(find.text('Route'), findsOneWidget);

      // Vérifie que le budget formaté s'affiche
      expect(find.text('394 000 000 000 FCFA'), findsOneWidget);
    });

    testWidgets('affiche le badge EN RETARD si estEnRetard() est true',
        (WidgetTester tester) async {
      final Chantier chantier = Chantier(
        id: 'w2',
        nom: 'Chantier retardé',
        type: TypeChantier.batiment,
        avancement: 20, // < 50
        budget: 5000000,
        dateFinPrevue: DateTime.now().add(const Duration(days: 5)), // < 30j
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChantierCard(
              chantier: chantier,
              onTap: () {},
            ),
          ),
        ),
      );

      // Le badge ⚠ EN RETARD doit être visible
      expect(find.text('⚠ EN RETARD'), findsOneWidget);
    });
  });
}
