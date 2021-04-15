using Printf: @sprintf
using Plotly: Layout, attr, plot, scatter

using Support: get_center

function plot_scoring_set(
    element_::Vector{String},
    element_score_::Vector{Float64},
    set_element_::Vector{String},
    is_::Vector{Float64},
    set_score_::Vector{Float64},
    extreme::Float64,
    area::Float64;
    width::Real = 800,
    height::Real = 500,
    line_width::Real = 2.0,
    title_text::String = "Set Enrichment",
    title_font_size::Real = 24,
    element_value_name::String = "Element Score",
    axis_title_font_size::Real = 12,
)::Any

    n_element = length(element_)

    yaxis1_domain = (0.0, 0.24)

    yaxis2_domain = (0.24, 0.32)

    yaxis3_domain = (0.32, 1.0)

    annotation_template = attr(
        xref = "paper",
        yref = "paper",
        yanchor = "middle",
        showarrow = false,
    )

    x_annotation_template =
        merge(annotation_template, attr(xanchor = "center", x = 0.5))

    y_annotation_template = merge(
        annotation_template,
        attr(xanchor = "right", x = -0.08, font_size = axis_title_font_size),
    )

    layout = Layout(
        width = width,
        height = height,
        margin_l = width * 0.24,
        margin_t = height * 0.24,
        legend_orientation = "h",
        legend_x = 0.5,
        legend_y = -0.32,
        legend_xanchor = "center",
        legend_yanchor = "middle",
        xaxis1_zeroline = false,
        #xaxis1_showspikes = true,
        #xaxis1_spikemode = "across",
        #xaxis1_spikedash = "solid",
        yaxis3_domain = yaxis3_domain,
        yaxis3_showline = true,
        yaxis2_domain = yaxis2_domain,
        yaxis2_showticklabels = false,
        yaxis2_showgrid = false,
        yaxis1_domain = yaxis1_domain,
        yaxis1_showline = true,
        annotations = [
            merge(
                x_annotation_template,
                attr(
                    y = 1.24,
                    text = "<b>$title_text</b>",
                    font_size = title_font_size,
                ),
            ),
            merge(
                x_annotation_template,
                attr(y = -0.1, text = "<b>Element Rank (n=$n_element)</b>"),
            ),
            merge(
                y_annotation_template,
                attr(
                    y = get_center(yaxis3_domain...),
                    text = "<b>Set Score</b>",
                ),
            ),
            merge(
                y_annotation_template,
                attr(y = get_center(yaxis2_domain...), text = "<b>Set</b>"),
            ),
            merge(
                y_annotation_template,
                attr(
                    y = get_center(yaxis1_domain...),
                    text = "<b>$element_value_name</b>",
                ),
            ),
        ],
    )

    x = 1:n_element

    element_score_trace = scatter(
        name = "Element Score",
        x = x,
        y = element_score_,
        text = element_,
        line_width = line_width,
        line_color = "#4e40d8",
        fill = "tozeroy",
    )

    set_element_bit = BitVector(is_)

    set_element_trace = scatter(
        name = "Set",
        yaxis = "y2",
        x = x[set_element_bit],
        y = zeros(Int64(sum(is_))),
        text = element_[set_element_bit],
        mode = "markers",
        marker_symbol = "line-ns-open",
        marker_size = height * (yaxis2_domain[2] - yaxis2_domain[1]) * 0.64,
        marker_line_width = line_width,
        marker_color = "#9017e6",
        hoverinfo = "name+x+text",
    )

    extreme = @sprintf "%.2e" extreme

    area = @sprintf "%.2e" area

    push!(
        layout["annotations"],
        merge(
            x_annotation_template,
            attr(
                y = 1.12,
                text = join(
                    ("<b>Extreme = $extreme</b>", "<b>Area = $area</b>"),
                    "     ",
                ),
                font_size = title_font_size * 0.56,
                font_color = "#2a603b",
            ),
        ),
    )

    set_score_trace = scatter(
        name = "Set Score",
        yaxis = "y3",
        x = x,
        y = set_score_,
        text = element_,
        line_width = line_width,
        line_color = "#20d9ba",
        fill = "tozeroy",
    )

    return plot(
        [element_score_trace, set_element_trace, set_score_trace],
        layout,
    )

end

export plot_scoring_set
