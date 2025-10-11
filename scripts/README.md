# Optimisation du Réseau de Bus SOTRACO

Projet d'analyse du réseau de transport de Ouagadougou avec Julia.

## Données
- 50 arrêts de bus
- 15 lignes de bus
- Données de fréquentation


## Installation
```julia
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
```

## Utilisation
```julia
include("src/Sotraco.jl")
using .Sotraco
arrets, lignes, frequentation = explorer_donnees()
```

## Commandes GIT (PowerShell)
 ```powershell
cd "C:\Users\tvick\sotraco-optimisation"
git status
git add .
git commit -m "Mise à jour du projet SOTRACO"
git push origin main
```