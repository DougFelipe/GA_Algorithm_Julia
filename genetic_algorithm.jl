module GeneticAlgorithmModule

using ..BiomarcadorModule
using ..FitnessModule
using Random
using TimerOutputs

export GeneticAlgorithm, executar, executar_limpo, to

const to = TimerOutput()

mutable struct GeneticAlgorithm
    dados::Vector{Biomarcador}
    tamanho_populacao::Int
    num_generations::Int
    taxa_crossover::Float64
    taxa_mutacao::Float64
end

# === População inicial ===
function gerar_populacao(ga::GeneticAlgorithm)
    tamanho = length(ga.dados)
    pop = Vector{BitVector}(undef, ga.tamanho_populacao)
    for i in 1:ga.tamanho_populacao
        crom = BitVector(undef, tamanho)
        for j in 1:tamanho
            crom[j] = rand(Bool)
        end
        pop[i] = crom
    end
    return pop
end

# === Torneio ===
function selecao_torneio(populacao::Vector{BitVector}, dados::Vector{Biomarcador})
    a = rand(populacao)
    b = rand(populacao)
    return avaliar_fitness(a, dados) > avaliar_fitness(b, dados) ? a : b
end

# === Crossover otimizado in-place ===
function crossover_1_ponto!(f1::BitVector, f2::BitVector, p1::BitVector, p2::BitVector)
    len = length(p1)
    ponto = rand(1:len)
    for i in 1:len
        f1[i] = i <= ponto ? p1[i] : p2[i]
        f2[i] = i <= ponto ? p2[i] : p1[i]
    end
end

# === Mutação (já era in-place) ===
function mutacao!(cromossomo::BitVector, taxa::Float64)
    for i in eachindex(cromossomo)
        if rand() < taxa
            cromossomo[i] = !cromossomo[i]
        end
    end
end

# === Execução com TimerOutputs (microbenchmark) ===
function executar(ga::GeneticAlgorithm)
    @timeit to "Geração da População" begin
        populacao = gerar_populacao(ga)
    end

    melhor_individuo = nothing
    melhor_fitness = -Inf
    tamanho = length(ga.dados)

    filho1 = BitVector(undef, tamanho)
    filho2 = BitVector(undef, tamanho)

    for _ in 1:1
        nova_populacao = Vector{BitVector}(undef, ga.tamanho_populacao)
        i = 1

        while i <= ga.tamanho_populacao
            @timeit to "Seleção por Torneio" begin
                pai1 = selecao_torneio(populacao, ga.dados)
                pai2 = selecao_torneio(populacao, ga.dados)
            end

            if rand() < ga.taxa_crossover
                @timeit to "Crossover 1 Ponto" begin
                    crossover_1_ponto!(filho1, filho2, pai1, pai2)
                end
            else
                copyto!(filho1, pai1)
                copyto!(filho2, pai2)
            end

            @timeit to "Mutação + Avaliação" begin
                mutacao!(filho1, ga.taxa_mutacao)
                mutacao!(filho2, ga.taxa_mutacao)

                nova_populacao[i] = copy(filho1)
                fit1 = avaliar_fitness(filho1, ga.dados)
                if fit1 > melhor_fitness
                    melhor_fitness = fit1
                    melhor_individuo = copy(filho1)
                end

                if i + 1 <= ga.tamanho_populacao
                    nova_populacao[i + 1] = copy(filho2)
                    fit2 = avaliar_fitness(filho2, ga.dados)
                    if fit2 > melhor_fitness
                        melhor_fitness = fit2
                        melhor_individuo = copy(filho2)
                    end
                end
            end

            i += 2
        end
        populacao = nova_populacao
    end

    println("✅ Melhor fitness encontrado: ", melhor_fitness)
    println("📊 Microbenchmark por etapa:")
    show(to)
end

# === Execução limpa (macrobenchmark) ===
function executar_limpo(ga::GeneticAlgorithm)
    populacao = gerar_populacao(ga)
    melhor_individuo = nothing
    melhor_fitness = -Inf
    tamanho = length(ga.dados)

    filho1 = BitVector(undef, tamanho)
    filho2 = BitVector(undef, tamanho)

    for _ in 1:1
        nova_populacao = Vector{BitVector}(undef, ga.tamanho_populacao)
        i = 1

        while i <= ga.tamanho_populacao
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
            if fit1 > melhor_fitness
                melhor_fitness = fit1
                melhor_individuo = copy(filho1)
            end

            if i + 1 <= ga.tamanho_populacao
                nova_populacao[i + 1] = copy(filho2)
                fit2 = avaliar_fitness(filho2, ga.dados)
                if fit2 > melhor_fitness
                    melhor_fitness = fit2
                    melhor_individuo = copy(filho2)
                end
            end

            i += 2
        end
        populacao = nova_populacao
    end

    return melhor_fitness
end

end
