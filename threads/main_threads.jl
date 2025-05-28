using Pkg; Pkg.activate(@__DIR__)  # Ativa o ambiente local da pasta threads

include("biomarcador.jl")
include("fitness.jl")
include("leitura_biomarcadores.jl")
include("genetic_algorithm_threads.jl")

using .BiomarcadorModule
using .FitnessModule
using .LeituraBiomarcadores
using .GeneticAlgorithmThreads

# 📂 Caminho local atualizado
path = "biomarcadores_1gb.txt"
dados = carregar_biomarcadores(path)

ga = GeneticAlgorithm(dados, 50, 100, 0.8, 0.01)
executar_parallel(ga)
