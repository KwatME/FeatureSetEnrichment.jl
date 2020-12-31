function score_set(
    element_::Vector{String},
    element_value_::Vector{Float64},
    is_in_::Vector{Int64};
    compute_cumulative_sum_::Bool = false,
)
    element_value_abs_ = abs.(element_value_)

    element_values_abs_in_sum = sum_in(element_value_abs_, is_in_)

    n_element = length(element_)

    d_down = -1 / (n_element - sum(is_in_))

    value = 0.0

    if compute_cumulative_sum_
        cumulative_sum_ = Vector{Float64}(undef, n_element)

    else
        cumulative_sum_ = nothing
    end

    ks = 0.0

    ks_abs = 0.0

    auc = 0.0

    @inbounds @fastmath @simd for index in 1:n_element
        if is_in_[index] == 1
            value += element_value_abs_[index] / element_values_abs_in_sum

        else
            value += d_down
        end

        if compute_cumulative_sum_
            cumulative_sum_[index] = value
        end

        value_abs = abs(value)

        if ks_abs < value_abs
            ks = value

            ks_abs = value_abs
        end

        auc += value
    end

    return cumulative_sum_, ks, auc
end

function score_set(
    element_::Vector{String},
    element_value_::Vector{Float64},
    set_element_::Vector{String};
    element_to_index::Union{Nothing, Dict{String, Int64}} = nothing,
    compute_cumulative_sum_::Bool = false,
)
    if element_to_index === nothing
        is_in_ = check_is_in(element_, set_element_)

    else
        is_in_ = check_is_in(element_to_index, set_element_)
    end

    return score_set(
        element_,
        element_value_,
        is_in_;
        compute_cumulative_sum_ = compute_cumulative_sum_,
    )
end
