library(JuliaCall)
library(tidyverse)
library(glue)
library(feather)

# set up julia
j <- julia_setup()
j$library("MixedModels")

# get data
src <- "https://github.com/mikabr/aoa-prediction/raw/master/aoa_unified/saved_data/comp_data.feather"
download.file(src, "comp_data.feather")
comp_data <- read_feather("comp_data.feather")
j$assign("comp_data", comp_data)
j$assign("trials", comp_data$total)

# construct model formula
predictors <- c("frequency", "MLU", "final_frequency", "solo_frequency",
                "num_phons", "concreteness", "valence", "arousal", "babiness")
effects <- paste(predictors, collapse = ' + ')
effects_formula <- as.formula(
  glue("prop ~ ({effects} | language) + (age | item) + age + {effects}")
)
j$assign("form", effects_formula)

# set up and fit model
j$eval("@elapsed group_model = GeneralizedLinearMixedModel(form, comp_data, Binomial(), wt = trials)")
j$eval("@elapsed fit!(group_model, fast=true)")
