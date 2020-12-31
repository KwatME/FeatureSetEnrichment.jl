function sum_in(number_::Vector{<:Real}, is_in_::Vector{Int64})
    sum_ = eltype(number_)(0)

    @inbounds @fastmath @simd for index in 1:length(number_)
        if is_in_[index] == 1
            sum_ += number_[index]
        end
    end

    return sum_
end
