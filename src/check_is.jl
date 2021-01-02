String_ = Vector{String}

Int_ = Vector{Int64}

function check_is(element_::String_, check_element_::String_)::Int_

    n_element = length(element_)

    is_ = Int_(undef, n_element)

    check_element_to_nothing = Dict(check_element => nothing for check_element in check_element_)

    @inbounds @fastmath @simd for index in 1:n_element

        if haskey(check_element_to_nothing, element_[index])

            is_[index] = 1

        else

            is_[index] = 0

        end

    end

    return is_

end


function check_is(element_to_index::Dict{String, Int64}, check_element_::String_)::Int_

    is_ = fill(0, length(element_to_index))

    @inbounds @fastmath @simd for check_element in check_element_

        index = get(element_to_index, check_element, nothing)

        if index !== nothing

            is_[index] = 1

        end

    end

    return is_
end

export check_is
