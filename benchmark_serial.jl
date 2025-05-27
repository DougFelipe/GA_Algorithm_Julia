###############################################################################
# Benchmark Serial - Mede tempo total e salva resultado com timestamp
# Saída em: versao_serial_YYYYMMDD_HHMMSS.csv
###############################################################################

using Pkg; Pkg.activate(@__DIR__)

include("biomarcador.jl")
include("fitness.jl")
include("genetic_algorithm.jl")

using .BiomarcadorModule
using .FitnessModule
using .GeneticAlgorithmModule
using BenchmarkTools
using Dates
using DelimitedFiles

# Geração de dados simulados
dados = [Biomarcador(i, "bio$i", rand() * 100) for i in 1:100]
ga = GeneticAlgorithm(dados, 50, 100, 0.8, 0.01)

println("⏱️ Executando macrobenchmark da função executar_limpo(ga)...")

# Executa e captura o benchmark
res = @benchmark executar_limpo($ga)

# Extração dos dados relevantes
tempo_min = minimum(res).time / 1e6  # ms
tempo_medio = median(res).time / 1e6  # ms
aloc_total = median(res).memory / 1024  # KiB

# Timestamp atual
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
filename = "versao_serial_$timestamp.csv"

# Conteúdo do CSV
header = ["Métrica", "Valor", "Unidade"]
conteudo = [
    ["Tempo mínimo", round(tempo_min, digits=3), "ms"];
    ["Tempo mediano", round(tempo_medio, digits=3), "ms"];
    ["Alocação média", round(aloc_total, digits=3), "KiB"];
]

# Salva como CSV
writedlm(filename, [header; conteudo], ',')

println("✅ Arquivo CSV salvo como: $filename")
