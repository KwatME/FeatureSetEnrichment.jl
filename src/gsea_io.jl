using CSV

include("combine_gene_sets_dn_up.jl")
include("compute_set_enrichment.jl")
include("read.jl")

function gsea_io(
    gene_x_sample_tsv_file_path::String,
    gmt_file_paths::Vector{String},
    output_directory_path::String;
    sample_normalization_method::Union{Nothing,String}=nothing,
    gene_set_keywords::Union{Nothing,Vector{String}}=nothing,
    n_required_gene_set_element::Union{Nothing,Int64}=nothing,
    statistic::String="ks",
)

    start_time = now()

    println("($start_time) GSEA...")

    print("Reading $gene_x_sample_tsv_file_path... ")

    gene_x_sample = CSV.read(gene_x_sample_tsv_file_path)

    gene_x_sample = gene_x_sample[.!ismissing.(gene_x_sample[!, 1]), :]

    n_gene, n_sample = size(gene_x_sample)

    println("There are $n_gene genes and $n_sample samples.")

    if sample_normalization_method !== nothing

        println("$sample_normalization_method normalizing each sample...")

        for name in names(gene_x_sample)[2:end]

            gene_x_sample[!, name] = normalize_vector_real(
                Vector{Float64}(gene_x_sample[!, name]),
                sample_normalization_method,
            )

        end

    end

    print("Reading $gmt_file_paths... ")

    gene_set_genes = read(gmt_file_paths)

    n_gene_set = length(gene_set_genes)

    println("Read $n_gene_set gene sets.")

    if gene_set_keywords !== nothing

        print("Selecting gene sets contain any of the keywords $gene_set_keywords... ")

        gene_set_genes = Dict(gene_set => genes_ for (gene_set, genes_) in gene_set_genes if any(occursin(
            gene_set_keyword,
            gene_set,
        ) for gene_set_keyword in gene_set_keywords))

        n_gene_set = length(gene_set_genes)

        println("Selected $n_gene_set gene sets.")

    end

    if n_required_gene_set_element !== nothing

        print("Selecting gene sets with $n_required_gene_set_element <= existing elements... ")

        gene_set_genes = Dict(gene_set => genes_ for (gene_set, genes_) in gene_set_genes if n_required_gene_set_element < length(intersect(
            genes_,
            gene_x_sample[!, 1],
        )))

        n_gene_set = length(gene_set_genes)

        println("Selected $n_gene_set gene sets.")

    end

    println("Computing set enrichment...")

    gene_set_x_sample = combine_gene_sets_dn_up(compute_set_enrichment(
        gene_x_sample,
        gene_set_genes,
        statistic,
    ))

    mkpath(output_directory_path)

    gene_set_x_sample_tsv_file_path = joinpath(
        output_directory_path,
        "gene_set_x_sample.tsv",
    )

    println("Writing $gene_set_x_sample_tsv_file_path...")

    CSV.write(gene_set_x_sample_tsv_file_path, gene_set_x_sample; delim='\t',)

    end_time = now()

    run_time = canonicalize(Dates.CompoundPeriod(end_time - start_time))

    println("($end_time) Done in $run_time.")

    return gene_set_x_sample_tsv_file_path

end
