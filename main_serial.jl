###############################################################################
# MAIN SERIAL - Executa o algoritmo genético com microbenchmark
# e salva os tempos e alocações por etapa em um CSV com timestamp
###############################################################################

using Pkg; Pkg.activate(@__DIR__)

include("biomarcador.jl")
include("fitness.jl")
include("genetic_algorithm.jl")

using .BiomarcadorModule
using .FitnessModule
using .GeneticAlgorithmModule
using TimerOutputs
using Dates
using DelimitedFiles

# 🔁 Resetar TimerOutput antes de iniciar a execução
reset_timer!(GeneticAlgorithmModule.to)

# 🧬 Geração de dados simulados
dados = [Biomarcador(i, "bio$i", rand() * 100) for i in 1:100]
ga = GeneticAlgorithm(dados, 50, 100, 0.8, 0.01)

# ▶️ Executa o algoritmo com medição por etapa
executar(ga)

# 📥 Exportar microbenchmark para CSV

# Captura a saída formatada como texto
buffer = IOBuffer()
TimerOutputs.print_timer(buffer, GeneticAlgorithmModule.to)

# Converte para texto e quebra em linhas
output_text = String(take!(buffer))
lines = split(output_text, '\n')

# Filtra apenas linhas com dados reais
dados_lidos = filter(l -> count(isspace, l) > 5 && occursin(r"\d", l), lines)

# Cabeçalho do CSV
header = ["Etapa", "ncalls", "Tempo total", "% do total", "Tempo médio", "Aloc total", "% aloc", "Aloc média"]
conteudo = [split(strip(l)) for l in dados_lidos]

# Timestamp e nome do arquivo
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
filename = "versao_serial_micro_$timestamp.csv"

# Salva arquivo CSV
writedlm(filename, [header; conteudo], ',')

println("📥 Microbenchmark salvo como: $filename")
