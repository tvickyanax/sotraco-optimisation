# Optimisation du Réseau de Bus SOTRACO

Projet d'analyse du réseau de transport de Ouagadougou avec Julia.

##  Données
- 50 arrêts de bus
- 15 lignes de bus
- Données de fréquentation

##  Installation
```julia
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")

##  Utilisation
include("src/sotraco.jl")
using .Sotraco
arrets, lignes, frequentation = explorer_donnees()



**Remarquez que :**
- J'ai fermé le premier bloc de code avec ``` 
- Le deuxième bloc de code est séparé

## **MAINTENANT DANS POWERSHELL :**

```powershell
# 1. Se placer dans le dossier
cd "C:\Users\tvick\sotraco-optimisation"

# 2. Vérifier les fichiers
git status

# 3. Ajouter tout
git add .

# 4. Commit
git commit -m "Premier commit : module Sotraco avec README"

# 5. Push vers GitHub
git push origin main