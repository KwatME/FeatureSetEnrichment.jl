Module for set enrichment analysis.

## Install

```sh
julia
```

```julia
using Pkg: add

add(url="https://github.com/KwatME/SEA.jl")
```

## Test

```sh
julia --eval 'using SEA; score_set(["a", "b", "c"], [-1.,0.,1.], ["a", "b"])'
```

## Use

See [examples](notebook/example.ipynb).

#### Check out the [python interface](https://github.com/KwatME/sea) and the [GSEA application](https://github.com/KwatME/gsea).
