using Kraft: cumulate_sum_reverse
using Information: compute_jsd

function score_set_pk(element_::Vector{String}, element_score_::Vector{Float64}, set_element_::Vector{String})::Tuple{Vector{Float64}, Float64, Float64}

    am_ = abs.(element_score_)

    is_h_ = check_is(element_, set_element_)

    is_m_ = 1.0 .- is_h_

    small_number = eps()

    am_p_ = am_ / sum(am_)

    am_p_cr_ = cumsum(am_p_) .+ small_number

    am_p_cl_ = cumulate_sum_reverse(am_p_) .+ small_number

    am_h_ = am_ .* is_h_

    am_h_p_ = am_h_ / sum(am_h_)

    am_h_p_cr_ = cumsum(am_h_p_) .+ small_number

    am_h_p_cl_ = cumulate_sum_reverse(am_h_p_) .+ small_number

    am_m_ = am_ .* is_m_

    am_m_p_ = am_m_ / sum(am_m_)

    am_m_p_cr_ = cumsum(am_m_p_) .+ small_number

    am_m_p_cl_ = cumulate_sum_reverse(am_m_p_) .+ small_number

    jsd_l_ = compute_jsd(am_h_p_cl_, am_m_p_cl_, am_p_cl_)

    jsd_r_ = compute_jsd(am_h_p_cr_, am_m_p_cr_, am_p_cr_)

    pk_ = jsd_l_ - jsd_r_

    set_score_ = pk_

    mi = minimum(set_score_)

    ma = maximum(set_score_)

    if abs(mi) < abs(ma)

        extreme = ma

    else

        extreme = mi

    end

    area = sum(set_score_)

    return set_score_, extreme, area

end

export score_set_pk
