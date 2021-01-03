using StatsBase: sample

using Kraft: shift_minimum

function make_benchmark(id)

    split_ = split(id)
    
    if split_[1] == "card"

        element_ = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "X"]

        element_score_ = float.(collect(-7:7))

        set_element_ = string.(collect(split_[2]))
    
    elseif split_[1] == "random" 

        element_ = ["e$index" for index in 1:parse(Int, split_[2])]

        n_element = length(element_)

        v = shift_minimum(randn(convert(Int64, n_element / 2)), "0<")

        element_score_ = sort([v; v])
            
        set_element_ = sample(element_, convert(Int64, ceil(n_element * parse(Float64, split_[3]))))
            
    end

    return element_, element_score_, set_element_
    
end

export make_benchmark
