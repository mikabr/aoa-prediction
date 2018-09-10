#!/Applications/Julia-0.6.app/Contents/Resources/julia/bin/julia

Pkg.checkout("MixedModels")
using MixedModels, DataFrames, RData

# english

eng_data = load("/Users/mikabr/projects/langcog/aoa-prediction/aoa_unified/aoa_analyses/eng_data.rda", convert=true)["eng_data"]

eng_trials = eng_data[:,:total]

eng_form = @formula(prop ~ (age | item) + age + frequency + MLU + final_frequency + solo_frequency + num_phons + concreteness + valence + arousal + babiness)

@elapsed eng_model = GeneralizedLinearMixedModel(eng_form, eng_data, Binomial(), wt = eng_trials)

@elapsed fit!(eng_model, fast=true, verbose=true)

# crossling

comp_data = load("/Users/mikabr/projects/langcog/aoa-prediction/aoa_unified/aoa_analyses/comp_data.rda", convert=true)["comp_data"]

comp_trials = comp_data[:,:total]

comp_form = @formula(prop ~ (frequency | language) + (age | item) + age + frequency + MLU + final_frequency + solo_frequency + num_phons + concreteness + valence + arousal + babiness)

comp_form = @formula(prop ~ (frequency + MLU + final_frequency + solo_frequency + num_phons + concreteness + valence + arousal + babiness | language) + (age | item) + age + frequency + MLU + final_frequency + solo_frequency + num_phons + concreteness + valence + arousal + babiness)

@elapsed comp_model = GeneralizedLinearMixedModel(comp_form, comp_data, Binomial(), wt = comp_trials)

@elapsed fit!(comp_model, fast=true, verbose=true)


using DataFrames, RData, MixedModels, StatsBase

const dat = convert(Dict{Symbol,DataFrame}, load(Pkg.dir("MixedModels", "test", "dat.rda")));

# works
mdl = GeneralizedLinearMixedModel(@formula(r2 ~ 1 + a + g + b + s + (1|id) + (1|item)), dat[:VerbAgg], Bernoulli());

# works
mdl = GeneralizedLinearMixedModel(@formula(r2 ~ 1 + a + g + b + s + (a|item)), dat[:VerbAgg], Bernoulli());

# works
mdl = GeneralizedLinearMixedModel(@formula(r2 ~ 1 + a + g + b + s + (a|item) + (1|id)), dat[:VerbAgg], Bernoulli());

# doesn't work
mdl = GeneralizedLinearMixedModel(@formula(r2 ~ 1 + a + g + b + s + (1|item) + (a|id)), dat[:VerbAgg], Bernoulli());



fm1 = LinearMixedModel(@formula(Y ~ 1+S+T+U+V+W+X+Z + (1+S+T+U+V+W+X+Z|G) + (1+S+T+U+V+W+X+Z|H)), dat[:kb07])

fm2 = GeneralizedLinearMixedModel(@formula(Y ~ 1+S+T+U+V+W+X+Z + (1+S+T+U+V+W+X+Z|G) + (1+S+T+U+V+W+X+Z|H)), dat[:kb07], Gaussian())
