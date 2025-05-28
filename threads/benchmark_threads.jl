using Pkg; Pkg.activate(@__DIR__)

include("biomarcador.jl")
include("fitness.jl")
include("leitura_biomarcadores.jl")
include("genetic_algorithm_threads.jl")

using .BiomarcadorModule
using .FitnessModule
using .LeituraBiomarcadores
using .GeneticAlgorithmThreads

using BenchmarkTools
using Dates
using DelimitedFiles

# 📂 Caminho local atualizado
path = "biomarcadores_1gb.txt"
dados = carregar_biomarcadores(path)
ga = GeneticAlgorithm(dados, 50, 100, 0.8, 0.01)

println("⏱️ Executando benchmark paralelo...")

res = @benchmark executar_parallel($ga)

tempo_min = minimum(res).time / 1e6
tempo_medio = median(res).time / 1e6
aloc_total = median(res).memory / 1024

script_name = "benchmark_threads"
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
filename = "$(script_name)_$timestamp.csv"

header = ["Métrica", "Valor", "Unidade"]
conteudo = [
    ["Tempo mínimo", round(tempo_min, digits=3), "ms"];
    ["Tempo mediano", round(tempo_medio, digits=3), "ms"];
    ["Alocação média", round(aloc_total, digits=3), "KiB"];
]

writedlm(filename, [header; conteudo], ',')
println("✅ Benchmark salvo como: $filename")
