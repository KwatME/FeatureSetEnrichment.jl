using Kraft: check_is

function score_set_ks(element_::Vector{String}, element_score_::Vector{Float64}, set_element_::Vector{String}; track::Bool = true, plot::Bool = true)::Tuple{Vector{Float64}, Float64, Float64}

    is_ = check_is(element_, set_element_)

    h_sum, m_sum = sum_h_m(element_score_, is_)

    d = 1.0 / m_sum

    set_score = 0.0
    
    n_element = length(element_)

    set_score_ = Vector{Float64}(undef, n_element)
    
    extreme = 0.0

    extreme_abs = 0.0

    area = 0.0

    @inbounds @fastmath @simd for i in n_element:-1:1

        if is_[i] == 1.0
           
            f = element_score_[i]
            
            if f < 0.0
                
                f = -f
                
            end
            
            set_score += f / h_sum

        else

            set_score -= d

        end

        if track

            set_score_[i] = set_score

        end

        if set_score < 0.0

            set_score_abs = -set_score

        else

            set_score_abs = set_score

        end

        if extreme_abs < set_score_abs

            extreme = set_score

            extreme_abs = set_score_abs

        end

        area += set_score

    end

    if track && plot

        display(plot_scoring_set(
            element_,
            element_score_,
            set_element_,
            is_,
            set_score_,
            extreme,
            area;
           ))

    end

    return set_score_, extreme, area / convert(Float64, n_element)

end

export score_set_ks
