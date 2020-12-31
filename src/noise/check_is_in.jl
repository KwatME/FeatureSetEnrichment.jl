function check_is_in(element_::Vector{String}, check_element_::Vector{String})
    n_element = length(element_)

    is_in_ = Vector{Int64}(undef, n_element)

    check_element_to_nothing =
        Dict(check_element => nothing for check_element in check_element_)

    @inbounds @fastmath @simd for index in 1:n_element
        if haskey(check_element_to_nothing, element_[index])
            is_in_[index] = 1

        else
            is_in_[index] = 0
        end
    end

    return is_in_
end

function check_is_in(element_to_index::Dict{String, Int64}, check_element_::Vector{String})
    is_in_ = fill(0, length(element_to_index))

    @inbounds @fastmath @simd for check_element in check_element_
        index = get(element_to_index, check_element, nothing)

        if index !== nothing
            is_in_[index] = 1
        end
    end

    return is_in_
end
