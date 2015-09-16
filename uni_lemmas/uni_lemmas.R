library(dplyr)
library(tidyr)
library(purrr)
library(readr)

words <- get_item_data(mode = "local") %>%
  filter(type == "word") %>%
  mutate(definition = tolower(definition))

uni_lemmas <- words %>%
  mutate(instrument = paste(language, form)) %>%
  select(-language, -form) %>%
  filter(!is.na(uni_lemma)) %>%
  group_by(instrument, lexical_category, uni_lemma) %>%
  summarise(#num_words = n(),
            #num_unique = length(unique(definition)),
            words = paste(definition, collapse = ", ")) #%>%
  #filter(num_words > 1, num_unique < num_words)

by_inst <- uni_lemmas %>%
  spread(instrument, words, fill = "")

by_inst %>%
  split(.$category) %>%
  map(function(category_lemmas) {
    write_csv(category_lemmas,
              sprintf("uni_lemmas_%s.csv", unique(category_lemmas$category)))
  })
