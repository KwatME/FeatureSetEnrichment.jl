function make_vector_01(elements::Vector{String}, elements_to_check::Vector{String})

    n_element = length(elements)

    vector_01 = Vector{Int64}(undef, n_element)

    element_to_check_nothing = Dict(element_to_check => nothing for element_to_check in elements_to_check)

    @inbounds @fastmath @simd for index = 1:n_element

        if haskey(element_to_check_nothing, elements[index])

            vector_01[index] = 1

        else

            vector_01[index] = 0

        end

    end

    return vector_01

end


function make_vector_01(
    element_index::Dict{String,Int64},
    elements_to_check::Vector{String},
)

    vector_01 = fill(0, length(element_index))

    @inbounds @fastmath @simd for element in elements_to_check

        index = get(element_index, element, nothing)

        if index !== nothing

            vector_01[index] = 1

        end

    end

    return vector_01

end
