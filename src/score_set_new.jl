using DataStructures: OrderedDict
using Plotly: Layout

using Information:
    compute_kld, compute_jsd1, compute_jsd2, compute_jsd3, compute_jsd4
using Plot: plot_x_y
using Support: cumulate_sum_reverse, get_extreme_and_area, sort_like

function compute_ks(v1::Vector{Float64}, v2::Vector{Float64})::Vector{Float64}

    return v1 - v2

end

function score_set_new(
    element_::Vector{String},
    score_::Vector{Float64},
    set_element_::Vector{String};
    sort::Bool = true,
    plot::Bool = true,
)::Dict{String, Tuple{Vector{Float64}, Float64, Float64}}

    if sort

        score_, element_ = sort_like((score_, element_))

    end

    a = abs.(score_)

    is_h = check_is(element_, set_element_)

    is_m = 1.0 .- is_h

    is_ha = is_h .* a

    e = eps()

    is_ha_p = is_ha / sum(is_ha)

    is_ha_p_cr = cumsum(is_ha_p) .+ e

    is_ha_p_cl = cumulate_sum_reverse(is_ha_p) .+ e

    is_m_p = is_m / sum(is_m)

    is_m_p_cr = cumsum(is_m_p) .+ e

    is_m_p_cl = cumulate_sum_reverse(is_m_p) .+ e

    a_p = a / sum(a)

    a_p_cr = cumsum(a_p) .+ e

    a_p_cl = cumulate_sum_reverse(a_p) .+ e

    a_h = a .* is_h

    a_h_p = a_h / sum(a_h)

    a_h_p_cr = cumsum(a_h_p) .+ e

    a_h_p_cl = cumulate_sum_reverse(a_h_p) .+ e

    a_m = a .* is_m

    a_m_p = a_m / sum(a_m)

    a_m_p_cr = cumsum(a_m_p) .+ e

    a_m_p_cl = cumulate_sum_reverse(a_m_p) .+ e

    if plot

        layout = Layout(xaxis_title = "Element")

        if length(element_) < 100

            layout = merge(
                layout,
                Layout(
                    xaxis_tickvals = 1:length(element_),
                    xaxis_ticktext = element_,
                ),
            )

        end

        display(
            plot_x_y(
                (score_,);
                layout = merge(layout, Layout(yaxis_title = "Score")),
            ),
        )

        display(
            plot_x_y(
                (is_h, is_m);
                name_ = ("Hit", "Miss"),
                layout = merge(layout, Layout(title = "Is")),
            ),
        )

        display(
            plot_x_y((a,); layout = merge(layout, Layout(yaxis_title = "A"))),
        )

        display(
            plot_x_y(
                (is_ha_p, is_ha_p_cr, is_ha_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(layout, Layout(title = "Is Hit * A")),
            ),
        )

        display(
            plot_x_y(
                (is_m_p, is_m_p_cr, is_m_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(layout, Layout(title = "Is Miss")),
            ),
        )

        display(
            plot_x_y(
                (is_ha_p_cr, is_m_p_cr);
                name_ = ("Is Hit * A", "Is Miss"),
                layout = merge(layout, Layout(title = "CR(P)")),
            ),
        )

        display(
            plot_x_y(
                (is_ha_p_cl, is_m_p_cl);
                name_ = ("Is Hit * A", "Is Miss"),
                layout = merge(layout, Layout(title = "CL(P)")),
            ),
        )

        display(
            plot_x_y(
                (
                    compute_kld(is_ha_p_cr, is_m_p_cr),
                    compute_kld(is_m_p_cr, is_ha_p_cr),
                );
                name_ = ("KLD(Hit, Miss)", "KLD(Miss, Hit)"),
                layout = merge(layout, Layout(title = "CR(P(Is)")),
            ),
        )

        display(
            plot_x_y(
                (
                    compute_kld(is_ha_p_cl, is_m_p_cl),
                    compute_kld(is_m_p_cl, is_ha_p_cl),
                );
                name_ = ("KLD(Hit, Miss)", "KLD(Miss, Hit)"),
                layout = merge(layout, Layout(title = "CL(P(Is)")),
            ),
        )

        display(
            plot_x_y(
                (a_p, a_p_cr, a_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(layout, Layout(title = "A")),
            ),
        )

        display(
            plot_x_y(
                (a_h_p, a_h_p_cr, a_h_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(layout, Layout(title = "A Hit")),
            ),
        )

        display(
            plot_x_y(
                (a_m_p, a_m_p_cr, a_m_p_cl);
                name_ = ("P", "CR(P)", "CL(P)"),
                layout = merge(layout, Layout(title = "A Miss")),
            ),
        )

        display(
            plot_x_y(
                (a_p_cr, a_h_p_cr, a_m_p_cr);
                name_ = ("A", "Hit", "Miss"),
                layout = merge(layout, Layout(title = "CR(P)")),
            ),
        )

        display(
            plot_x_y(
                (a_p_cl, a_h_p_cl, a_m_p_cl);
                name_ = ("A", "Hit", "Miss"),
                layout = merge(layout, Layout(title = "CL(P)")),
            ),
        )

        display(
            plot_x_y(
                (
                    compute_kld(a_h_p_cr, a_m_p_cr),
                    compute_kld(a_m_p_cr, a_h_p_cr),
                );
                name_ = ("KLD(Hit, Miss)", "KLD(Miss, Hit)"),
                layout = merge(layout, Layout(title = "CR(P(A))")),
            ),
        )

        display(
            plot_x_y(
                (
                    compute_kld(a_h_p_cl, a_m_p_cl),
                    compute_kld(a_m_p_cl, a_h_p_cl),
                );
                name_ = ("KLD(Hit, Miss)", "KLD(Miss, Hit)"),
                layout = merge(layout, Layout(title = "CL(P(A))")),
            ),
        )

    end

    d = OrderedDict{String, Tuple{Vector{Float64}, Float64, Float64}}()

    for (kv, hl, ml, hr, mr) in (
        ("Is", is_ha_p_cl, is_m_p_cl, is_ha_p_cr, is_m_p_cr),
        ("A", a_h_p_cl, a_m_p_cl, a_h_p_cr, a_m_p_cr),
    )

        for (kf, f) in (
            ("KS", compute_ks),
            ("JSD1", compute_jsd1),
            ("JSD2", compute_jsd2),
            ("JSD3", compute_jsd3),
            ("JSD4", compute_jsd4),
        )

            l = f(hl, ml)

            r = f(hr, mr)

            lr = l - r

            p = [("$kv $kf <", l), ("$kv $kf >", r), ("$kv $kf <>", l - r)]

            if kv == "Is" && in(kf, ("JSD1", "JSD2"))

                l = f(hl, ml, a_p_cl)

                r = f(hr, mr, a_p_cr)

                lr = l - r

                p = vcat(
                    p,
                    [
                        ("$kv $(kf)w <", l),
                        ("$kv $(kf)w >", r),
                        ("$kv $(kf)w <>", l - r),
                    ],
                )

            end

            for (k, v) in p


                d[k] = (v, get_extreme_and_area(v)...)

            end

        end

    end

    if plot

        for (k, (set_score_, extreme, area)) in d

            display(
                _plot(
                    element_,
                    score_,
                    set_element_,
                    is_h,
                    set_score_,
                    extreme,
                    area;
                    title_text = k,
                ),
            )

        end

    end

    return d

end

function score_set_new(
    element_::Vector{String},
    score_::Vector{Float64},
    set_to_element_::Dict{String, Vector{String}};
    sort::Bool = true,
)::Dict{String, Dict{String, Tuple{Vector{Float64}, Float64, Float64}}}

    if sort

        score_, element_ = sort_like((score_, element_))

    end

    set_to_d =
        Dict{String, Dict{String, Tuple{Vector{Float64}, Float64, Float64}}}()

    for (set, set_element_) in set_to_element_

        set_to_d[set] = score_set_new(
            element_,
            score_,
            set_element_,
            sort = false,
            plot = false,
        )

    end

    return set_to_d

end

export score_set_new
