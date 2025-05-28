module GeneticAlgorithmThreads

using ..BiomarcadorModule
using ..FitnessModule
using Random
using Base.Threads

export GeneticAlgorithm, executar_parallel

mutable struct GeneticAlgorithm
    dados::Vector{Biomarcador}
    tamanho_populacao::Int
    num_generations::Int
    taxa_crossover::Float64
    taxa_mutacao::Float64
end

function gerar_populacao(ga::GeneticAlgorithm)
    tamanho = length(ga.dados)
    pop = Vector{BitVector}(undef, ga.tamanho_populacao)
    @threads for i in 1:ga.tamanho_populacao
        crom = BitVector(undef, tamanho)
        for j in 1:tamanho
            crom[j] = rand(Bool)
        end
        pop[i] = crom
    end
    return pop
end

function selecao_torneio(populacao::Vector{BitVector}, dados::Vector{Biomarcador})
    a = rand(populacao)
    b = rand(populacao)
    return avaliar_fitness(a, dados) > avaliar_fitness(b, dados) ? a : b
end

function crossover_1_ponto!(f1::BitVector, f2::BitVector, p1::BitVector, p2::BitVector)
    len = length(p1)
    ponto = rand(1:len)
    for i in 1:len
        f1[i] = i <= ponto ? p1[i] : p2[i]
        f2[i] = i <= ponto ? p2[i] : p1[i]
    end
end

function mutacao!(cromossomo::BitVector, taxa::Float64)
    for i in eachindex(cromossomo)
        if rand() < taxa
            cromossomo[i] = !cromossomo[i]
        end
    end
end

function executar_parallel(ga::GeneticAlgorithm)
    populacao = gerar_populacao(ga)
    melhor_individuo = nothing
    melhor_fitness = -Inf
    tamanho = length(ga.dados)

    for _ in 1:ga.num_generations
        nova_populacao = Vector{BitVector}(undef, ga.tamanho_populacao)
        fits = Vector{Float64}(undef, ga.tamanho_populacao)

        @threads for i in 1:2:ga.tamanho_populacao
            local filho1 = BitVector(undef, tamanho)
            local filho2 = BitVector(undef, tamanho)

            pai1 = selecao_torneio(populacao, ga.dados)
            pai2 = selecao_torneio(populacao, ga.dados)

            if rand() < ga.taxa_crossover
                crossover_1_ponto!(filho1, filho2, pai1, pai2)
            else
                copyto!(filho1, pai1)
                copyto!(filho2, pai2)
            end

            mutacao!(filho1, ga.taxa_mutacao)
            mutacao!(filho2, ga.taxa_mutacao)

            nova_populacao[i] = copy(filho1)
            fit1 = avaliar_fitness(filho1, ga.dados)
            fits[i] = fit1

            if i + 1 <= ga.tamanho_populacao
                nova_populacao[i + 1] = copy(filho2)
                fit2 = avaliar_fitness(filho2, ga.dados)
                fits[i + 1] = fit2
            end
        end

        populacao = nova_populacao
        gen_best_fit = maximum(fits)
        if gen_best_fit > melhor_fitness
            melhor_fitness = gen_best_fit
            melhor_individuo = copy(populacao[argmax(fits)])
        end
    end

    println("✅ Melhor fitness (paralelo): ", melhor_fitness)
    return melhor_fitness
end

end
