# ChantierSN 🇸🇳

Application mobile Flutter de **suivi de chantiers d'infrastructure au Sénégal**.

> **ODD 9 — Industrie, innovation et infrastructure**  
> Auteur : **Pape Souleymane Ndao** — ESMT Licence 3 DAR26  
> Date : Juin 2026

---

## Présentation

ChantierSN permet aux agents de collectivités locales sénégalaises de suivre
l'avancement des grands chantiers d'infrastructure (routes, ponts, bâtiments).

---

## Fonctionnalités

| Fonctionnalité | Description |
|---|---|
|  Liste des chantiers | Affichage avec filtre avancement > 80% |
|  Détail d'un chantier | Barre d'avancement, budget, délai, alerte retard |
|  Ajouter un chantier | Formulaire avec validation complète |
|  Modifier un chantier | Pré-remplissage automatique du formulaire |
|  Supprimer un chantier | Confirmation par dialog |
| ℹ À propos | Infos étudiant + sources des données |

---

## Architecture

```
lib/
└── main.dart       ← fichier unique (contrainte pédagogique)
```

**Patterns utilisés :**
- État global dans `_ChantierAppState` (callbacks passés par navigation)
- Navigation nommée avec `onGenerateRoute`
- `StatefulWidget` et `StatelessWidget` justifiés par des commentaires
- Zéro package externe (`flutter/material.dart` uniquement)

---

## Données initiales

| Chantier | Type | Avancement | Budget (FCFA) | Source |
|---|---|---|---|---|
| BRT Dakar | Route | 65% | 394 000 000 000 | CETUD / Dakar Dem Dikk |
| TER Dakar-Diamniadio | Pont | 82% | 568 000 000 000 | APIX / Min. Transports |
| Autoroute Ila Touba | Route | 90% | 260 000 000 000 | AGEROUTE Sénégal |

---

## Lancer le projet

```bash
# 1. Générer les fichiers de plateforme (Android, iOS, web...)
flutter create . --project-name chantiersn

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

> **Note :** Le fichier `lib/main.dart` existant sera conservé.  
> Si `flutter create` propose de l'écraser, répondre **`n`** (no).

---

## Workflow Git (commits pédagogiques)

```bash
git add . && git commit -m "init: création projet Flutter ChantierSN"
git add . && git commit -m "feat: modèle Chantier, enum TypeChantier, méthodes"
git add . && git commit -m "feat: données initiales 3 chantiers réels Sénégal"
git add . && git commit -m "feat: navigation nommée 4 écrans et état global"
git add . && git commit -m "feat: widget réutilisable ChantierCard StatelessWidget"
git add . && git commit -m "feat: écran liste filtre et StatefulWidget setState"
git add . && git commit -m "feat: écran détail StatelessWidget passage arguments"
git add . && git commit -m "feat: formulaire création et édition avec validation"
git add . && git commit -m "feat: écran À propos infos étudiant et sources"
git add . && git commit -m "style: thème vert Sénégal badges colorés UI finale"
```

---

## Thème visuel

| Élément | Couleur | Code hex |
|---|---|---|
| Couleur primaire | Vert Sénégal | `#1B5E20` |
| Couleur secondaire | Jaune or | `#FFD600` |
| Badge Route | Vert foncé | `#1B5E20` |
| Badge Pont | Bleu foncé | `#1565C0` |
| Badge Bâtiment | Orange foncé | `#E65100` |
