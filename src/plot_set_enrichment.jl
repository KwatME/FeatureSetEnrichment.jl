using PlotlyJS
using Printf
using Statistics

include("compute_set_enrichment.jl")
include("make_vector_01.jl")
include("sort_vectors.jl")


function plot_set_enrichment(
    element_values::Vector{Float64},
    elements::Vector{String},
    set_elements::Vector{String};
    height::Real=500,
    width::Real=800,
    line_width::Real=2,
    title1_text::String="Set Enrichment Plot",
    title2_text::String="",
    title1_font_size=20,
    element_value_name="Element<br>Value",
    axis_title_font_size=12,
)

    n_element = length(element_values)

    annotation_template = attr(
        xref="paper",
        yref="paper",
        xanchor="center",
        yanchor="middle",
        showarrow=false,
    )

    x_annotation_template = merge(annotation_template, attr(x=0.5, ))

    y_annotation_template = merge(
        annotation_template,
        attr(x=-0.125, font_size=axis_title_font_size),
    )

    title2_font_size = title1_font_size * 0.7

    yaxis1_domain = (0, 0.3)

    yaxis2_domain = (0.3, 0.4)

    yaxis3_domain = (0.4, 1)

    layout = Layout(
        height=height,
        width=width,
        margin_t=height * 0.2,
        margin_l=width * 0.2,
        legend_orientation="h",
        legend_x=0.5,
        legend_y=-0.2,
        legend_xanchor="center",
        legend_yanchor="middle",
        xaxis1_zeroline=false,
        xaxis1_showspikes=true,
        xaxis1_spikemode="across",
        xaxis1_spikedash="solid",
        yaxis3_domain=yaxis3_domain,
        yaxis3_showline=true,
        yaxis2_domain=yaxis2_domain,
        yaxis2_showticklabels=false,
        yaxis2_showgrid=false,
        yaxis1_domain=yaxis1_domain,
        yaxis1_showline=true,
        annotations=[
            merge(
                x_annotation_template,
                attr(y=1.25, text="<b>$title1_text</b>", font_size=title1_font_size),
            ),
            merge(
                x_annotation_template,
                attr(y=1.15, text="<b>$title2_text</b>", font_size=title2_font_size),
            ),
            merge(
                x_annotation_template,
                attr(
                    y=-0.1,
                    text="<b>Element Rank (n=$n_element)</b>",
                    font_size=axis_title_font_size,
                ),
            ),
            merge(
                y_annotation_template,
                attr(y=mean(yaxis3_domain), text="<b>Set<br>Enrichment</b>"),
            ),
            merge(
                y_annotation_template,
                attr(y=mean(yaxis2_domain), text="<b>Set<br>Member</b>"),
            ),
            merge(
                y_annotation_template,
                attr(y=mean(yaxis1_domain), text="<b>$element_value_name</b>"),
            ),
        ],
    )

    x = 1:n_element

    element_values, elements = sort_vectors([element_values, elements]; reverse=true,)

    element_values_trace = scatter(
        name="Element Value",
        x=x,
        y=element_values,
        text=elements,
        line_width=line_width,
        line_color="#ffb61e",
        fill="tozeroy",
    )

    set_elements_01 = make_vector_01(elements, set_elements)

    set_elements_bit = BitVector(set_elements_01)

    set_elements_trace = scatter(
        name="Set Element",
        yaxis="y2",
        x=x[set_elements_bit],
        y=zeros(sum(set_elements_01)),
        text=elements[set_elements_bit],
        mode="markers",
        marker_symbol="line-ns-open",
        marker_size=height * (yaxis2_domain[2] - yaxis2_domain[1]) * 0.25,
        marker_line_width=line_width,
        marker_color="#006c7f",
        hoverinfo="name+x+text",
    )

    set_enrichments, ks, auc = compute_set_enrichment(
        element_values,
        elements,
        set_elements_01;
        compute_cumulative_sums=true,
    )

    p_value = 0.05

    ks_string = @sprintf "%.2e" ks

    auc_string = @sprintf "%.2e" auc

    p_value_string = @sprintf "%.2e" p_value

    push!(
        layout["annotations"],
        merge(
            x_annotation_template,
            attr(
                y=1.05,
                text=join(
                    ("KS = $ks_string", "AUC = $auc_string", "P-Value = $p_value_string"),
                    "     ",
                ),
                font_size=title2_font_size,
                font_color="#913228",
            ),
        ),
    )

    set_enrichments_trace = scatter(
        name="Set Enrichment",
        yaxis="y3",
        x=x,
        y=set_enrichments,
        text=elements,
        line_width=line_width,
        line_color="#8db255",
        fill="tozeroy",
    )

    plot([element_values_trace, set_elements_trace, set_enrichments_trace], layout)

end
