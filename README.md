# aoa-prediction
Estimating and predicting words' age of acquisition

## Analysis pipeline

1. `aoa_unified/aoa_loading/predictors/childes/get_childes_data.py`
1. `aoa_unified/aoa_loading/aoa_loading.Rmd`
1. `aoa_unified/aoa_loading/aoa_analyses/aoa_modeling.Rmd`
1. `aoa_unified/aoa_loading/aoa_analyses/aoa_consistency.Rmd`
1. `reports/journal_paper/aoapred_si.Rmd`
1. `reports/journal_paper/aoapred_openmind.Rmd`

## Dependencies

R, Python, and Julia

### R packages

From CRAN:
- tidyverse
- widyr
- ggthemes
- ggstance
- ggdendro
- ggridges
- cowplot
- glue
- knitr
- broom

From GitHub:
- langcog/langcog
- langcog/wordbankr
- mikabr/rticles
- mikabr/jglmm

### Python

- nltk

### Julia

- RCall.jl
- DataFrames.jl
- MixedModels.jl
- StatsModels.jl
