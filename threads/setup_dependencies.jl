using Pkg

# Ativa o ambiente local da pasta threads/
Pkg.activate(@__DIR__)

# Adiciona os pacotes essenciais
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("TimerOutputs")
Pkg.add("BenchmarkTools")
Pkg.add("DelimitedFiles")  # este é parte da stdlib, mas mantido por segurança
