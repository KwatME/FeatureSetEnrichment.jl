using Plotly: Layout

using Information: compute_gjsd, compute_adkld
using Plot: plot_x_y
using Support:
    cumulate_sum_reverse, get_extreme_and_area, sort_like

function score_set_new(
    #
    element_::Vector{String},
    element_score_::Vector{Float64},
    #
    set_element_::Vector{String};
    #
    sort::Bool = true,
    #
    plot::Bool = true,
)::Dict{String, Tuple{Vector{Float64}, Float64, Float64}}

    #
    if sort

        element_score_, element_ =
            sort_like((element_score_, element_))

    end

    #
    a = abs.(element_score_)

    #
    is_h = check_is(element_, set_element_)

    is_m = 1.0 .- is_h

    #
    is_ha = is_h .* a

    #
    is_ha_p = is_ha / sum(is_ha)

    is_ha_p_cr = cumsum(is_ha_p) #.+ e

    is_ha_p_cl = cumulate_sum_reverse(is_ha_p) #.+ e

    #
    is_m_p = is_m / sum(is_m)

    is_m_p_cr = cumsum(is_m_p) #.+ e

    is_m_p_cl = cumulate_sum_reverse(is_m_p) #.+ e

    #
    e = eps()

    #
    a_p = a / sum(a)

    a_p_cr = cumsum(a_p) .+ e

    a_p_cl = cumulate_sum_reverse(a_p) .+ e

    #
    a_h = a .* is_h

    a_h_p = a_h / sum(a_h)

    a_h_p_cr = cumsum(a_h_p) .+ e

    a_h_p_cl = cumulate_sum_reverse(a_h_p) .+ e

    #
    a_m = a .* is_m

    a_m_p = a_m / sum(a_m)

    a_m_p_cr = cumsum(a_m_p) .+ e

    a_m_p_cl = cumulate_sum_reverse(a_m_p) .+ e

    #
    if plot

        #
        layout = Layout(xaxis_title = "Element")

        #
        if length(element_) < 100

            layout = merge(
                layout,
                Layout(
                    xaxis_tickvals = 1:length(element_),
                    xaxis_ticktext = element_,
                ),
            )

        end

        #
        display(
            plot_x_y(
                (element_score_,);
                layout = merge(
                    layout,
                    Layout(yaxis_title = "Score"),
                ),
            ),
        )

        #
        display(
            plot_x_y(
                (is_h, is_m);
                name_ = ("Hit", "Miss"),
                layout = merge(layout, Layout(title = "Is")),
            ),
        )

        #
        display(
            plot_x_y(
                (a,);
                layout = merge(
                    layout,
                    Layout(yaxis_title = "Amplitude"),
                ),
            ),
        )

        #
        display(
            plot_x_y(
                (is_ha_p, is_ha_p_cr, is_ha_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(
                    layout,
                    Layout(title = "Is Hit * Amplitude"),
                ),
            ),
        )

        display(
            plot_x_y(
                (is_m_p, is_m_p_cr, is_m_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(
                    layout,
                    Layout(title = "Is Miss"),
                ),
            ),
        )

        #
        display(
            plot_x_y(
                (a_p, a_p_cr, a_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(
                    layout,
                    Layout(title = "Amplitude"),
                ),
            ),
        )

        #
        display(
            plot_x_y(
                (a_h_p, a_h_p_cr, a_h_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(
                    layout,
                    Layout(title = "Amplitude Hit"),
                ),
            ),
        )

        display(
            plot_x_y(
                (a_m_p, a_m_p_cr, a_m_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(
                    layout,
                    Layout(title = "Amplitude Miss"),
                ),
            ),
        )

        #
        display(
            plot_x_y(
                (a_p_cr, a_h_p_cr, a_m_p_cr);
                name_ = ("Amplitude", "Hit", "Miss"),
                layout = merge(layout, Layout(title = "CR(P)")),
            ),
        )

        display(
            plot_x_y(
                (a_p_cl, a_h_p_cl, a_m_p_cl);
                name_ = ("Amplitude", "Hit", "Miss"),
                layout = merge(layout, Layout(title = "CL(P)")),
            ),
        )

    end

    #
    d = Dict{String, Tuple{Vector{Float64}, Float64, Float64}}()

    #
    for (k, set_score_) in (
        #
        ("Is KS < (classic)", is_ha_p_cl - is_m_p_cl),
        (
            "Is KS <>",
            (is_ha_p_cl - is_m_p_cl) - (is_ha_p_cr - is_m_p_cr),
        ),
        #
        ("Is GJSD <", compute_gjsd(is_ha_p_cl, is_m_p_cl)),
        (
            "Is GJSD <>",
            compute_gjsd(is_ha_p_cl, is_m_p_cl) -
            compute_gjsd(is_ha_p_cr, is_m_p_cr),
        ),
        #
        ("Is ADKLD <", compute_adkld(is_ha_p_cl, is_m_p_cl)),
        (
            "Is ADKLD <>",
            compute_adkld(is_ha_p_cl, is_m_p_cl) -
            compute_adkld(is_ha_p_cr, is_m_p_cr),
        ),
        #
        ("A KS <", a_h_p_cl - a_m_p_cl),
        (
            "A KS <>",
            (a_h_p_cl - a_m_p_cl) - (a_h_p_cr - a_m_p_cr),
        ),
        #
        ("A GJSDm <", compute_gjsd(a_h_p_cl, a_m_p_cl)),
        (
            "A GJSDm <>",
            compute_gjsd(a_h_p_cl, a_m_p_cl) -
            compute_gjsd(a_h_p_cr, a_m_p_cr),
        ),
        #
        ("A GJSDp <", compute_gjsd(a_h_p_cl, a_m_p_cl, a_p_cl)),
        (
            "A GJSDp <>",
            compute_gjsd(a_h_p_cl, a_m_p_cl, a_p_cl) -
            compute_gjsd(a_h_p_cr, a_m_p_cr, a_p_cr),
        ),
        #
        ("A ADKLD <", compute_adkld(a_h_p_cl, a_m_p_cl)),
        (
            "A ADKLD <>",
            compute_adkld(a_h_p_cl, a_m_p_cl) -
            compute_adkld(a_h_p_cr, a_m_p_cr),
        ),
    )

        #
        extreme, area = get_extreme_and_area(set_score_)

        #
        d[k] = (set_score_, extreme, area)

        #
        display(
            _plot(
                #
                element_,
                element_score_,
                #
                set_element_,
                #
                is_h,
                #
                set_score_,
                #
                extreme,
                area;
                #
                title_text = k,
            ),
        )

    end

    #
    return d

end

export score_set_new
