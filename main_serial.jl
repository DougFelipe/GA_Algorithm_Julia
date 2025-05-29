###############################################################################
# MAIN SERIAL - Executa o algoritmo genético com microbenchmark
# e salva os tempos e alocações por etapa em um CSV com timestamp
###############################################################################

using Pkg; Pkg.activate(@__DIR__)

# Inclui os módulos do projeto
include("biomarcador.jl")
include("fitness.jl")
include("genetic_algorithm.jl")
include("leitura_biomarcadores.jl")

# Carrega pacotes e módulos necessários
using .BiomarcadorModule
using .FitnessModule
using .GeneticAlgorithmModule
using .LeituraBiomarcadores
using TimerOutputs
using Dates
using DelimitedFiles

# 🔁 Resetar TimerOutput antes de iniciar a execução
reset_timer!(GeneticAlgorithmModule.to)

# 📂 Carrega o dataset real
path = "biomarcadores_1gb.txt"
dados = carregar_biomarcadores(path)

# 🧬 Instancia o algoritmo genético
ga = GeneticAlgorithm(dados, 50, 1, 0.8, 0.01)

# ▶️ Executa com microbenchmark integrado
executar(ga)

# 📥 Exporta microbenchmark para CSV

# Captura a saída do TimerOutput como texto
buffer = IOBuffer()
TimerOutputs.print_timer(buffer, GeneticAlgorithmModule.to)

# Processa a string e extrai linhas de dados
output_text = String(take!(buffer))
lines = split(output_text, '\n')
dados_lidos = filter(l -> count(isspace, l) > 5 && occursin(r"\d", l), lines)

# Monta CSV
header = ["Etapa", "ncalls", "Tempo total", "% do total", "Tempo médio", "Aloc total", "% aloc", "Aloc média"]
conteudo = [split(strip(l)) for l in dados_lidos]

# 🔖 Nome do script atual (sem extensão)
script_name = "main_serial"

# 🕒 Timestamp
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")

# 📄 Nome final do arquivo
filename = "$(script_name)_micro_$timestamp.csv"

# 💾 Salva CSV
writedlm(filename, [header; conteudo], ',')

println("📥 Microbenchmark salvo como: $filename")
