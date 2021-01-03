#using StatsBase

function make_benchmark(name)
    
    if name == "ace"

        element_ = string.(collect('A':'Z'))

        element_score_ = float.(collect(1:length(element_)))

        set_element_ = string.(collect("ACE"))

    end

    return element_, element_score_, set_element_
    
end

#set_element_ = sample(element_, 3; replace = false)
