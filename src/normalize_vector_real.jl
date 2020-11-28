using Statistics
using StatsBase


function normalize_vector_real(vector::Vector{<:Real}, method::String)

    vector = Vector{Float64}(vector)

    is_not_nan = .!isnan.(vector)

    if !any(is_not_nan)

        return vector

    end

    vector_not_nan = vector[is_not_nan]

    if method == "-0-"

        vector_not_nan_normalized = (vector_not_nan .- mean(vector_not_nan)) /
                                    std(vector_not_nan)

    elseif method == "0-1"

        vector_not_nan_minimum = minimum(vector_not_nan)

        vector_not_nan_normalized = (vector_not_nan .- vector_not_nan_minimum) /
                                    (maximum(vector_not_nan) - vector_not_nan_minimum)

    elseif method == "sum"

        if any(vector_not_nan .< 0)

            error("can not normalize vector with any negative value with method sum.")

        end

        vector_not_nan_normalized = vector_not_nan / sum(vector_not_nan)

    elseif method == "1234"

        vector_not_nan_normalized = ordinalrank(vector_not_nan)

    elseif method == "1224"

        vector_not_nan_normalized = competerank(vector_not_nan)

    elseif method == "1223"

        vector_not_nan_normalized = denserank(vector_not_nan)

    elseif method == "1 2.5 2.5 4"

        vector_not_nan_normalized = tiedrank(vector_not_nan)

    else

        error("method $method is not -0-, 0-1, sum, 1234, 1224, 1223, or 1 2.5 2.5 4.")

    end

    vector[is_not_nan] .= vector_not_nan_normalized

    return vector

end
