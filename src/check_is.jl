function check_is(element_::Vector{String}, set_element_::Vector{String})::Vector{Float64}

    set_element_to_nothing = Dict(set_element => nothing for set_element in set_element_)

    return [Float64(haskey(set_element_to_nothing, element)) for element in element_]

end
