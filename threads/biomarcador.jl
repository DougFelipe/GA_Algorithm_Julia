module BiomarcadorModule

export Biomarcador

# Novo tipo com todos os campos relevantes do CSV
struct Biomarcador
    id::String
    expressao_tumoral::Float64
    conservacao::Int64
    similaridade_humana::Int64
    localizacao::Int64
end

end
