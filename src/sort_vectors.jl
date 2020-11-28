function sort_vectors(vectors::Vector{Vector}; reverse::Bool=false,)

    sort_indices = sortperm(vectors[1]; rev=reverse,)

    return [vector[sort_indices] for vector in vectors]

end
