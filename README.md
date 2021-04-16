For set enrichment analysis.

## Install

```sh
julia
```

```julia
using Pkg: add

add(url="https://github.com/KwatME/FeatureSetEnrichment.jl")
```

Test

```sh
julia --eval 'using FeatureSetEnrichment; score_set(["a", "b", "c"], [-1.,0.,1.], ["a", "b"])'
```

## Use

See [examples](notebook/example.ipynb).

### For using the the python interface, check out [FeatureSetEnrichment.py](https://github.com/KwatME/FeatureSetEnrichment.py).

### For using the desktop application, check out [GSEA.js](https://github.com/KwatME/GSEA.js).
