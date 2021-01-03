function sum_where_is(v::Vector{Float64}, is_::Vector{Float64})::Float64

    suM = 0.0
    
    for index in 1:length(v)

        if is_[index] == 1.0

            suM += v[index]

        end

    end

    return suM

end
