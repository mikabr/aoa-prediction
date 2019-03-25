# aoa-prediction
Estimating and predicting words' age of acquisition

## Analysis pipeline

- aoa_unified/aoa_loading/predictors/childes/get_childes_data.py
- aoa_unified/aoa_loading/aoa_loading.Rmd
- aoa_unified/aoa_loading/aoa_analyses/aoa_modeling.Rmd
- aoa_unified/aoa_loading/aoa_analyses/aoa_consistency.Rmd
- reports/journal_paper/aoapred_si.Rmd
- reports/journal_paper/aoapred_openmind.Rmd

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

- RCall.jl,
- DataFrames.jl,
- MixedModels.jl,
- StatsModels.jl
