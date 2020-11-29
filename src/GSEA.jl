module GSEA


function check_is_in(element_::Vector{String}, check_element_::Vector{String})

    n_element = length(element_)

    is_in_ = Vector{Int64}(undef, n_element)

    check_element_to_nothing = Dict(check_element => nothing for check_element in check_element_)

    @inbounds @fastmath @simd for index = 1:n_element

        if haskey(check_element_to_nothing, element_[index])

            is_in_[index] = 1

        else

            is_in_[index] = 0

        end

    end

    return is_in_

end


function check_is_in(
    element_to_index::Dict{String,Int64},
    check_element_::Vector{String},
)

    is_in_ = fill(0, length(element_to_index))

    @inbounds @fastmath @simd for check_element in check_element_

        index = get(element_to_index, check_element, nothing)

        if index !== nothing

            is_in_[index] = 1

        end

    end

    return is_in_

end


function sum_in(number_::Vector{<:Real}, is_in_::Vector{Int64})

    sum_ = eltype(number_)(0)

    @inbounds @fastmath @simd for index = 1:length(number_)

        if is_in_[index] == 1

            sum_ += number_[index]

        end

    end

    return sum_

end


function score_set(
    element_::Vector{String},
    element_value_::Vector{Float64},
    is_in_::Vector{Int64};
    compute_cumulative_sum_::Bool=false,
)

    element_value_abs_ = abs.(element_value_)

    element_values_abs_in_sum = sum_in(element_value_abs_, is_in_)

    n_element = length(element_)

    d_down = -1 / (n_element - sum(is_in_))

    value = 0.0

    if compute_cumulative_sum_

        cumulative_sum_ = Vector{Float64}(undef, n_element)

    else

        cumulative_sum_ = nothing

    end

    ks = 0.0

    ks_abs = 0.0

    auc = 0.0

    @inbounds @fastmath @simd for index = 1:n_element

        if is_in_[index] == 1

            value += element_value_abs_[index] / element_values_abs_in_sum

        else

            value += d_down

        end

        if compute_cumulative_sum_

            cumulative_sum_[index] = value

        end

        value_abs = abs(value)

        if ks_abs < value_abs

            ks = value

            ks_abs = value_abs

        end

        auc += value

    end

    return cumulative_sum_, ks, auc

end


function score_set(
    element_::Vector{String},
    element_value_::Vector{Float64},
    set_element_::Vector{String};
    element_to_index::Union{Nothing,Dict{String,Int64}}=nothing,
    compute_cumulative_sum_::Bool=false,
)

    if element_to_index === nothing

        is_in_ = check_is_in(element_, set_element_)

    else

        is_in_ = check_is_in(element_to_index, set_element_)

    end

    return score_set(
        element_,
        element_value_,
        is_in_;
        compute_cumulative_sum_=compute_cumulative_sum_,
    )

end


using Plotly
using Printf
using Statistics

function sort_vectors(vectors::Vector{Vector}; reverse::Bool=false,)

    sort_indices = sortperm(vectors[1]; rev=reverse,)

    return [vector[sort_indices] for vector in vectors]

end


function plot_set_enrichment(
    elements::Vector{String},
    element_values::Vector{Float64},
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

    set_elements_01 = check_is_in(elements, set_elements)

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

    set_enrichments, ks, auc = score_set(
        elements,
        element_values,
        set_elements_01;
        compute_cumulative_sum_=true,
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

export check_is_in, score_set, plot_set_enrichment

end
