function sum_h_m(v::Vector{Float64}, is_::Vector{Float64})::Tuple{Float64, Float64}
    
    h = 0.0
    
    m = 0.0
    
    for index in 1:length(v)
        
        if is_[index] == 1.0
            
            f = v[index]
            
            if f < 0.0
                
                f = abs(f)
                
            end
            
            h += f
        
        else
            
            m += 1.0
            
        end
            
    end
    
    return h, m
        
end
