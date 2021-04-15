using CSV


using DataFrames: DataFrame


function compute_set_enrichment(
    gene_x_sample_path::String,
    gmt_path_::Vector{String},
    directory_path::String,
)::DataFrame


    gene_set_x_sample = DataFrame()


    return gene_set_x_sample


end


export compute_set_enrichment
