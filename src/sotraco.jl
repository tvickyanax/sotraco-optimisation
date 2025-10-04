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

end # module