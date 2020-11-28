function sum_vector_real(vector_real::Vector{<:Real}, vector_01::Vector{Int64})

    sum_ = eltype(vector_real)(0)

    @inbounds @fastmath @simd for index = 1:length(vector_real)

        if vector_01[index] == 1

            sum_ += vector_real[index]

        end

    end

    return sum_

end
