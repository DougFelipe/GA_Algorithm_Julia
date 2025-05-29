###############################################################################
# Benchmark Serial - Mede tempo total com dataset real
# e salva resultado em CSV com timestamp
# Saída em: benchmark_serial_YYYYMMDD_HHMMSS.csv
###############################################################################

using Pkg; Pkg.activate(@__DIR__)

# Inclusão dos módulos do projeto
include("biomarcador.jl")
include("fitness.jl")
include("genetic_algorithm.jl")
include("leitura_biomarcadores.jl")

# Importação dos namespaces
using .BiomarcadorModule
using .FitnessModule
using .GeneticAlgorithmModule
using .LeituraBiomarcadores

# Pacotes auxiliares
using BenchmarkTools
using Dates
using DelimitedFiles

# 📂 Caminho para o arquivo real (na mesma pasta)
path = "biomarcadores_1gb.txt"

# 🧬 Carrega os dados reais
dados = carregar_biomarcadores(path)

# Instancia o algoritmo genético
ga = GeneticAlgorithm(dados, 50, 1, 0.8, 0.01)

println("⏱️ Executando macrobenchmark da função executar_limpo(ga)...")

# Executa e coleta estatísticas
res = @benchmark executar_limpo($ga)

# Extrai métricas
tempo_min = minimum(res).time / 1e6       # ms
tempo_medio = median(res).time / 1e6      # ms
aloc_total = median(res).memory / 1024    # KiB

# Nome do script
script_name = "benchmark_serial"

# Timestamp e nome final
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
filename = "$(script_name)_$timestamp.csv"

# Prepara conteúdo
header = ["Métrica", "Valor", "Unidade"]
conteudo = [
    ["Tempo mínimo", round(tempo_min, digits=3), "ms"];
    ["Tempo mediano", round(tempo_medio, digits=3), "ms"];
    ["Alocação média", round(aloc_total, digits=3), "KiB"];
]

# Salva CSV
writedlm(filename, [header; conteudo], ',')

println("✅ Arquivo CSV salvo como: $filename")
