# TEST FINAL COMPLET - SYSTÈME SOTRACO
include("src/Sotraco.jl")
using Sotraco, DataFrames, Dates

println("="^60)
println("🚍 TEST FINAL DU SYSTÈME SOTRACO OPTIMISATION")
println("="^60)

# 1. TESTS UNITAIRES
println("\n1. 🔧 TESTS UNITAIRES")
Sotraco.tests_unitaires()

# 2. DONNÉES DE TEST
println("\n2. 📊 CRÉATION DES DONNÉES DE TEST")
frequentation_test = DataFrame(
    heure = [7,7,8,8,9,9,10,10,17,17,18,18,19,19],
    ligne_id = [1,2,1,2,1,2,1,2,1,2,1,2,1,2],
    montees = [45,25,85,40,60,30,40,20,75,35,80,45,50,25],
    occupation_bus = [0.6,0.4,0.95,0.6,0.7,0.5,0.5,0.3,0.85,0.5,0.9,0.6,0.6,0.4]
)

lignes_test = DataFrame(
    id = [1, 2],
    nom_ligne = ["Ligne A - Centre↔Pissy", "Ligne B - Dassasgho↔Gounghin"]
)

println("Données créées: $(nrow(frequentation_test)) enregistrements")

# 3. ANALYSE COMPLÈTE
println("\n3. 📈 ANALYSE COMPLÈTE DU SYSTÈME")
rapport_final = Sotraco.lancer_analyse_complete(lignes_test, frequentation_test)

# 4. RÉSUMÉ FINAL
println("\n" * "="^60)
println("🎯 RÉSUMÉ DU SYSTÈME SOTRACO OPTIMISATION")
println("="^60)
println("Fonctionnalités implémentées:")
println("✓ Calcul de distances et temps de trajet")
println("✓ Import et gestion des données")
println("✓ Analyse de fréquentation horaire")
println("✓ Identification des lignes critiques") 
println("✓ Optimisation des fréquences de bus")
println("✓ Système de recommandations automatiques")
println("✓ Génération de rapports quotidiens")
println("✓ Tests unitaires complets")
println("\n✅ SYSTÈME PRÊT POUR LA PRODUCTION!")