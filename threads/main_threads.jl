###############################################################################
# MAIN THREADS - Executa o algoritmo genético com microbenchmark (paralelo)
# e salva os tempos e alocações por etapa em um CSV com timestamp
###############################################################################

using Pkg
Pkg.activate(@__DIR__)  # Ativa o ambiente da pasta `threads/`

# Inclui apenas os módulos da pasta atual
include("biomarcador.jl")
include("fitness.jl")
include("leitura_biomarcadores.jl")
include("genetic_algorithm_threads.jl")

# Usa os namespaces explicitamente
using .BiomarcadorModule
using .FitnessModule
using .LeituraBiomarcadores
using .GeneticAlgorithmThreads
using TimerOutputs
using Dates
using DelimitedFiles

# 🔁 Resetar TimerOutput antes de iniciar a execução
reset_timer!(GeneticAlgorithmThreads.to)

println("📥 Iniciando leitura do dataset...")

# 📂 Caminho local atualizado
path = "biomarcadores_1gb.txt"

# Leitura protegida
dados = LeituraBiomarcadores.carregar_biomarcadores(path)
println("✅ Dados carregados: $(length(dados)) biomarcadores")

# 🧬 Instancia o algoritmo genético com paralelismo
ga = GeneticAlgorithmThreads.GeneticAlgorithm(dados, 50, 1, 0.8, 0.01)

# ▶️ Executa com microbenchmark integrado (com TimerOutput)
println("🚀 Executando algoritmo genético com paralelismo...")
GeneticAlgorithmThreads.executar(ga)

# 📥 Exporta microbenchmark para CSV
buffer = IOBuffer()
TimerOutputs.print_timer(buffer, GeneticAlgorithmThreads.to)

output_text = String(take!(buffer))
lines = split(output_text, '\n')
dados_lidos = filter(l -> count(isspace, l) > 5 && occursin(r"\d", l), lines)

# Monta CSV
header = ["Etapa", "ncalls", "Tempo total", "% do total", "Tempo médio", "Aloc total", "% aloc", "Aloc média"]
conteudo = [split(strip(l)) for l in dados_lidos]

# 🔖 Nome do script atual (sem extensão)
script_name = "main_threads"

# 🕒 Timestamp
timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")

# 📄 Nome final do arquivo
filename = "$(script_name)_micro_$timestamp.csv"

# 💾 Salva CSV
writedlm(filename, [header; conteudo], ',')

println("📥 Microbenchmark salvo como: $filename")
println("🏁 Execução paralela concluída com sucesso.")
