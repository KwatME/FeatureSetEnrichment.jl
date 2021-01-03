function score_set_ks(element_::Vector{String}, element_score_::Vector{Float64}, set_element_::Vector{String}; track::Bool = false)::Tuple{Vector{Float64}, Float64, Float64}

    is_ = check_is(element_, set_element_)

    h_sum, m_sum = sum_h_m(element_score_, is_)

    d = 1.0 / m_sum

    set_score = 0.0
    
    n_element = length(element_)

    set_score_ = Vector{Float64}(undef, n_element)
    
    extreme = 0.0

    extreme_abs = 0.0

    area = 0.0

    @inbounds @fastmath @simd for index in 1:n_element

        if is_[index] == 1.0
           
            f = element_score_[index]
            
            if f < 0.0
                
                f = abs(f)
                
            end
            
            set_score += f / h_sum

        else

            set_score -= d

        end

        if track

            set_score_[index] = set_score

        end

        set_score_abs = abs(set_score)

        if extreme_abs < set_score_abs

            extreme = set_score

            extreme_abs = set_score_abs

        end

        area += set_score

    end

    return set_score_, extreme, area

end
