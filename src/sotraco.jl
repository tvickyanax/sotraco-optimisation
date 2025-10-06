module Sotraco

export Arret, Ligne, importer_arrets, importer_lignes, importer_frequentation, 
       explorer_donnees, calculer_distance, calculer_temps_trajet, analyser_performances,
       analyser_frequentation_horaire, analyser_arrets_frequentés, calculer_occupation_lignes,
       identifier_lignes_problematiques

using CSV, DataFrames, LinearAlgebra, Dates, Statistics

"Représente un arrêt de bus avec ses coordonnées"
struct Arret
    id::Int
    nom::String
    latitude::Float64
    longitude::Float64
end

"Représente une ligne de bus avec ses arrêts et sa distance"
struct Ligne
    id::Int
    nom::String
    arrets::Vector{Arret}
    distance_km::Float64
end

"""
Calculer la distance entre deux points géographiques en km
Utilise la formule de Haversine
"""
function calculer_distance(lat1::Float64, lon1::Float64, lat2::Float64, lon2::Float64)
    R = 6371.0  # Rayon de la Terre en km
    
    # Conversion en radians
    dlat = deg2rad(lat2 - lat1)
    dlon = deg2rad(lon2 - lon1)
    
    lat1_rad = deg2rad(lat1)
    lat2_rad = deg2rad(lat2)
    
    a = sin(dlat/2)^2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon/2)^2
    c = 2 * atan(sqrt(a), sqrt(1-a))
    
    return R * c
end

"""
Calculer le temps de trajet en minutes basé sur la distance
Vitesse moyenne supposée : 20 km/h en ville
"""
function calculer_temps_trajet(distance_km::Float64; vitesse_moyenne_kmh=20.0)
    return (distance_km / vitesse_moyenne_kmh) * 60
end

"""
Importer les arrêts depuis le fichier CSV
"""
function importer_arrets(chemin_fichier="data/arrets.csv")
    if !isfile(chemin_fichier)
        error("Fichier non trouvé: $chemin_fichier")
    end
    
    df = CSV.read(chemin_fichier, DataFrame)
    println("✓ Arrêts importés : $(nrow(df)) lignes")
    println("Colonnes disponibles : $(names(df))")
    
    # Aperçu des données
    println("\nAperçu des arrêts :")
    show(first(df, 5), allrows=true)
    println("\n")
    
    return df
end

"""
Importer les lignes de bus depuis le fichier CSV
"""
function importer_lignes(chemin_fichier="data/lignes_bus.csv")
    if !isfile(chemin_fichier)
        error("Fichier non trouvé: $chemin_fichier")
    end
    
    df = CSV.read(chemin_fichier, DataFrame)
    println("✓ Lignes importées : $(nrow(df)) lignes")
    println("Colonnes disponibles : $(names(df))")
    
    println("\nAperçu des lignes :")
    show(first(df, 5), allrows=true)
    println("\n")
    
    return df
end

"""
Importer la fréquentation depuis le fichier CSV
"""
function importer_frequentation(chemin_fichier="data/frequentation.csv")
    if !isfile(chemin_fichier)
        error("Fichier non trouvé: $chemin_fichier")
    end
    
    df = CSV.read(chemin_fichier, DataFrame)
    println("✓ Fréquentation importée : $(nrow(df)) lignes")
    println("Colonnes disponibles : $(names(df))")
    
    println("\nAperçu de la fréquentation :")
    show(first(df, 5), allrows=true)
    println("\n")
    
    return df
end

"""
Analyser la fréquentation horaire
"""
function analyser_frequentation_horaire(frequentation)
    println("📊 ANALYSE HORAIRE")
    frequentation[!, :heure_num] = hour.(frequentation.heure)
    
    freq_horaire = combine(groupby(frequentation, :heure_num), 
        :montees => sum => :total_montees,
        :descentes => sum => :total_descentes,
        nrow => :nb_passages
    )
    sort!(freq_horaire, :heure_num)
    
    println("Fréquentation par heure :")
    show(freq_horaire, allrows=true)
    println()
    
    return freq_horaire
end

"""
Analyser les arrêts les plus fréquentés
"""
function analyser_arrets_frequentés(arrets, frequentation)
    println("🏆 ARRÊTS LES PLUS FRÉQUENTÉS")
    
    freq_par_arret = combine(groupby(frequentation, :arret_id),
        :montees => sum => :total_montees,
        :descentes => sum => :total_descentes,
        nrow => :nb_passages
    )
    
    # Correction : utiliser le bon nom de colonne
    freq_par_arret = innerjoin(freq_par_arret, arrets, on=:arret_id => :id)
    sort!(freq_par_arret, :total_montees, rev=true)
    
    println("Top 10 des arrêts les plus fréquentés :")
    show(first(freq_par_arret, 10), allrows=true)
    println()
    
    return freq_par_arret
end

