module GeneticAlgorithmModule

using ..BiomarcadorModule
using ..FitnessModule
using Random
using TimerOutputs

export GeneticAlgorithm, executar, executar_limpo  # <-- agora exporta também

const to = TimerOutput()

mutable struct GeneticAlgorithm
    dados::Vector{Biomarcador}
    tamanho_populacao::Int
    num_generations::Int
    taxa_crossover::Float64
    taxa_mutacao::Float64
end

function gerar_populacao(ga::GeneticAlgorithm)
    pop = BitVector[]
    tamanho = length(ga.dados)
    for _ in 1:ga.tamanho_populacao
        push!(pop, BitVector(rand(Bool, tamanho)))
    end
    return pop
end

function selecao_torneio(populacao::Vector{BitVector}, dados::Vector{Biomarcador})
    a = rand(populacao)
    b = rand(populacao)
    return avaliar_fitness(a, dados) > avaliar_fitness(b, dados) ? a : b
end

function crossover_1_ponto(p1::BitVector, p2::BitVector)
    len = length(p1)
    ponto = rand(1:len)
    f1 = [i <= ponto ? p1[i] : p2[i] for i in 1:len]
    f2 = [i <= ponto ? p2[i] : p1[i] for i in 1:len]
    return BitVector(f1), BitVector(f2)
end

function mutacao!(cromossomo::BitVector, taxa::Float64)
    for i in eachindex(cromossomo)
        if rand() < taxa
            cromossomo[i] = !cromossomo[i]
        end
    end
end

# 🔍 Microbenchmark ativo
function executar(ga::GeneticAlgorithm)
    @timeit to "Geração da População" begin
        populacao = gerar_populacao(ga)
    end

    melhor_individuo = nothing
    melhor_fitness = -Inf

    for _ in 1:ga.num_generations
        nova_populacao = BitVector[]
        while length(nova_populacao) < ga.tamanho_populacao
            @timeit to "Seleção por Torneio" begin
                pai1 = selecao_torneio(populacao, ga.dados)
                pai2 = selecao_torneio(populacao, ga.dados)
            end

            if rand() < ga.taxa_crossover
                @timeit to "Crossover 1 Ponto" begin
                    filho1, filho2 = crossover_1_ponto(pai1, pai2)
                end
            else
                filho1 = copy(pai1)
                filho2 = copy(pai2)
            end

            @timeit to "Mutação + Avaliação" begin
                mutacao!(filho1, ga.taxa_mutacao)
                mutacao!(filho2, ga.taxa_mutacao)

                for filho in (filho1, filho2)
                    push!(nova_populacao, filho)
                    fit = avaliar_fitness(filho, ga.dados)
                    if fit > melhor_fitness
                        melhor_fitness = fit
                        melhor_individuo = copy(filho)
                    end
                    if length(nova_populacao) == ga.tamanho_populacao
                        break
                    end
                end
            end
        end
        populacao = nova_populacao
    end

    println("✅ Melhor fitness encontrado: ", melhor_fitness)
    println("📊 Microbenchmark por etapa:")
    show(to)
end

# 🕓 Versão limpa para macrobenchmark
function executar_limpo(ga::GeneticAlgorithm)
    populacao = gerar_populacao(ga)
    melhor_individuo = nothing
    melhor_fitness = -Inf

    for _ in 1:ga.num_generations
        nova_populacao = BitVector[]
        while length(nova_populacao) < ga.tamanho_populacao
            pai1 = selecao_torneio(populacao, ga.dados)
            pai2 = selecao_torneio(populacao, ga.dados)

            if rand() < ga.taxa_crossover
                filho1, filho2 = crossover_1_ponto(pai1, pai2)
            else
                filho1 = copy(pai1)
                filho2 = copy(pai2)
            end

            mutacao!(filho1, ga.taxa_mutacao)
            mutacao!(filho2, ga.taxa_mutacao)

            for filho in (filho1, filho2)
                push!(nova_populacao, filho)
                fit = avaliar_fitness(filho, ga.dados)
                if fit > melhor_fitness
                    melhor_fitness = fit
                    melhor_individuo = copy(filho)
                end
                if length(nova_populacao) == ga.tamanho_populacao
                    break
                end
            end
        end
        populacao = nova_populacao
    end

    return melhor_fitness
end

end
