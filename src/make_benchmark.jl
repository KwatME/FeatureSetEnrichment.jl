function make_benchmark(name)
    
    if name == "abc"

        element_ = string.(collect('A':'Z'))

        element_score_ = float.(collect(1:length(element_)))

        set_element_ = string.(collect("KWAT"))

    elseif name == "card"

        element_ = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

        element_score_ = float.(collect(2:14))

        set_element_ = ["8", "J"]

    end

    return element_, element_score_, set_element_
    
end