"""
Calculer l'occupation moyenne par ligne
"""
function calculer_occupation_lignes(lignes, frequentation)
    println("🚍 OCCUPATION DES LIGNES")
    
    occupation_lignes = combine(groupby(frequentation, :ligne_id),
        :montees => mean => :montees_mean,
        :descentes => mean => :descentes_mean,
        :occupation_bus => mean => :occupation_bus_mean,
        :capacite_bus => mean => :capacite_bus_mean
    )
    
    # Joindre avec les noms des lignes
    occupation_lignes = innerjoin(occupation_lignes, lignes, on=:ligne_id => :id)
    
    println("Taux d'occupation moyen par ligne :")
    show(occupation_lignes[:, [:nom_ligne, :montees_mean, :occupation_bus_mean, :capacite_bus_mean]], allrows=true)
    println()
    
    return occupation_lignes
end

"""
Identifier les lignes sous-utilisées et surchargées
"""
function identifier_lignes_problematiques(occupation_lignes)
    println("⚠️  DIAGNOSTIC DES LIGNES")
    
    lignes_sous_utilisees = filter(row -> row.occupation_bus_mean < 0.4, occupation_lignes)
    lignes_surchargees = filter(row -> row.occupation_bus_mean > 0.8, occupation_lignes)
    
    println("Lignes sous-utilisées (occupation < 40%) :")
    show(lignes_sous_utilisees[:, [:nom_ligne, :occupation_bus_mean]], allrows=true)
    
    println("\nLignes surchargées (occupation > 80%) :")
    show(lignes_surchargees[:, [:nom_ligne, :occupation_bus_mean]], allrows=true)
    
    return lignes_sous_utilisees, lignes_surchargees
end

"""
Analyser les performances du réseau
"""
function analyser_performances(arrets, lignes, frequentation)
    println("📈 ANALYSE DES PERFORMANCES DU RÉSEAU")
    println("="^50)
    
    # Test des fonctions de calcul
    println("\n🧮 TESTS DES CALCULS DE DISTANCE ET TEMPS")
    distance_test = calculer_distance(12.3686, -1.5271, 12.3658, -1.5302)
    temps_test = calculer_temps_trajet(distance_test)
    println("Distance test Gare Routière → Place de la Nation: $(round(distance_test, digits=2)) km")
    println("Temps de trajet estimé: $(round(temps_test, digits=1)) minutes")
    
    # Statistiques de fréquentation
    println("\n📊 STATISTIQUES DE FRÉQUENTATION")
    total_montees = sum(frequentation.montees)
    total_descentes = sum(frequentation.descentes)
    println("Total montées: $total_montees passagers")
    println("Total descentes: $total_descentes passagers")
    println("Moyenne montées par arrêt: $(round(mean(frequentation.montees), digits=2))")
    
    # Occupation moyenne
    if "occupation_bus" in names(frequentation)
        occupation_moyenne = mean(frequentation.occupation_bus)
        println("Occupation moyenne des bus: $(round(occupation_moyenne*100, digits=1))%")
    end
    
    return distance_test, temps_test
end

"""
Explorer la structure des données
"""
function explorer_donnees()
    println("🔍 EXPLORATION DES DONNÉES SOTRACO")
    println("="^50)
    
    # Importer les données
    try
        arrets = importer_arrets()
        lignes = importer_lignes()
        frequentation = importer_frequentation()
        
        # Analyses de performances
        analyser_performances(arrets, lignes, frequentation)
        
        return arrets, lignes, frequentation
        
    catch e
        println("❌ Erreur lors de l'import: $e")
        println("Vérifiez que les fichiers CSV sont dans le dossier 'data/'")
        return nothing, nothing, nothing
    end
end

# ==============================================================================
# SYSTÈME D'ANALYSES AVANCÉES
# ==============================================================================

export analyser_heures_pointe, identifier_lignes_critiques, optimiser_frequences,
       generer_recommandations, generer_rapport_quotidien, tests_unitaires,
       lancer_analyse_complete

"""
Analyser les heures de pointe détaillées
"""
function analyser_heures_pointe(frequentation)
    println("ANALYSE DES HEURES DE POINTE")
    
    # Utiliser directement la colonne heure (déjà numérique)
    freq_par_heure = combine(groupby(frequentation, :heure),
        :montees => sum => :total_montees
    )
    
    sort!(freq_par_heure, :total_montees, rev=true)
    println("Heures par fréquentation :")
    show(freq_par_heure, allrows=true)
    
    # Afficher les heures de pointe
    println("\n🏆 HEURES DE POINTE :")
    for i in 1:min(3, nrow(freq_par_heure))
        h = freq_par_heure[i, :heure]
        m = freq_par_heure[i, :total_montees]
        println("$i. $(h)h00 : $(m) montées")
    end
    
    return freq_par_heure
end

