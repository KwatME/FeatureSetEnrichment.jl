function get_extreme_and_area(v::Vector{Float64})::Tuple{Float64, Float64}

    mi = minimum(v)

    ma = maximum(v)

    if abs(mi) < abs(ma)

        e = ma

    else

        e = mi

    end

    return e, sum(v) / convert(Float64, length(v))

end

export get_extreme_and_area
