#using CSV: read
#using DataFrames: DataFrame
#using StatsBase: sample
#
#using GCTGMT: read_gmt
#using Kraft: list_card
#
#function make_benchmark(id::String)::Tuple{Vector{String}, Vector{Float64}, Vector{String}}
#
#    split_ = split(id)
#    
#    if split_[1] == "card"
#
#        element_ = list_card()
#
#        element_score_ = convert.(Float64, -7:7)
#
#        set_element_ = string.(collect(split_[2]))
#    
#    elseif split_[1] == "random" 
#
#        element_ = ["e$i" for i in 1:parse(Int64, split_[2])]
#
#        n_element = length(element_)
#
#        v = randn(convert(Int64, n_element / 2))
#
#        element_score_ = sort([.-v; v])
#
#        set_element_ = sample(element_, parse(Int64, split_[3]))
#
#    elseif split_[1] == "myc"
#
#        data_directory_path = "../notebook/data/"
#
#        df = read(joinpath(data_directory_path, "gene_score.tsv"), DataFrame)
#
#        element_ = df[!, Symbol("Gene")]
#
#        element_score_ = df[!, Symbol("Score")]
#
#        set_to_element_ = read_gmt(joinpath(data_directory_path, "c2.all.v7.1.symbols.gmt"))
#
#        set_element_ = set_to_element_["COLLER_MYC_TARGETS_UP"]
#            
#    end
#
#    return element_, element_score_, set_element_
#    
#end
#
#export make_benchmark
