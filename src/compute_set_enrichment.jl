using DataFrames
using Distributed

include("make_vector_01.jl")
include("sort_vectors.jl")
include("sum_vector_real.jl")


function compute_set_enrichment(
    element_values::Vector{Float64},
    elements::Vector{String},
    vector_01::Vector{Int64};
    compute_cumulative_sums::Bool=false,
)

    element_values_abs = abs.(element_values)

    element_values_abs_1_sum = sum_vector_real(element_values_abs, vector_01)

    n_element = length(elements)

    d_down = -1 / (n_element - sum(vector_01))

    value = 0.0

    if compute_cumulative_sums

        cumulative_sums = Vector{Float64}(undef, n_element)

    else

        cumulative_sums = nothing

    end

    ks = 0.0

    ks_abs = 0.0

    auc = 0.0

    @inbounds @fastmath @simd for index = 1:n_element

        if vector_01[index] == 1

            value += element_values_abs[index] / element_values_abs_1_sum

        else

            value += d_down

        end

        if compute_cumulative_sums

            cumulative_sums[index] = value

        end

        value_abs = abs(value)

        if ks_abs < value_abs

            ks = value

            ks_abs = value_abs

        end

        auc += value

    end

    return cumulative_sums, ks, auc

end


function compute_set_enrichment(
    element_values::Vector{Float64},
    elements::Vector{String},
    set_elements::Vector{String};
    element_index::Union{Nothing,Dict{String,Int64}}=nothing,
    compute_cumulative_sums::Bool=false,
)

    if element_index === nothing

        vector_01 = make_vector_01(elements, set_elements)

    else

        vector_01 = make_vector_01(element_index, set_elements)

    end

    return compute_set_enrichment(
        element_values,
        elements,
        vector_01;
        compute_cumulative_sums=compute_cumulative_sums,
    )

end


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
