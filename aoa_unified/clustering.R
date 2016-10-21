data_path <- "../../aoa_unified/saved_data"
uni_prop_data <- feather::read_feather(
  file.path(data_path, "uni_prop_data.feather")
)

eng <- uni_prop_data %>%
  filter(language == "English")

fit_aoa <- function(data) {
  glm(cbind(num_true, num_false) ~ age, data, family = "binomial")
}

eng_coefs <- eng %>%
  filter(!grepl(",", lexical_classes)) %>%
  rename(lexical_class = lexical_classes) %>%
  group_by(measure, lexical_class, uni_lemma) %>%
  nest() %>%
  mutate(model = map(data, fit_aoa),
         intercept = map_dbl(model, ~coefficients(.x)[["(Intercept)"]]),
         slope = map_dbl(model, ~coefficients(.x)[["age"]])) %>%
  select(-data, -model)

lang_coefs <- uni_prop_data %>%
  filter(!grepl(",", lexical_classes)) %>%
  rename(lexical_class = lexical_classes) %>%
  group_by(language, measure, lexical_class, uni_lemma) %>%
  nest() %>%
  mutate(model = map(data, fit_aoa),
         intercept = map_dbl(model, ~coefficients(.x)[["(Intercept)"]]),
         slope = map_dbl(model, ~coefficients(.x)[["age"]])) %>%
  select(-data, -model)

lang_coefs <- lang_coefs %>%
  mutate(aoa = -intercept / slope)

# pair_aoa <- lang_coefs %>%
#   filter(measure == "understands", aoa > 0, aoa < 40) %>%
#   group_by(uni_lemma) %>%
#   filter(n() == 10) %>%
#   select(language, lexical_class, uni_lemma, aoa) %>%
#   spread(language, aoa)
#
# ggcorplot(pair_aoa)

aoas <- lang_coefs %>%
  filter(measure == "understands", aoa > 0, aoa < 40) %>%
  select(language, lexical_class, uni_lemma, aoa)

feather::write_feather(aoas, "app/aoas.feather")

pair_cor <- function(l1, l2) {
  pair_aoas <- aoas %>%
    filter(language == l1 | language == l2) %>%
    spread(language, aoa)
  cor(pair_aoas[[l1]], pair_aoas[[l2]], use = "complete.obs")
}

pair_aoas <- map_df(unique(aoas$language), function(l1) {
  map_df(setdiff(unique(aoas$language), l1), function(l2) {
    aoas %>%
      filter(language == l1 | language == l2) %>%
      spread(language, aoa) %>%
      mutate(language1 = l1, language2 = l2) %>%
      rename_(.dots = list("aoa1" = as.name(l1), "aoa2" = as.name(l2)))
  })
})

ggplot(pair_aoas, aes(x = aoa1, y = aoa2, colour = lexical_class)) +
  facet_grid(language1 ~ language2) +
  coord_equal() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey") +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_colour_solarized()
  #geom_text(aes(label = uni_lemma))

lang_cors <- expand.grid(language1 = unique(lang_coefs$language),
            language2 = unique(lang_coefs$language),
            stringsAsFactors = FALSE) %>%
  mutate(cor = map2_dbl(language1, language2, pair_cor))

map(each_lang, function(l1) nrow(l1))
map(each_lang, function(l1) map(each_lang, function(l2) cor(l1$aoa, l2$aoa)))

ggplot(eng_coefs, aes(x = intercept, y = slope)) + #, colour = lexical_class)) +
  facet_wrap(~measure, scales = "free") +
  geom_text(aes(label = uni_lemma), size = 2.5, colour = solarized_palette(1))
  #scale_colour_solarized()

lang_coefs %>%
  filter(measure == "understands") %>%
  ggplot(aes(x = intercept, y = slope)) + #, colour = lexical_class)) +
    facet_wrap(~language) +
    geom_text(aes(label = uni_lemma), size = 2.5, colour = solarized_palette(1))

lang_coefs %>%
  filter(measure == "understands", uni_lemma == "dog") %>%
  ggplot(aes(x = intercept, y = slope)) +
    geom_text(aes(label = language), size = 2.5, colour = solarized_palette(1))

coef_var <- lang_coefs %>%
  mutate(aoa = -intercept / slope) %>%
  group_by(measure, lexical_class, uni_lemma) %>%
  summarise(num_langs = n(),
            mean_intercept = mean(intercept),
            mean_slope = mean(slope),
            mean_aoa = mean(aoa),
            var_intercept = var(intercept),
            var_slope = var(slope),
            var_aoa = var(aoa))

coef_var %>%
  filter(num_langs > 9, measure == "understands") %>% #View()
  ggplot(aes(x = mean_intercept, y = var_intercept)) +
    geom_text(aes(label = uni_lemma), size = 2.5, colour = solarized_palette(1))

coef_var %>%
  filter(num_langs > 9, measure == "understands") %>% View()
  ggplot(aes(x = var_intercept)) +
  geom_density()
