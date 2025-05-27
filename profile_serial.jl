using Pkg
Pkg.activate(@__DIR__)

include("main_serial.jl")
using Profile
using StatProfilerHTML

@profile executar(ga)  # grava profile

StatProfilerHTML.html_file("profiler_serial.html")  # gera relatório interativo
