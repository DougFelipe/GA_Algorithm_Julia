###############################################################################
# PROFILE SERIAL - Corrigido para mover statprof/index.html com timestamp
###############################################################################

using Pkg; Pkg.activate(@__DIR__)

include("biomarcador.jl")
include("fitness.jl")
include("genetic_algorithm.jl")
include("leitura_biomarcadores.jl")

using .BiomarcadorModule
using .FitnessModule
using .GeneticAlgorithmModule
using .LeituraBiomarcadores

using StatProfilerHTML
using Dates

# Caminho para o dataset real
path = "biomarcadores_1gb.txt"
dados = carregar_biomarcadores(path)
ga = GeneticAlgorithm(dados, 50, 100, 0.8, 0.01)

println("⏱️ Gerando HTML com @profilehtml...")

# Gera diretório e relatório: ./statprof/index.html
@profilehtml executar_limpo(ga)

# Define novo nome com timestamp
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
newname = "profiler_serial_$(timestamp).html"

# Copia o arquivo gerado (statprof/index.html)
cp("statprof/index.html", newname; force=true)

println("✅ Relatório salvo como: $newname — abra no navegador")
