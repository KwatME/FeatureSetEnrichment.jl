function compute_set_enrichment(
    element_values::Vector{Float64},
    elements::Vector{String},
    set_elements::Dict{String,Vector{String}};
    sort_::Bool=true,
)

    if sort_

        element_values, elements = sort_vectors([element_values, elements]; reverse=true,)

    end

    if length(set_elements) < 10

        element_index = nothing

    else

        element_index = Dict(element => index for (element, index) in zip(
            elements,
            1:length(elements),
        ))

    end

    set_enrichment = Dict{String,Tuple{Union{Nothing,Vector{Float64}},Float64,Float64}}()

    for (set, set_elements_) in set_elements

        set_enrichment[set] = compute_set_enrichment(
            element_values,
            elements,
            set_elements_;
            element_index=element_index,
        )

    end

    return set_enrichment

end


function compute_set_enrichment(
    element_x_sample::DataFrame,
    set_elements::Dict{String,Vector{String}},
    statistic::String,
)

    elements = element_x_sample[!, 1]

    set_x_sample = DataFrame(Symbol("Set") => sort(collect(keys(set_elements))))

    if statistic == "ks"

        set_enrichment_index = 2

    elseif statistic == "auc"

        set_enrichment_index = 3

    elseif statistic == "js"

        set_enrichment_index = 4

    end

    for sample in names(element_x_sample)[2:end]

        has_element_value = findall(!ismissing, element_x_sample[!, sample])

        set_enrichment = compute_set_enrichment(
            Vector{Float64}(element_x_sample[has_element_value, sample]),
            Vector{String}(elements[has_element_value]),
            set_elements,
        )

        set_x_sample[
            !,
            sample,
        ] = collect(set_enrichment[set][set_enrichment_index] for set in set_x_sample[
            !,
            Symbol("Set"),
        ])

    end

    return set_x_sample

end