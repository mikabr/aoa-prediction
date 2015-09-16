library(dplyr)
library(tidyr)
library(purrr)
library(readr)

words <- get_item_data(mode = "local") %>%
  filter(type == "word") %>%
  mutate(definition = tolower(definition))

#dimension <- "category"
#dimension <- "lexical_category"
dimension <- "lexical_class"

uni_lemmas <- words %>%
  mutate(instrument = paste(language, form)) %>%
  select(-language, -form) %>%
  filter(!is.na(uni_lemma)) %>%
  group_by_("instrument", dimension, "uni_lemma") %>%
  summarise(words = paste(definition, collapse = ", "))

by_inst <- uni_lemmas %>%
  spread(instrument, words, fill = "")

by_inst %>%
  split(.[[dimension]]) %>%
  map(function(category_lemmas) {
    write_csv(category_lemmas,
              sprintf("%s/uni_lemmas_%s.csv", dimension,
                      unique(category_lemmas[[dimension]])))
  })
