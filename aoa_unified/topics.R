predictors <- c("frequency", "MLU", "final_frequency", "solo_frequency",
                #"kl_mean",
                "length", "concreteness", "valence", "arousal",
                "babiness")

lang_model_fun <- function(lang_measure_data, pred) {
  interaction_formula <- as.formula(
    sprintf("cbind(num_true, num_false) ~ (age | uni_lemma) + age + %s",
            paste(sprintf("age * %s", pred), collapse = " + "))
  )
  lme4::glmer(interaction_formula, family = "binomial", data = lang_measure_data)
}

aoa <- function(ages, props) {
  acq <- which(props > 0.5)
  if (length(acq)) ages[[min(acq)]] else NA
}

uni_model_data <- feather::read_feather("saved_data/uni_model_data.feather")

eng_data <- uni_model_data %>%
  filter(language == "English") %>%
  mutate(prop = num_true / (num_true + num_false)) %>%
  group_by_(.dots = c("measure", "uni_lemma", predictors)) %>%
  summarise(aoa = aoa(unscaled_age, prop)) %>%
  gather_("predictor", "value", predictors)

# ggplot(eng_data, aes(x = value, y = aoa)) +
#   facet_grid(predictor ~ measure) +
#   geom_point() +
#   geom_smooth(method = "lm")
#

freq <- uni_model_data %>%
  filter(language == "English", measure == "produces") %>%
  lang_model_fun("frequency")

childes <- uni_model_data %>%
  filter(language == "English", measure == "produces") %>%
  lang_model_fun(c("kl_mean", "frequency", "MLU", "final_frequency",
                   "solo_frequency"))

eng_kl <- uni_model_data %>%
  filter(language == "English", measure == "produces") %>%
  lang_model_fun(c(predictors, "kl_mean"))

eng <- uni_model_data %>%
  filter(language == "English", measure == "produces") %>%
  lang_model_fun(predictors)

lang_coef_fun <- function(lang_model) {
  broom::tidy(lang_model) %>%
    filter(term != "(Intercept)", term != "age", group == "fixed") %>%
    select(term, estimate, std.error) %>%
    mutate(interaction = ifelse(grepl(":", term), "interaction with age",
                                "main effect"),
           term = gsub("age:", "", term))
}

eng_coefs <- lang_coef_fun(eng)

term_order <- eng_coefs %>%
  filter(interaction == "main effect") %>%
  arrange(desc(abs(estimate))) %>%
  .$term

demo_coefs <- eng_coefs %>%
  mutate(term = factor(term, levels = rev(term_order)),
         interaction = factor(interaction,
                              levels = c("main effect", "interaction with age")))

ggplot(eng_coefs, aes(x = term, y = estimate)) +
  facet_grid(. ~ interaction) +
  geom_pointrange(aes(ymin = estimate - 1.96 * std.error,
                      ymax = estimate + 1.96 * std.error,
                      colour = term)) +
  geom_hline(yintercept = 0, color = "grey", linetype = "dashed") +
  # geom_text(aes(label = paste("bar(R)^2==", round(adj_rsq, 2))), parse = TRUE,
  #           x = 9, y = 1.4, family = font, size = 3) +
  coord_flip() +
  scale_fill_solarized(guide = FALSE) +
  scale_colour_manual(guide = FALSE, values = rev(solarized_palette(length(predictors)))) +
  xlab("") +
scale_y_continuous(name = "Coefficient Estimate")

# eng_models <- eng_data %>%
#   group_by(measure) %>%
#   nest() %>%
#   mutate(model = map(data, lang_model_fun))
#
# ggplot(eng_data, aes(x = kl_mean, y = prop)) +
#   facet_wrap(age ~ measure) +
#   geom_point()




# eng_cor <- eng_data %>%
#   filter(measure == "produces") %>%
#   spread(predictor, value) %>%
#   ungroup() %>%
#   distinct_(.dots = c("aoa", predictors)) %>%
#   filter(!is.na(aoa))

# ggcorplot(eng_cor)
#
# cors <- expand.grid(predictor1 = colnames(eng_cor),
#                     predictor2 = colnames(eng_cor)) %>%
#   mutate(cor = map2_dbl(predictor1, predictor2,
#                         ~cor(eng_cor[[.x]], eng_cor[[.y]])))
#
# ggplot(cors, aes(x = predictor1, y = predictor2)) +
#   coord_fixed() +
#   geom_tile(aes(fill = abs(cor))) +
#   scale_fill_gradient2()
