function sum_where_is(real_::Vector{<:Real}, is_::Vector{Int64})

    sum_ = eltype(real_)(0)

    @inbounds @fastmath @simd for index in 1:length(real_)

        if is_[index] == 1

            sum_ += real_[index]

        end

    end

    return sum_

end