"""
Identifier les lignes critiques (surchargées)
"""
function identifier_lignes_critiques(lignes, frequentation)
    println("IDENTIFICATION DES LIGNES CRITIQUES")
    
    stats_lignes = combine(groupby(frequentation, :ligne_id),
        :montees => sum => :total_passagers,
        :occupation_bus => mean => :taux_occupation
    )
    
    stats_lignes = innerjoin(stats_lignes, lignes, on=:ligne_id => :id)
    
    println("Lignes surchargées :")
    surchargees = filter(row -> row.taux_occupation > 0.8, stats_lignes)
    show(surchargees[:, [:nom_ligne, :taux_occupation]], allrows=true)
    
    return stats_lignes
end

"""
Optimiser les fréquences de bus
"""
function optimiser_frequences(stats_lignes)
    println("⚙️ OPTIMISATION DES FRÉQUENCES")
    println("="^35)
    
    for ligne in eachrow(stats_lignes)
        occupation = ligne.taux_occupation
        
        if occupation > 0.4
            action = "AUGMENTER"
            nouvelle_freq = "10-12 min"
        elseif occupation < 0.25
            action = "RÉDUIRE" 
            nouvelle_freq = "20-25 min"
        else
            action = "MAINTENIR"
            nouvelle_freq = "15 min"
        end
        
        println("- $(ligne.nom_ligne): $(action) → $(nouvelle_freq) (occupation: $(round(occupation*100, digits=1))%)")
    end
end

"""
Générer des recommandations automatiques
"""
function generer_recommandations(stats_lignes, freq_par_heure)
    println("📊 SYSTÈME DE RECOMMANDATIONS")
    println("="^45)
    
    recommendations = String[]
    
    # Analyse de la fréquentation horaire
    heure_max = freq_par_heure[1, :heure]
    passagers_max = freq_par_heure[1, :total_montees]
    push!(recommendations, "🕐 Renforcer les effectifs à $(heure_max)h ($passagers_max passagers)")
    
    # Analyse des lignes surchargées
    lignes_surchargees = filter(row -> row.taux_occupation > 0.8, stats_lignes)
    for ligne in eachrow(lignes_surchargees)
        push!(recommendations, "🚍 Ajouter des bus sur la ligne $(ligne.nom_ligne) (occupation: $(round(ligne.taux_occupation*100, digits=1))%)")
    end
    
    # Recommandations par occupation
    for ligne in eachrow(stats_lignes)
        occupation = ligne.taux_occupation
        if occupation > 0.9
            push!(recommendations, "⚠️  URGENT: Doubler la fréquence ligne $(ligne.nom_ligne)")
        elseif occupation > 0.7
            push!(recommendations, "📈 Augmenter fréquence ligne $(ligne.nom_ligne)")
        elseif occupation < 0.3
            push!(recommendations, "📉 Réduire fréquence ligne $(ligne.nom_ligne)")
        end
    end
    
    # Affichage des recommandations
    for (i, rec) in enumerate(recommendations)
        println("$i. $rec")
    end
    
    return recommendations
end

"""
Générer un rapport quotidien complet
"""
function generer_rapport_quotidien(lignes, frequentation, date_rapport=Dates.now())
    println("📄 RAPPORT QUOTIDIEN - $(date_rapport)")
    println("="^50)
    
    # Métriques principales
    total_passagers = sum(frequentation.montees)
    nb_lignes = length(unique(frequentation.ligne_id))
    occupation_moyenne = mean(skipmissing(frequentation.occupation_bus)) * 100
    
    println("📈 MÉTRIQUES CLÉS:")
    println("   • Total passagers: $total_passagers")
    println("   • Nombre de lignes: $nb_lignes")
    println("   • Occupation moyenne: $(round(occupation_moyenne, digits=1))%")
    
    # Analyses détaillées
    freq_par_heure = analyser_heures_pointe(frequentation)
    stats_lignes = identifier_lignes_critiques(lignes, frequentation)
    optimiser_frequences(stats_lignes)
    recommandations = generer_recommandations(stats_lignes, freq_par_heure)
    
    return (
        total_passagers=total_passagers,
        nb_lignes=nb_lignes,
        occupation_moyenne=occupation_moyenne,
        recommandations=recommandations
    )
end

"""
Lancer une analyse complète du système
"""
function lancer_analyse_complete(lignes, frequentation)
    println("🚍 SYSTÈME SOTRACO - ANALYSE COMPLÈTE")
    println("="^50)
    
    # Génération du rapport complet
    rapport = generer_rapport_quotidien(lignes, frequentation)
    
    println("\n✅ ANALYSE TERMINÉE")
    return rapport
end

"""
Tests unitaires du système
"""
function tests_unitaires()
    println("🧪 TESTS UNITAIRES SOTRACO")
    
    # Test de calcul de distance
    distance = calculer_distance(12.3686, -1.5271, 12.3658, -1.5302)
    @assert distance > 0 "Distance doit être positive"
    println("✓ Test distance: OK ($(round(distance, digits=2)) km)")
    
    # Test de calcul de temps
    temps = calculer_temps_trajet(10.0)
    @assert temps == 30.0 "10km à 20km/h = 30 min"
    println("✓ Test temps: OK ($temps minutes)")
    
    println("🎉 TOUS LES TESTS PASSENT!")
end



end # module