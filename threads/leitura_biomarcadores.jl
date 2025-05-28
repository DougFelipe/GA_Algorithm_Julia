module LeituraBiomarcadores

using ..BiomarcadorModule
using CSV, DataFrames

export carregar_biomarcadores

function carregar_biomarcadores(path::String)
    if !isfile(path)
        error("❌ Arquivo '$path' não encontrado.")
    end

    local df  # <== Define o df aqui no escopo externo

    try
        df = CSV.File(path; delim=';', header=1, ignorerepeated=true) |> DataFrame
    catch err
        error("❌ Erro ao ler o CSV: ", err)
    end

    try
        dados = Biomarcador[
            Biomarcador(
                row.BiomarcadorID,
                row.Expressao_Tumoral,
                row.Conservacao,
                row.Similaridade_Humana,
                row.Localizacao
            ) for row in eachrow(df)
        ]
    catch err
        error("❌ Erro ao transformar os dados do CSV em Biomarcador: ", err)
    end

    return dados
end

end
