module FitnessModule

using ..BiomarcadorModule

export avaliar_fitness

"""
    avaliar_fitness(cromossomo::BitVector, dados::Vector{Biomarcador})

Soma os valores de expressão tumoral dos biomarcadores ativos no cromossomo.
"""
function avaliar_fitness(cromossomo::BitVector, dados::Vector{Biomarcador})
    soma = sum(b.expressao_tumoral for (b, ativo) in zip(dados, cromossomo) if ativo)
    return soma
end

end
