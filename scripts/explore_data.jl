using CSV
using DataFrames
include("../src/Sotraco.jl")
using .Sotraco

# Charger les CSV
lignes = CSV.read("data/lignes_bus.csv", DataFrame)
arrets = CSV.read("data/arrets.csv", DataFrame)
freq = CSV.read("data/frequentation.csv", DataFrame)

println("📊 Aperçu des données :")
println("Lignes : ", size(lignes))
println("Arrêts : ", size(arrets))
println("Fréquentation : ", size(freq))

println("\n--- LIGNES BUS ---")
first(lignes, 5) |> display

println("\n--- ARRETS ---")
first(arrets, 5) |> display

println("\n--- FREQUENTATION ---")
first(freq, 5) |> display
