library(JuliaCall)
library(glue)
library(tidyverse)
library(lme4)

# set up julia and julia packages
j_dir <- '/Applications/Julia-0.6.app/Contents/Resources/julia/bin/'
j <- julia_setup(JULIA_HOME = j_dir, verbose = TRUE)
j$library("MixedModels")
j$library("GLM")
j$library("DataFrames")

# construct model formula
predictors <- c("frequency", "MLU", "final_frequency", "solo_frequency",
                "num_phons", "concreteness", "valence", "arousal", "babiness")
effects <- paste("age", predictors, sep = " * ")
effects_formula <- as.formula(glue("prop ~ (age | item) + {paste(effects, collapse = ' + ')}"))
j$assign("form", effects_formula)

fit_lang_meas_model <- function(group_data) {
  message(glue("Fitting model for {unique(group_data$lang_meas)}..."))

  # pass formula and data
  j$assign("group_data", group_data)
  j$assign("trials", group_data$total)

  # set up and fit model
  j$eval("@elapsed group_model = GeneralizedLinearMixedModel(form, group_data, Binomial(), wt = trials)")
  j$eval("@elapsed fit!(group_model, fast=true)")

  # extract coefficients
  j$eval("coef = coeftable(group_model)")
  j$eval("coef_df = DataFrame(coef.cols)")
  j$eval("coef_df[4] = [ coef_df[4][i].v for i in 1:length(coef_df[4]) ]")
  j$eval("names!(coef_df, [ Symbol(nm) for nm in coef.colnms ])")
  j$eval("coef_df[:term] = coef.rownms")
  j$eval("coef_df")

}

load("../saved_data/uni_model_data.RData")
lang_results <- uni_model_data %>%
  mutate(total = as.double(num_true + num_false),
         prop = num_true / total,
         lang_meas = paste(language, measure)) %>%
  select(language, measure, lang_meas, item = uni_lemma, prop, total, age,
         !!predictors) %>%
  group_by(language, measure) %>%
  nest() %>%
  mutate(results = map(data, fit_lang_meas_model))

lang_coefs <- lang_results %>%
  select(-data) %>%
  unnest()
