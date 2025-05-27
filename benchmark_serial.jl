using Pkg; Pkg.activate(@__DIR__)  # <-- ativa o ambiente da pasta onde o script está

include("main_serial.jl")
using BenchmarkTools

@btime executar($ga)
