using Plotly: Layout

using Information: compute_jsd
using Kraft: cumulate_sum_reverse, sort_like
using Plot: plot_x_y

function score_set_new(element_::Vector{String}, element_score_::Vector{Float64}, set_element_::Vector{String}; plot::Bool = true)::Dict{String, Tuple{Vector{Float64}, Float64, Float64}}

    #
    d = Dict{String, Tuple{Vector{Float64}, Float64, Float64}}()

    #
    layout = Layout(xaxis_title = "Element", xaxis_ticktext = element_)

    if length(element_) < 100
        
        layout = merge(layout, Layout(xaxis_tickvals = 1:length(element_)))
        
    end

    #
    element_score_, element_ = sort_like((element_score_, element_))

    plot_x_y((element_score_,); layout = merge(layout, Layout(yaxis_title = "Score")))

    #
    is_h_ = check_is(element_, set_element_)

    is_m_ = 1.0 .- is_h_

    plot_x_y((is_h_, is_m_); name_ = ("Hit", "Miss"), layout = merge(layout, Layout(title = "Is")))

    #
    am_ = abs.(element_score_)

    plot_x_y((am_,); layout = merge(layout, Layout(yaxis_title = "Amplitude")))

    #
    is_h_am_ = is_h_ .* am_

    is_h_p_ = is_h_am_ / sum(is_h_am_)

    is_h_p_cl_ = cumulate_sum_reverse(is_h_p_)

    plot_x_y((is_h_p_, is_h_p_cl_); name_ = ("P", "CL(P)"), layout = merge(layout, Layout(title = "Is Hit * Amplitude")))

    #
    is_m_p_ = is_m_ / sum(is_m_)

    is_m_p_cl_ = cumulate_sum_reverse(is_m_p_)

    plot_x_y((is_m_p_, is_m_p_cl_); name_ = ("P", "CL(P)"), layout = merge(layout, Layout(title = "Is Miss")))
    
    #
    small_number = eps()

    #
    am_p_ = am_ / sum(am_)

    am_p_cr_ = cumsum(am_p_) .+ small_number

    am_p_cl_ = cumulate_sum_reverse(am_p_) .+ small_number

    plot_x_y((am_p_, am_p_cr_, am_p_cl_); name_ = ("P", "CR(P)", "CL(P)"), layout = merge(layout, Layout(title = "Amplitude")))

    #
    am_h_ = am_ .* is_h_

    am_h_p_ = am_h_ / sum(am_h_)

    am_h_p_cr_ = cumsum(am_h_p_) .+ small_number

    am_h_p_cl_ = cumulate_sum_reverse(am_h_p_) .+ small_number

    plot_x_y((am_h_p_, am_h_p_cr_, am_h_p_cl_); name_ = ("P", "CR(P)", "CL(P)"), layout = merge(layout, Layout(title = "Amplitude Hit")))

    #
    am_m_ = am_ .* is_m_

    am_m_p_ = am_m_ / sum(am_m_)

    am_m_p_cr_ = cumsum(am_m_p_) .+ small_number

    am_m_p_cl_ = cumulate_sum_reverse(am_m_p_) .+ small_number

    plot_x_y((am_m_p_, am_m_p_cr_, am_m_p_cl_); name_ = ("P", "CR(P)", "CL(P)"), layout = merge(layout, Layout(title = "Amplitude Miss")))

    #
    jsd_l_ = compute_jsd(am_h_p_cl_, am_m_p_cl_, am_p_cl_)

    display(plot_x_y((am_p_cl_, am_h_p_cl_, am_m_p_cl_); name_ = ("Amplitude", "Hit", "Miss"), layout = merge(layout, Layout(title = "CL(P)"))))

    plot_x_y((jsd_l_,); layout = merge(layout, Layout(title = "JSD L", yaxis_title = "Set Score")))

    #
    jsd_r_ = compute_jsd(am_h_p_cr_, am_m_p_cr_, am_p_cr_)

    display(plot_x_y((am_p_cr_, am_h_p_cr_, am_m_p_cr_); name_ = ("Amplitude", "Hit", "Miss"), layout = merge(layout, Layout(title = "CR(P)"))))

    plot_x_y((jsd_r_,); layout = merge(layout, Layout(title = "JSD R", yaxis_title = "Set Score")))

    #
    set_score_ = is_h_p_cl_ - is_m_p_cl_

    d["classic"] = (set_score_, get_extreme_and_area(set_score_)...)

    #
    set_score_ = jsd_l_ - jsd_r_

    d["am c jsd <->"] = (set_score_, get_extreme_and_area(set_score_)...)

    #
    if plot

        for (k, (set_score_, extreme, area)) in d
        
            println(k)
            
            display(plot_scoring_set(
                element_,
                element_score_,
                set_element_,
                is_h_,
                set_score_,
                extreme,
                area;
                title_text = k,
               ))
        end

    end

    return d

end

export score_set_new
