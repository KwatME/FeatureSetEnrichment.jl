function sort_like(v_::Tuple{Vararg{Vector}}; reverse::Bool = false)::Tuple{Vararg{Vector}}
    
    sort_index_ = sortperm(v_[1]; rev = reverse)

    return Tuple(v[sort_index_] for v in v_)
    
end

export sort_like
