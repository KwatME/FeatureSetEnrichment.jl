using DataFrames

function combine_gene_sets_dn_up(gene_set_x_element::DataFrame)
    column_1_name = names(gene_set_x_element)[1]

    gene_sets = gene_set_x_element[!, 1]

    gene_set_x_element_ = DataFrame(eltypes(gene_set_x_element), names(gene_set_x_element))

    for gene_set in gene_sets
        if endswith(gene_set, "_DN") || endswith(gene_set, "_UP")
            gene_set_ = gene_set[1:(end - 3)]

            if gene_set_ in gene_set_x_element_[!, 1]
                continue
            end

            dn_values = gene_set_x_element[gene_sets .== "$(gene_set_)_DN", 2:end]

            up_values = gene_set_x_element[gene_sets .== "$(gene_set_)_UP", 2:end]

            if size(dn_values, 1) == 0 || size(up_values, 1) == 0
                continue
            end

            combined_values = up_values .- dn_values

            insertcols!(combined_values, 1, column_1_name => gene_set_)

            push!(gene_set_x_element_, combined_values[1, :])
        end
    end

    return sort(vcat(gene_set_x_element, gene_set_x_element_), 1)
end
