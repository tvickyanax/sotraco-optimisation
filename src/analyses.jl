# Analyses pour Sotraco
using Dates, Statistics, DataFrames

function analyser_heures_pointe(frequentation)
    println("ANALYSE DES HEURES DE POINTE")
    
    # Utiliser directement la colonne heure (déjà numérique)
    freq_par_heure = combine(groupby(frequentation, :heure),
        :montees => sum => :total_montees
    )
    
    sort!(freq_par_heure, :total_montees, rev=true)
    println("Heures par fréquentation :")
    show(freq_par_heure, allrows=true)
    
    # Afficher les heures de pointe - CORRIGÉ
    println("\n🏆 HEURES DE POINTE :")
    for i in 1:min(3, nrow(freq_par_heure))
        h = freq_par_heure[i, :heure]
        m = freq_par_heure[i, :total_montees]
        println("$i. $(h)h00 : $(m) montées")  # CORRECTION : $(m) au lieu de $m
    end
    
    return freq_par_heure
end

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

function optimiser_frequences(stats_lignes)
    println("⚙️ OPTIMISATION DES FRÉQUENCES")
    println("="^35)
    
    for ligne in eachrow(stats_lignes)
        occupation = ligne.taux_occupation
        
        if occupation > 0.4  # Correction : 0.4 au lieu de 40 (car c'est un ratio)
            action = "AUGMENTER"
            nouvelle_freq = "10-12 min"
        elseif occupation < 0.25  # Correction : 0.25 au lieu de 25
            action = "RÉDUIRE" 
            nouvelle_freq = "20-25 min"
        else
            action = "MAINTENIR"
            nouvelle_freq = "15 min"
        end
        
        # CORRECTION : multiplication par 100 ajoutée
        println("- $(ligne.nom_ligne): $(action) → $(nouvelle_freq) (occupation: $(round(occupation*100, digits=1))%)")
    end
end

function tests_unitaires()
    println("🧪 TESTS UNITAIRES")
    
    # Test de calcul de distance
    distance = Main.Sotraco.calculer_distance(12.3686, -1.5271, 12.3658, -1.5302)
    @assert distance > 0 "Distance doit être positive"
    println("✓ Test distance: OK")
    
    # Test de calcul de temps
    temps = Main.Sotraco.calculer_temps_trajet(10.0)
    @assert temps == 30.0 "10km à 20km/h = 30 min"
    println("✓ Test temps: OK")
    
    println("🎉 TOUS LES TESTS PASSENT!")
end

# ==============================================================================
# SYSTÈME DE RECOMMANDATIONS
# ==============================================================================

function generer_recommandations(stats_lignes, freq_par_heure)
    println("📊 SYSTÈME DE RECOMMANDATIONS")
    println("="^45)
    
    # CORRECTION : String[] au lieu de []
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
    
    # Affichage des recommandations
    for (i, rec) in enumerate(recommendations)
        println("$i. $rec")
    end
    
    return recommendations
end

# ==============================================================================
# GÉNÉRATION DE RAPPORTS
# ==============================================================================

function generer_rapport_quotidien(lignes, frequentation, date_rapport=Dates.now())
    println("📄 RAPPORT QUOTIDIEN - $(date_rapport)")
    println("="^50)
    
    # Métriques principales
    total_passagers = sum(frequentation.montees)
    nb_lignes = length(unique(frequentation.ligne_id))
    occupation_moyenne = mean(frequentation.occupation_bus) * 100
    
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