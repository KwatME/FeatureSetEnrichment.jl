Float_ = Vector{Float64}

Int_ = Vector{Int}

String_ = Vector{String}

function score_set(element_::String_, element_score_::Float_, is_in_::Int_; compute_cumulative_sum_::Bool = false)::Any

    element_score_abs_ = abs.(element_score_)

    element_scores_abs_in_sum = sum_in(element_score_abs_, is_in_)

    n_element = length(element_)

    d_down = -1 / (n_element - sum(is_in_))

    score = 0.0

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
            score += element_score_abs_[index] / element_scores_abs_in_sum

        else
            score += d_down
        end

        if compute_cumulative_sum_
            cumulative_sum_[index] = score
        end

        score_abs = abs(score)

        if ks_abs < score_abs
            ks = score

            ks_abs = score_abs
        end

        auc += score
    end

    return cumulative_sum_, ks, auc
end

function score_set(element_::String_, element_score_::Float_, element_to_index::Union{Nothing, Dict{String, Int64}}; compute_cumulative_sum_::Bool = false)::Any

    if element_to_index === nothing

        is_ = check_is_in(element_, set_element_)

    else

        is_ = check_is_in(element_to_index, set_element_)

    end

    return score_set(element_, element_score_, is_; compute_cumulative_sum_ = compute_cumulative_sum_)

end

export score_set
