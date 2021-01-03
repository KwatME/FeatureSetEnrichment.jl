Float_ = Vector{Float64}

Int_ = Vector{Int64}

String_ = Vector{String}

include("sum_where_is.jl")

function score_set(element_::String_, element_score_::Float_, set_element_::String_; compute_cumulative_sum_::Bool = false)::Any

    return score_set(element_, element_score_, check_is(element_, set_element_); compute_cumulative_sum_ = compute_cumulative_sum_)

end

function score_set(element_::String_, element_score_::Float_, element_to_index::Dict{String, Int64}, set_element_::String_; compute_cumulative_sum_::Bool = false)::Any

    return score_set(element_, element_score_, check_is(element_to_index, set_element_); compute_cumulative_sum_ = compute_cumulative_sum_)

end

function score_set(element_::String_, element_score_::Float_, is_::Int_; compute_cumulative_sum_::Bool = false)::Any

    element_amplitude_ = abs.(element_score_)

    element_amplitude_in_sum = sum_where_is(element_amplitude_, is_)

    n_element = length(element_)

    d_down = -1 / (n_element - sum(is_))

    score = 0.0

    if compute_cumulative_sum_

        cumulative_sum_ = Float_(undef, n_element)

    else

        cumulative_sum_ = nothing

    end

    extreme = 0.0

    extreme_abs = 0.0

    auc = 0.0

    @inbounds @fastmath @simd for index in 1:n_element

        if is_[index] == 1

            score += element_amplitude_[index] / element_amplitude_in_sum

        else

            score += d_down

        end

        if compute_cumulative_sum_

            cumulative_sum_[index] = score

        end

        score_abs = abs(score)

        if extreme_abs < score_abs

            extreme = score

            extreme_abs = score_abs

        end

        auc += score

    end

    return cumulative_sum_, extreme, auc

end
