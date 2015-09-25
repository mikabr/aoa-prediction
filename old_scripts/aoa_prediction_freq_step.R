library(wordbankr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(langcog)
library(readr)
font <- "Open Sans"

words <- get_item_data(mode = "local") %>%
  filter(type == "word") %>%
  mutate(definition = tolower(definition))

progress <- freqs %>%
  group_by(language, form) %>%
  summarise(num_items = n(),
            num_uni_lemmas = sum(!is.na(uni_lemma)),
            num_freqs = sum(!is.na(frequency)))

uni_data <- raw_data %>%
  group_by(language, form, measure, lexical_category, category, uni_lemma, data_id) %>%
  summarise(uni_value = any(value),
            words = paste(definition, collapse = ", "))

uni_props <- uni_data %>%
  group_by(language, form, measure, lexical_category, category, uni_lemma, words) %>%
  summarise(prop = mean(uni_value, na.rm = TRUE))

uni_joined <- uni_props %>%
  left_join(uni_freqs)

ggplot(filter(uni_joined, !is.na(uni_freq), measure == "understands"),
       aes(x = uni_freq, y = prop, colour = lexical_category)) +
  facet_wrap(~language + form) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_log10() +
  scale_colour_solarized() +
  xlab("\nLog frequency in child-directed speech") +
  ylab("Proportion of children understanding\n") +
  theme_bw(base_size = 14) +
  theme(text = element_text(family = font))

# uni_props %>%
#   group_by(measure, lexical_category, category, uni_lemma) %>%
#   summarise(prop_diff = max(prop) - min(prop)) %>%
#   filter(prop_diff > 0.7)
#
# uni_props %>%
#   filter(measure == "produces", uni_lemma == "bottle") %>%
#   ungroup() %>%
#   select(language, form, uni_lemma, words, prop)

#
# num_insts <- uni_lemmas %>%
#   group_by(lexical_category, category, uni_lemma) %>%
#   summarise(num_instruments = n())
# num_insts %>%
#   group_by(num_instruments) %>%
#   summarise(n = n())
#
# ggplot(num_insts, aes(x = num_instruments)) +
#   facet_wrap(~lexical_category) +
#   geom_bar(stat = "bin", binwidth = 1) +
#   theme_bw()
