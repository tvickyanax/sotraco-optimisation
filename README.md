# 🚍 SOTRACO-OPTIMISATION

Optimisation et analyse des données de transport urbain (SOTRACO) avec Julia.

---

## 📁 Structure du projet

```
SOTRACO-OPTIMISATION/
│
├── data/                     # Données sources (à créer)
│   ├── arrets.csv
│   ├── frequentation.csv
│   └── lignes_bus.csv
│
├── src/                      # Code source principal (module Julia)
│   └── SotracoOptimisation.jl
│
├── test/                     # Tests unitaires
│   └── runtests.jl
│
├── Project.toml              # Dépendances du projet
├── Manifest.toml             # Versions verrouillées
└── README.md                 # Documentation principale
```

---

## ⚙️ Installation

1. Télécharger **Julia (version 1.6 ou supérieure)** depuis [julialang.org](https://julialang.org)

2. Ouvrir Julia dans le dossier du projet :

```julia
cd("C:\\chemin\\vers\\SOTRACO-OPTIMISATION")
```

3. Activer l'environnement et installer les dépendances :

```julia
using Pkg
Pkg.activate(".")
Pkg.add(["DataFrames", "CSV", "Dates", "Statistics", "LinearAlgebra"])
```

---

## ▶️ Utilisation

### Chargement du module :
```julia
cd("C:\\chemin\\vers\\SOTRACO-OPTIMISATION")
include("src/SotracoOptimisation.jl")
using .SotracoOptimisation
```

### Exécution des tests unitaires :
```julia
SotracoOptimisation.tests_unitaires()
```

### Exploration des données :
```julia
arrets, lignes, frequentation = SotracoOptimisation.explorer_donnees()
```

### Analyse complète :
```julia
rapport = SotracoOptimisation.lancer_analyse_complete(lignes, frequentation)
```

---

## 📊 Fonctionnalités

### 🔍 Analyse de base
- `importer_arrets()` → Import des arrêts depuis CSV  
- `importer_lignes()` → Import des lignes de bus  
- `importer_frequentation()` → Import des données de fréquentation  
- `explorer_donnees()` → Exploration complète des données  

### 📈 Analyses avancées
- `analyser_frequentation_horaire()` → Analyse par créneau horaire  
- `analyser_arrets_frequentés()` → Identification des arrêts stratégiques  
- `identifier_lignes_problematiques()` → Détection des lignes sous/sur-utilisées  
- `optimiser_frequences()` → Recommandations d'optimisation  

### 🧮 Calculs
- `calculer_distance()` → Calcul de distances géographiques (formule Haversine)  
- `calculer_temps_trajet()` → Estimation des temps de parcours  

---

## 🧪 Tests

Pour exécuter les tests unitaires :
```julia
SotracoOptimisation.tests_unitaires()
```

---

## 📋 Prérequis des données

Créer le dossier `data/` avec les fichiers suivants :

| Fichier | Colonnes attendues |
|----------|--------------------|
| **arrets.csv** | id, nom, latitude, longitude |
| **lignes_bus.csv** | id, nom_ligne, arrets_ids, distance_km |
| **frequentation.csv** | heure, arret_id, ligne_id, montees, descentes, occupation_bus, capacite_bus |

---

## 🧑‍💻 Auteur

Projet développé par **@tvickyanax** dans le cadre d’une étude d’optimisation du transport urbain.

---

## 🪪 Licence

Ce projet est distribué sous licence **MIT** – voir le fichier `LICENSE` pour plus d’informations.

---

## 🔄 Mise à jour

**Dernière mise à jour :** 2025-10-12 17:20:39

### Principales modifications :
- Structure de projet Julia standardisée  
- Module `SotracoOptimisation` fonctionnel  
- Tests unitaires opérationnels  
- Système d’analyse complet des données de transport  

### Points clés à retenir :
- Le package fonctionne avec `include("src/SotracoOptimisation.jl")`  
- Les tests unitaires passent avec succès  
- Toutes les fonctions d’analyse sont disponibles  
- Prêt pour les démonstrations en vidéo 🎥

## 🎥 Démonstration Vidéo
[![Vidéo démo]  (https://youtu.be/jGlZ0UQIjOc)

## 📋 Description
Système d'optimisation pour le réseau SOTRACO de Ouagadougou
