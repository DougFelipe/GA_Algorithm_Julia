###############################################################################
# PROFILE THREADS - Gera HTML com StatProfilerHTML para a versão paralela
###############################################################################

using Pkg
Pkg.activate(@__DIR__)  # Ativa o ambiente da pasta `threads/`

# Inclui os módulos necessários
include("biomarcador.jl")
include("fitness.jl")
include("leitura_biomarcadores.jl")
include("genetic_algorithm_threads.jl")

# Usa os namespaces dos módulos
using .BiomarcadorModule
using .FitnessModule
using .LeituraBiomarcadores
using .GeneticAlgorithmThreads
using StatProfilerHTML
using Dates

# Caminho para o dataset real
path = "biomarcadores_1gb.txt"
dados = carregar_biomarcadores(path)
ga = GeneticAlgorithm(dados, 50, 1, 0.8, 0.01)

println("⏱️ Gerando HTML com @profilehtml (versão paralela)...")

# Executa profiling com StatProfilerHTML
@profilehtml executar_parallel(ga)

# Define novo nome com timestamp
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
newname = "profiler_threads_$(timestamp).html"

# Copia o HTML gerado
cp("statprof/index.html", newname; force=true)

println("✅ Relatório salvo como: $newname — abra no navegador")
