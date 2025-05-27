# Inclusão dos módulos
include("biomarcador.jl")
include("fitness.jl")
include("genetic_algorithm.jl")

using .BiomarcadorModule
using .FitnessModule
using .GeneticAlgorithmModule

# Gerar dados simulados
dados = [Biomarcador(i, "bio$i", rand()*100) for i in 1:100]

# Instanciar algoritmo com parâmetros padrão
ga = GeneticAlgorithm(dados, 50, 100, 0.8, 0.01)

# Executar versão serial
executar(ga)
