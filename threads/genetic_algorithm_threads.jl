module GeneticAlgorithmThreads

using ..BiomarcadorModule
using ..FitnessModule
using Random
using Base.Threads
using TimerOutputs

export GeneticAlgorithm, executar_parallel, executar, to

const to = TimerOutput()

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
        rng = TaskLocalRNG()
        crom = BitVector(undef, tamanho)
        for j in 1:tamanho
            crom[j] = rand(rng, Bool)
        end
        pop[i] = crom
    end
    return pop
end

function selecao_torneio(populacao::Vector{BitVector}, dados::Vector{Biomarcador}, rng)
    a = rand(rng, populacao)
    b = rand(rng, populacao)
    return avaliar_fitness(a, dados) > avaliar_fitness(b, dados) ? a : b
end

function crossover_1_ponto!(f1::BitVector, f2::BitVector, p1::BitVector, p2::BitVector, rng)
    len = length(p1)
    ponto = rand(rng, 1:len)
    for i in 1:len
        f1[i] = i <= ponto ? p1[i] : p2[i]
        f2[i] = i <= ponto ? p2[i] : p1[i]
    end
end

function mutacao!(cromossomo::BitVector, taxa::Float64, rng)
    for i in eachindex(cromossomo)
        if rand(rng) < taxa
            cromossomo[i] = !cromossomo[i]
        end
    end
end

function executar(ga::GeneticAlgorithm)
    @timeit to "Geração da População" begin
        populacao = gerar_populacao(ga)
    end

    tamanho = length(ga.dados)
    melhor_fitness = -Inf
    melhor_individuo = BitVector()

    filho1 = BitVector(undef, tamanho)
    filho2 = BitVector(undef, tamanho)

    for _ in 1:ga.num_generations
        nova_populacao = Vector{BitVector}(undef, ga.tamanho_populacao)
        fits = Vector{Float64}(undef, ga.tamanho_populacao)

        @threads for i in 1:2:ga.tamanho_populacao
            rng = TaskLocalRNG()
            local filho1 = BitVector(undef, tamanho)
            local filho2 = BitVector(undef, tamanho)

            #@timeit to "Seleção por Torneio"
             begin
                pai1 = selecao_torneio(populacao, ga.dados, rng)
                pai2 = selecao_torneio(populacao, ga.dados, rng)
            end

            if rand(rng) < ga.taxa_crossover
                #@timeit to "Crossover 1 Ponto" 
                begin
                    crossover_1_ponto!(filho1, filho2, pai1, pai2, rng)
                end
            else
                copyto!(filho1, pai1)
                copyto!(filho2, pai2)
            end

            #@timeit to "Mutação + Avaliação" 
            begin
                mutacao!(filho1, ga.taxa_mutacao, rng)
                mutacao!(filho2, ga.taxa_mutacao, rng)

                fits[i] = avaliar_fitness(filho1, ga.dados)
                nova_populacao[i] = filho1

                if i + 1 <= ga.tamanho_populacao
                    fits[i + 1] = avaliar_fitness(filho2, ga.dados)
                    nova_populacao[i + 1] = filho2
                end
            end
        end

        populacao = nova_populacao

        gen_idx = argmax(fits)
        gen_fit = fits[gen_idx]

        if gen_fit > melhor_fitness
            melhor_fitness = gen_fit
            melhor_individuo = copy(populacao[gen_idx])
        end
    end

    println("✅ Melhor fitness (paralelo): ", melhor_fitness)
end

function executar_parallel(ga::GeneticAlgorithm)
    populacao = gerar_populacao(ga)
    tamanho = length(ga.dados)
    melhor_fitness = -Inf
    melhor_individuo = BitVector()

    for _ in 1:ga.num_generations
        nova_populacao = Vector{BitVector}(undef, ga.tamanho_populacao)
        fits = Vector{Float64}(undef, ga.tamanho_populacao)

        @threads for i in 1:2:ga.tamanho_populacao
            rng = TaskLocalRNG()
            local filho1 = BitVector(undef, tamanho)
            local filho2 = BitVector(undef, tamanho)

            pai1 = selecao_torneio(populacao, ga.dados, rng)
            pai2 = selecao_torneio(populacao, ga.dados, rng)

            if rand(rng) < ga.taxa_crossover
                crossover_1_ponto!(filho1, filho2, pai1, pai2, rng)
            else
                copyto!(filho1, pai1)
                copyto!(filho2, pai2)
            end

            mutacao!(filho1, ga.taxa_mutacao, rng)
            mutacao!(filho2, ga.taxa_mutacao, rng)

            fits[i] = avaliar_fitness(filho1, ga.dados)
            nova_populacao[i] = filho1

            if i + 1 <= ga.tamanho_populacao
                fits[i + 1] = avaliar_fitness(filho2, ga.dados)
                nova_populacao[i + 1] = filho2
            end
        end

        populacao = nova_populacao

        gen_idx = argmax(fits)
        gen_fit = fits[gen_idx]

        if gen_fit > melhor_fitness
            melhor_fitness = gen_fit
            melhor_individuo = copy(populacao[gen_idx])
        end
    end

    println("✅ Melhor fitness (paralelo): ", melhor_fitness)
    return melhor_fitness
end

end
