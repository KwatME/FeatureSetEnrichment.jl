Module for set enrichment analysis.

## Install

```sh
julia
```

```julia
using Pkg: add

add(url="https://github.com/KwatME/SEA.jl")
```

Test

```sh
julia --eval 'using SEA; score_set(["a", "b", "c"], [-1.,0.,1.], ["a", "b"])'
```

## Use

See [examples](notebook/example.ipynb).

#### For using the the python interface, check out [sea](https://github.com/KwatME/sea).

#### For using the desktop application, check out [gsea](https://github.com/KwatME/gsea).
