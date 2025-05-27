module FitnessModule

using ..BiomarcadorModule
export avaliar_fitness

# Soma os valores dos biomarcadores selecionados (true no cromossomo)
function avaliar_fitness(cromossomo::BitVector, dados::Vector{Biomarcador})
    soma = 0.0
    for i in eachindex(cromossomo)
        if cromossomo[i]
            soma += dados[i].valor
        end
    end
    return soma
end

end
