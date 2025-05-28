module LeituraBiomarcadores

using ..BiomarcadorModule
using CSV, DataFrames

export carregar_biomarcadores

function carregar_biomarcadores(path::String)
    df = CSV.File(path; delim=';', header=1, ignorerepeated=true) |> DataFrame

    dados = Biomarcador[
        Biomarcador(
            row.BiomarcadorID,
            row.Expressao_Tumoral,       # já é Float64
            row.Conservacao,             # já é Int64
            row.Similaridade_Humana,     # já é Int64
            row.Localizacao              # já é Int64
        )
        for row in eachrow(df)
    ]

    return dados
end

end
